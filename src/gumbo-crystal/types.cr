require "./enums"

lib LibGumbo
  # The type for an allocator function.  Takes the 'userdata' member of the
  # GumboParser struct as its first argument.  Semantics should be the same as
  # malloc, i.e. return a block of size_t bytes on success or NULL on failure.
  # Allocating a block of 0 bytes behaves as per malloc.
  type GumboAllocatorFunction = Void*, LibC::SizeT -> LibC::Int* # Void*

  # The type for a deallocator function.  Takes the 'userdata' member of the
  # GumboParser struct as its first argument.
  type GumboDeallocatorFunction = Void*, Void* -> Void

  # A simple vector implementation.  This stores a pointer to a data array and a
  # length.  All elements are stored as void*; client code must cast to the
  # appropriate type.  Overflows upon addition result in reallocation of the data
  # array, with the size doubling to maintain O(1) amortized cost.  There is no
  # removal function, as this isn't needed for any of the operations within this
  # library.  Iteration can be done through inspecting the structure directly in
  # a for-loop.
  struct GumboVector
    # Data elements.  This points to a dynamically-allocated array of capacity
    # elements, each a void* to the element itself.
    data : Void**

    # Number of elements currently in the vector.
    length : LibC::UInt

    # Current array capacity.
    capacity : LibC::UInt
  end

  # A struct representing a string or part of a string.  Strings within the
  # parser are represented by a char* and a length; the char* points into
  # an existing data buffer owned by some other code (often the original input).
  # GumboStringPieces are assumed (by convention) to be immutable, because they
  # may share data.  Use GumboStringBuffer if you need to construct a string.
  # Clients should assume that it is not NUL-terminated, and should always use
  # explicit lengths when manipulating them.
  struct GumboStringPiece
    # A pointer to the beginning of the string.  NULL iff length == 0.
    data : LibC::Char*

    # The length of the string fragment, in bytes.  May be zero.
    length : LibC::SizeT
  end

  # A struct representing a character position within the original text buffer.
  # Line and column numbers are 1-based and offsets are 0-based, which matches
  # how most editors and command-line tools work.  Also, columns measure
  # positions in terms of characters while offsets measure by bytes; this is
  # because the offset field is often used to pull out a particular region of
  # text (which in most languages that bind to C implies pointer arithmetic on a
  # buffer of bytes), while the column field is often used to reference a
  # particular column on a printable display, which nowadays is usually UTF-8.
  struct GumboSourcePosition
    line : LibC::UInt
    column : LibC::UInt
    offset : LibC::UInt
  end

  # The struct used to represent TEXT, CDATA, COMMENT, and WHITESPACE elements.
  # This contains just a block of text and its position.
  struct GumboText
    # The text of this node, after entities have been parsed and decoded.  For
    # comment/cdata nodes, this does not include the comment delimiters.
    text : LibC::Char*

    # The original text of this node, as a pointer into the original buffer.  For
    # comment/cdata nodes, this includes the comment delimiters.
    original_text : GumboStringPiece

    # The starting position of this node.  This corresponds to the position of
    # original_text, before entities are decoded.
    start_pos : GumboSourcePosition
  end

  # The struct used to represent all HTML elements.  This contains information
  # about the tag, attributes, and child nodes.
  struct GumboElement
    # An array of GumboNodes, containing the children of this element.  Pointers
    # are owned.
    children : GumboVector

    # The GumboTag enum for this element.
    tag : GumboTag

    # The GumboNamespaceEnum for this element.
    tag_namespace : GumboNamespaceEnum

    # A GumboStringPiece pointing to the original tag text for this element,
    # pointing directly into the source buffer.  If the tag was inserted
    # algorithmically (for example, <head> or <tbody> insertion), this will be a
    # zero-length string.
    original_tag : GumboStringPiece

    # A GumboStringPiece pointing to the original end tag text for this element.
    # If the end tag was inserted algorithmically, (for example, closing a
    # self-closing tag), this will be a zero-length string.
    original_end_tag : GumboStringPiece

    # The source position for the start of the start tag. */
    start_pos : GumboSourcePosition

    # The source position for the start of the end tag. */
    end_pos : GumboSourcePosition

    # An array of GumboAttributes, containing the attributes for this tag in the
    # order that they were parsed.  Pointers are owned.
    attributes : GumboVector
  end

  # Information specific to document nodes.
  struct GumboDocument
    # An array of GumboNodes, containing the children of this element.  This will
    # normally consist of the <html> element and any comment nodes found.
    # Pointers are owned.
    children : GumboVector

    # True if there was an explicit doctype token as opposed to it being omitted.
    has_doctype : Bool

    # Fields from the doctype token, copied verbatim.
    name : LibC::Char*
    public_identifier : LibC::Char*
    system_identifier : LibC::Char*

    # Whether or not the document is in QuirksMode, as determined by the values
    # in the GumboTokenDocType template.
    doc_type_quirks_mode : GumboQuirksModeEnum
  end

  # The actual node data.
  union V
    document : GumboDocument  # For GUMBO_NODE_DOCUMENT.
    element : GumboElement    # For GUMBO_NODE_ELEMENT.
    text : GumboText          # For everything else.
  end

  # A supertype for GumboElement and GumboText, so that we can include one
  # generic type in lists of children and cast as necessary to subtypes.
  struct GumboNode
    # The type of node that this is.
    type : GumboNodeType

    # Pointer back to parent node.  Not owned.
    parent : GumboNode*

    # The index within the parent's children vector of this node.
    index_within_parent : LibC::SizeT

    # A bitvector of flags containing information about why this element was
    # inserted into the parse tree, including a variety of special parse
    # situations.
    parse_flags : GumboParseFlags

    v : V
  end

  # The output struct containing the results of the parse.
  struct GumboOutput
    # Pointer to the document node.  This is a GumboNode of type NODE_DOCUMENT
    # that contains the entire document as its child.
    document : GumboNode*

    # Pointer to the root node.  This the <html> tag that forms the root of the
    # document.
    root : GumboNode*

    # A list of errors that occurred during the parse.
    # NOTE: In version 1.0 of this library, the API for errors hasn't been fully
    # fleshed out and may change in the future.  For this reason, the GumboError
    # header isn't part of the public API.  Contact us if you need errors
    # reported so we can work out something appropriate for your use-case.
    errors : GumboVector
  end

  # Input struct containing configuration options for the parser.
  # These let you specify alternate memory managers, provide different error
  # handling, etc.
  # Use kGumboDefaultOptions for sensible defaults, and only set what you need.
  struct GumboOptions
    # A memory allocator function.  Default: malloc.
    allocator : GumboAllocatorFunction

    # A memory deallocator function. Default: free.
    deallocator : GumboDeallocatorFunction

    # An opaque object that's passed in as the first argument to all callbacks
    # used by this library.  Default: NULL.
    userdata : Void*

    # The tab-stop size, for computing positions in source code that uses tabs.
    # Default: 8.
    tab_stop : LibC::Int

    # Whether or not to stop parsing when the first error is encountered.
    # Default: false.
    stop_on_first_error : Bool

    # The maximum number of errors before the parser stops recording them.  This
    # is provided so that if the page is totally borked, we don't completely fill
    # up the errors vector and exhaust memory with useless redundant errors.  Set
    # to -1 to disable the limit.
    # Default: -1
    max_errors : LibC::Int

    # The fragment context for parsing:
    # https://html.spec.whatwg.org/multipage/syntax.html#parsing-html-fragments
    #
    # If GUMBO_TAG_LAST is passed here, it is assumed to be "no fragment", i.e.
    # the regular parsing algorithm.  Otherwise, pass the tag enum for the
    # intended parent of the parsed fragment.  We use just the tag enum rather
    # than a full node because that's enough to set all the parsing context we
    # need, and it provides some additional flexibility for client code to act as
    # if parsing a fragment even when a full HTML tree isn't available.
    #
    # Default: GUMBO_TAG_LAST
    fragment_context : GumboTag

    # The namespace for the fragment context.  This lets client code
    # differentiate between, say, parsing a <title> tag in SVG vs. parsing it in
    # HTML.
    # Default: GUMBO_NAMESPACE_HTML
    fragment_namespace : GumboNamespaceEnum
  end
end

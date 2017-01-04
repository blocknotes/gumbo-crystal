require "./types"

@[Link("gumbo")]
lib LibGumbo
  # Compares two GumboStringPieces, and returns true if they're equal or false
  # otherwise.
  fun gumbo_string_equals( str1 : GumboStringPiece*, str2 : GumboStringPiece* ): Bool

  # Compares two GumboStringPieces ignoring case, and returns true if they're
  # equal or false otherwise.
  fun gumbo_string_equals_ignore_case( str1 : GumboStringPiece*, str2 : GumboStringPiece* ): Bool

  # Returns the first index at which an element appears in this vector (testing
  # by pointer equality), or -1 if it never does.
  fun gumbo_vector_index_of( vector : GumboVector*, element : Void* ): LibC::Int

  # Returns the normalized (usually all-lowercased, except for foreign content)
  # tag name for an GumboTag enum.  Return value is static data owned by the
  # library.
  fun gumbo_normalized_tagname( tag : GumboTag ): LibC::Char*

  # Extracts the tag name from the original_text field of an element or token by
  # stripping off </> characters and attributes and adjusting the passed-in
  # GumboStringPiece appropriately.  The tag name is in the original case and
  # shares a buffer with the original text, to simplify memory management.
  # Behavior is undefined if a string-piece that doesn't represent an HTML tag
  # (<tagname> or </tagname>) is passed in.  If the string piece is completely
  # empty (NULL data pointer), then this function will exit successfully as a
  # no-op.
  fun gumbo_tag_from_original_text( text : GumboStringPiece* ): Void

  # Fixes the case of SVG elements that are not all lowercase.
  # http://www.whatwg.org/specs/web-apps/current-work/multipage/tree-construction.html#parsing-main-inforeign
  # This is not done at parse time because there's no place to store a mutated
  # tag name.  tag_name is an enum (which will be TAG_UNKNOWN for most SVG tags
  # without special handling), while original_tag_name is a pointer into the
  # original buffer.  Instead, we provide this helper function that clients can
  # use to rename SVG tags as appropriate.
  # Returns the case-normalized SVG tagname if a replacement is found, or NULL if
  # no normalization is called for.  The return value is static data and owned by
  # the library.
  fun gumbo_normalize_svg_tagname( tagname : GumboStringPiece* ): LibC::Char*

  # Converts a tag name string (which may be in upper or mixed case) to a tag
  # enum. The `tag` version expects `tagname` to be NULL-terminated
  fun gumbo_tag_enum( tagname : LibC::Char* ): GumboTag
  fun gumbo_tagn_enum( tagname : LibC::Char*, length : LibC::UInt ): GumboTag

  # Given a vector of GumboAttributes, look up the one with the specified name
  # and return it, or NULL if no such attribute exists.  This uses a
  # case-insensitive match, as HTML is case-insensitive.
  fun gumbo_get_attribute( attrs : GumboVector*, name : LibC::Char* ): GumboAttribute*

  # Parses a buffer of UTF8 text into an GumboNode parse tree.  The buffer must
  # live at least as long as the parse tree, as some fields (eg. original_text)
  # point directly into the original buffer.
  #
  # This doesn't support buffers longer than 4 gigabytes.
  fun gumbo_parse( buffer : LibC::Char* ): GumboOutput*

  # Extended version of gumbo_parse that takes an explicit options structure,
  # buffer, and length.
  fun gumbo_parse_with_options( options : GumboOptions*, buffer : LibC::Char*, buffer_length : LibC::SizeT ): GumboOutput*

  # Release the memory used for the parse tree & parse errors.
  fun gumbo_destroy_output( options : GumboOptions*, output : GumboOutput* ): Void
end

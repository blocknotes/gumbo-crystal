lib LibGumbo
  # Attribute namespaces.
  # HTML includes special handling for XLink, XML, and XMLNS namespaces on
  # attributes.  Everything else goes in the generic "NONE" namespace.
  enum GumboAttributeNamespaceEnum
    GUMBO_ATTR_NAMESPACE_NONE
    GUMBO_ATTR_NAMESPACE_XLINK
    GUMBO_ATTR_NAMESPACE_XML
    GUMBO_ATTR_NAMESPACE_XMLNS
  end

  # Namespaces.
  # Unlike in X(HT)ML, namespaces in HTML5 are not denoted by a prefix.  Rather,
  # anything inside an <svg> tag is in the SVG namespace, anything inside the
  # <math> tag is in the MathML namespace, and anything else is inside the HTML
  # namespace.  No other namespaces are supported, so this can be an enum only.
  enum GumboNamespaceEnum
    GUMBO_NAMESPACE_HTML
    GUMBO_NAMESPACE_SVG
    GUMBO_NAMESPACE_MATHML
  end

  #  Enum denoting the type of node.  This determines the type of the node.v union.
  enum GumboNodeType
    # Document node.  v will be a GumboDocument.
    GUMBO_NODE_DOCUMENT
    # Element node.  v will be a GumboElement.
    GUMBO_NODE_ELEMENT
    # Text node.  v will be a GumboText.
    GUMBO_NODE_TEXT
    # CDATA node. v will be a GumboText.
    GUMBO_NODE_CDATA
    # Comment node.  v will be a GumboText, excluding comment delimiters.
    GUMBO_NODE_COMMENT
    # Text node, where all contents is whitespace.  v will be a GumboText.
    GUMBO_NODE_WHITESPACE
    # Template node.  This is separate from GUMBO_NODE_ELEMENT because many
    #  client libraries will want to ignore the contents of template nodes, as
    #  the spec suggests.  Recursing on GUMBO_NODE_ELEMENT will do the right thing
    #  here, while clients that want to include template contents should also
    #  check for GUMBO_NODE_TEMPLATE.  v will be a GumboElement.
    GUMBO_NODE_TEMPLATE
  end

  # Parse flags.
  # We track the reasons for parser insertion of nodes and store them in a
  # bitvector in the node itself.  This lets client code optimize out nodes that
  # are implied by the HTML structure of the document, or flag constructs that
  # may not be allowed by a style guide, or track the prevalence of incorrect or
  # tricky HTML code.
  enum GumboParseFlags
    # A normal node - both start and end tags appear in the source, nothing has
    # been reparented.
    GUMBO_INSERTION_NORMAL = 0

    # A node inserted by the parser to fulfill some implicit insertion rule.
    # This is usually set in addition to some other flag giving a more specific
    # insertion reason; it's a generic catch-all term meaning "The start tag for
    # this node did not appear in the document source".
    GUMBO_INSERTION_BY_PARSER = 1 << 0

    # A flag indicating that the end tag for this node did not appear in the
    # document source.  Note that in some cases, you can still have
    # parser-inserted nodes with an explicit end tag: for example, "Text</html>"
    # has GUMBO_INSERTED_BY_PARSER set on the <html> node, but
    # GUMBO_INSERTED_END_TAG_IMPLICITLY is unset, as the </html> tag actually
    # exists.  This flag will be set only if the end tag is completely missing;
    # in some cases, the end tag may be misplaced (eg. a </body> tag with text
    # afterwards), which will leave this flag unset and require clients to
    # inspect the parse errors for that case.
    GUMBO_INSERTION_IMPLICIT_END_TAG = 1 << 1

    # Value 1 << 2 was for a flag that has since been removed.

    # A flag for nodes that are inserted because their presence is implied by
    # other tags, eg. <html>, <head>, <body>, <tbody>, etc.
    GUMBO_INSERTION_IMPLIED = 1 << 3

    # A flag for nodes that are converted from their end tag equivalents.  For
    # example, </p> when no paragraph is open implies that the parser should
    # create a <p> tag and immediately close it, while </br> means the same thing
    # as <br>.
    GUMBO_INSERTION_CONVERTED_FROM_END_TAG = 1 << 4

    # A flag for nodes that are converted from the parse of an <isindex> tag.
    GUMBO_INSERTION_FROM_ISINDEX = 1 << 5

    # A flag for <image> tags that are rewritten as <img>.
    GUMBO_INSERTION_FROM_IMAGE = 1 << 6

    # A flag for nodes that are cloned as a result of the reconstruction of
    # active formatting elements.  This is set only on the clone; the initial
    # portion of the formatting run is a NORMAL node with an IMPLICIT_END_TAG.
    GUMBO_INSERTION_RECONSTRUCTED_FORMATTING_ELEMENT = 1 << 7

    # A flag for nodes that are cloned by the adoption agency algorithm.
    GUMBO_INSERTION_ADOPTION_AGENCY_CLONED = 1 << 8

    # A flag for nodes that are moved by the adoption agency algorithm.
    GUMBO_INSERTION_ADOPTION_AGENCY_MOVED = 1 << 9

    # A flag for nodes that have been foster-parented out of a table (or
    # should've been foster-parented, if verbatim mode is set).
    GUMBO_INSERTION_FOSTER_PARENTED = 1 << 10
  end

  # http://www.whatwg.org/specs/web-apps/current-work/complete/dom.html#quirks-mode
  enum GumboQuirksModeEnum
    GUMBO_DOCTYPE_NO_QUIRKS
    GUMBO_DOCTYPE_QUIRKS
    GUMBO_DOCTYPE_LIMITED_QUIRKS
  end

  # An enum for all the tags defined in the HTML5 standard.  These correspond to
  # the tag names themselves.  Enum constants exist only for tags which appear in
  # the spec itself (or for tags with special handling in the SVG and MathML
  # namespaces); any other tags appear as GUMBO_TAG_UNKNOWN and the actual tag
  # name can be obtained through original_tag.
  #
  # This is mostly for API convenience, so that clients of this library don't
  # need to perform a strcasecmp to find the normalized tag name.  It also has
  # efficiency benefits, by letting the parser work with enums instead of
  # strings.
  enum GumboTag
    # Load all the tags from an external source, generated from tag.in.
    GUMBO_TAG_HTML
    GUMBO_TAG_HEAD
    GUMBO_TAG_TITLE
    GUMBO_TAG_BASE
    GUMBO_TAG_LINK
    GUMBO_TAG_META
    GUMBO_TAG_STYLE
    GUMBO_TAG_SCRIPT
    GUMBO_TAG_NOSCRIPT
    GUMBO_TAG_TEMPLATE
    GUMBO_TAG_BODY
    GUMBO_TAG_ARTICLE
    GUMBO_TAG_SECTION
    GUMBO_TAG_NAV
    GUMBO_TAG_ASIDE
    GUMBO_TAG_H1
    GUMBO_TAG_H2
    GUMBO_TAG_H3
    GUMBO_TAG_H4
    GUMBO_TAG_H5
    GUMBO_TAG_H6
    GUMBO_TAG_HGROUP
    GUMBO_TAG_HEADER
    GUMBO_TAG_FOOTER
    GUMBO_TAG_ADDRESS
    GUMBO_TAG_P
    GUMBO_TAG_HR
    GUMBO_TAG_PRE
    GUMBO_TAG_BLOCKQUOTE
    GUMBO_TAG_OL
    GUMBO_TAG_UL
    GUMBO_TAG_LI
    GUMBO_TAG_DL
    GUMBO_TAG_DT
    GUMBO_TAG_DD
    GUMBO_TAG_FIGURE
    GUMBO_TAG_FIGCAPTION
    GUMBO_TAG_MAIN
    GUMBO_TAG_DIV
    GUMBO_TAG_A
    GUMBO_TAG_EM
    GUMBO_TAG_STRONG
    GUMBO_TAG_SMALL
    GUMBO_TAG_S
    GUMBO_TAG_CITE
    GUMBO_TAG_Q
    GUMBO_TAG_DFN
    GUMBO_TAG_ABBR
    GUMBO_TAG_DATA
    GUMBO_TAG_TIME
    GUMBO_TAG_CODE
    GUMBO_TAG_VAR
    GUMBO_TAG_SAMP
    GUMBO_TAG_KBD
    GUMBO_TAG_SUB
    GUMBO_TAG_SUP
    GUMBO_TAG_I
    GUMBO_TAG_B
    GUMBO_TAG_U
    GUMBO_TAG_MARK
    GUMBO_TAG_RUBY
    GUMBO_TAG_RT
    GUMBO_TAG_RP
    GUMBO_TAG_BDI
    GUMBO_TAG_BDO
    GUMBO_TAG_SPAN
    GUMBO_TAG_BR
    GUMBO_TAG_WBR
    GUMBO_TAG_INS
    GUMBO_TAG_DEL
    GUMBO_TAG_IMAGE
    GUMBO_TAG_IMG
    GUMBO_TAG_IFRAME
    GUMBO_TAG_EMBED
    GUMBO_TAG_OBJECT
    GUMBO_TAG_PARAM
    GUMBO_TAG_VIDEO
    GUMBO_TAG_AUDIO
    GUMBO_TAG_SOURCE
    GUMBO_TAG_TRACK
    GUMBO_TAG_CANVAS
    GUMBO_TAG_MAP
    GUMBO_TAG_AREA
    GUMBO_TAG_MATH
    GUMBO_TAG_MI
    GUMBO_TAG_MO
    GUMBO_TAG_MN
    GUMBO_TAG_MS
    GUMBO_TAG_MTEXT
    GUMBO_TAG_MGLYPH
    GUMBO_TAG_MALIGNMARK
    GUMBO_TAG_ANNOTATION_XML
    GUMBO_TAG_SVG
    GUMBO_TAG_FOREIGNOBJECT
    GUMBO_TAG_DESC
    GUMBO_TAG_TABLE
    GUMBO_TAG_CAPTION
    GUMBO_TAG_COLGROUP
    GUMBO_TAG_COL
    GUMBO_TAG_TBODY
    GUMBO_TAG_THEAD
    GUMBO_TAG_TFOOT
    GUMBO_TAG_TR
    GUMBO_TAG_TD
    GUMBO_TAG_TH
    GUMBO_TAG_FORM
    GUMBO_TAG_FIELDSET
    GUMBO_TAG_LEGEND
    GUMBO_TAG_LABEL
    GUMBO_TAG_INPUT
    GUMBO_TAG_BUTTON
    GUMBO_TAG_SELECT
    GUMBO_TAG_DATALIST
    GUMBO_TAG_OPTGROUP
    GUMBO_TAG_OPTION
    GUMBO_TAG_TEXTAREA
    GUMBO_TAG_KEYGEN
    GUMBO_TAG_OUTPUT
    GUMBO_TAG_PROGRESS
    GUMBO_TAG_METER
    GUMBO_TAG_DETAILS
    GUMBO_TAG_SUMMARY
    GUMBO_TAG_MENU
    GUMBO_TAG_MENUITEM
    GUMBO_TAG_APPLET
    GUMBO_TAG_ACRONYM
    GUMBO_TAG_BGSOUND
    GUMBO_TAG_DIR
    GUMBO_TAG_FRAME
    GUMBO_TAG_FRAMESET
    GUMBO_TAG_NOFRAMES
    GUMBO_TAG_ISINDEX
    GUMBO_TAG_LISTING
    GUMBO_TAG_XMP
    GUMBO_TAG_NEXTID
    GUMBO_TAG_NOEMBED
    GUMBO_TAG_PLAINTEXT
    GUMBO_TAG_RB
    GUMBO_TAG_STRIKE
    GUMBO_TAG_BASEFONT
    GUMBO_TAG_BIG
    GUMBO_TAG_BLINK
    GUMBO_TAG_CENTER
    GUMBO_TAG_FONT
    GUMBO_TAG_MARQUEE
    GUMBO_TAG_MULTICOL
    GUMBO_TAG_NOBR
    GUMBO_TAG_SPACER
    GUMBO_TAG_TT
    GUMBO_TAG_RTC
    # Used for all tags that don't have special handling in HTML.  Add new tags
    # to the end of tag.in so as to preserve backwards-compatibility.
    GUMBO_TAG_UNKNOWN
    # A marker value to indicate the end of the enum, for iterating over it.
    # Also used as the terminator for varargs functions that take tags.
    GUMBO_TAG_LAST
  end
end

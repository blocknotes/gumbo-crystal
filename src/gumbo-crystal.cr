require "./gumbo-crystal/*"

module Gumbo
  GumboEmptySourcePosition = LibGumbo::GumboSourcePosition.new

  GumboEmptyString = LibGumbo::GumboStringPiece.new

  GumboEmptyVector = LibGumbo::GumboVector.new

  GumboDefaultOptions = LibGumbo::GumboOptions.new
  GumboDefaultOptions.allocator = ->( unused : Void*, size : LibC::SizeT ) do
    Pointer( LibC::Int ).malloc size
  end
  GumboDefaultOptions.deallocator = ->( unused : Void*, ptr : Void* ) do
    # free( ptr )
  end
  GumboDefaultOptions.userdata = nil
  GumboDefaultOptions.tab_stop = 8
  GumboDefaultOptions.stop_on_first_error = false
  GumboDefaultOptions.max_errors = -1
  GumboDefaultOptions.fragment_context = LibGumbo::GumboTag::GUMBO_TAG_LAST
  GumboDefaultOptions.fragment_namespace = LibGumbo::GumboNamespaceEnum::GUMBO_NAMESPACE_HTML
  DefaultOptions = pointerof( GumboDefaultOptions )
end

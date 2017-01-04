require "./types"

@[Link("gumbo")]
lib LibGumbo
  fun gumbo_parse( buffer : LibC::Char* ): GumboOutput*
  fun gumbo_destroy_output( options : GumboOptions*, output : GumboOutput* ): Void
end

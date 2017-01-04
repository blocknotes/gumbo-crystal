# - Example:     clean_text
# - Description: Extract all text strings from an HTML string
require "../gumbo-crystal"

def clean_text( node : LibGumbo::GumboNode* )
  if node.value.type == LibGumbo::GumboNodeType::GUMBO_NODE_TEXT
    String.new node.value.v.text.text
  elsif node.value.type == LibGumbo::GumboNodeType::GUMBO_NODE_ELEMENT && node.value.v.element.tag != LibGumbo::GumboTag::GUMBO_TAG_SCRIPT && node.value.v.element.tag != LibGumbo::GumboTag::GUMBO_TAG_STYLE
    contents = ""
    children = node.value.v.element.children
    (0...children.length).each do |i|
      text = clean_text( children.data[i].as( LibGumbo::GumboNode* ) ).strip
      contents += " " if( i > 0 && !text.empty? )
      contents += text
    end
    contents
  else
    ""
  end
end

html = <<-END
<div id="content">
  <h1 class="title">Lorem!</h1>
  <p>
    <b>Lorem</b> ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim <span style="color: red">veniam</span>, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo <u>consequat</u>. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla <i>pariatur</i>. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
<div>
END

output = LibGumbo.gumbo_parse html
puts clean_text( output.value.root )
LibGumbo.gumbo_destroy_output Gumbo::DefaultOptions, output

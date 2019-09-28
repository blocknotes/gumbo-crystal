# - Example:     clean_text
# - Description: Extract all text strings from an HTML string
require "../src/gumbo-crystal"

def clean_text(node : Gumbo::Node)
  if node.type == LibGumbo::GumboNodeType::GUMBO_NODE_TEXT
    String.new node.v.text.text
  elsif node.type == LibGumbo::GumboNodeType::GUMBO_NODE_ELEMENT && node.v.element.tag != LibGumbo::GumboTag::GUMBO_TAG_SCRIPT && node.v.element.tag != LibGumbo::GumboTag::GUMBO_TAG_STYLE
    contents = ""
    node.children.each do |child|
      text = clean_text(child).strip
      contents += " " if !text.empty?
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

output = Gumbo::Output.new LibGumbo.gumbo_parse(html)
puts clean_text(output.root)
output.uninitialize

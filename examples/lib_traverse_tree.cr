# - Example:     traverse_tree
# - Description: Traverse all elements in an HTML string
require "../gumbo-crystal"

def traverse_tree( node : LibGumbo::GumboNode* )
  if node.value.type == LibGumbo::GumboNodeType::GUMBO_NODE_ELEMENT
    el = node.value.v.element
    p el.tag
    (0...el.children.length).each do |i|
      traverse_tree( el.children.data[i].as( LibGumbo::GumboNode* ) )
    end
  end
end

html = <<-END
<div id="content">
  <h1 class="title">Lorem<a href="/">!</a></h1>
  <ul>
    <li><a href="#1">First</a></li>
    <li><a href="#2">Second</a></li>
    <li><a href="#3">Third</a></li>
  </ul>
  <footer>
    <a href="#last-link">footer link</a>
  </footer>
<div>
END

output = LibGumbo.gumbo_parse html
traverse_tree( output.value.root )
LibGumbo.gumbo_destroy_output Gumbo::DefaultOptions, output

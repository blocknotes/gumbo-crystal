# - Example:     find_links
# - Description: Find all links in an HTML string
require "../src/gumbo-crystal"

def find_links(node : LibGumbo::GumboNode*)
  if node.value.type == LibGumbo::GumboNodeType::GUMBO_NODE_ELEMENT
    el = node.value.v.element
    if el.tag == LibGumbo::GumboTag::GUMBO_TAG_A
      puts el.tag
      attrs = el.attributes
      if (href = LibGumbo.gumbo_get_attribute(pointerof(attrs), "href"))
        puts String.new(href.value.value)
      end
    end
    (0...el.children.length).each do |i|
      find_links(el.children.data[i].as(LibGumbo::GumboNode*))
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
    <a name="name1">no href</a>
    <a href="#last-link">footer link</a>
  </footer>
<div>
END

output = LibGumbo.gumbo_parse html
find_links(output.value.root)
LibGumbo.gumbo_destroy_output Gumbo::DefaultOptions, output

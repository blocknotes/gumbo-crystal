require "./spec_helper"

describe Gumbo do
  html = <<-END
<div id="content">
  <h1 class="title">Lorem!</h1>
  <p>
    <b>Lorem</b> ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim <span style="color: red">veniam</span>, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo <u>consequat</u>. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla <i>pariatur</i>. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
<div>
END

  it "should initialize the library" do
    output = LibGumbo.gumbo_parse html
    output.null?.should eq(false)
    output.value.is_a?(LibGumbo::GumboOutput).should eq(true)
    LibGumbo.gumbo_destroy_output Gumbo::DefaultOptions, output
  end
end

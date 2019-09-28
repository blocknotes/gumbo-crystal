require "./gumbo-crystal/*"

module Gumbo
  GumboEmptySourcePosition = LibGumbo::GumboSourcePosition.new

  GumboEmptyString = LibGumbo::GumboStringPiece.new

  GumboEmptyVector = LibGumbo::GumboVector.new

  GumboDefaultOptions = LibGumbo::GumboOptions.new
  GumboDefaultOptions.allocator = ->(unused : Void*, size : LibC::SizeT) do
    Pointer(LibC::Int).malloc size
  end
  GumboDefaultOptions.deallocator = ->(unused : Void*, ptr : Void*) do
    # free( ptr )
  end
  GumboDefaultOptions.userdata = nil
  GumboDefaultOptions.tab_stop = 8
  GumboDefaultOptions.stop_on_first_error = false
  GumboDefaultOptions.max_errors = -1
  GumboDefaultOptions.fragment_context = LibGumbo::GumboTag::GUMBO_TAG_LAST
  GumboDefaultOptions.fragment_namespace = LibGumbo::GumboNamespaceEnum::GUMBO_NAMESPACE_HTML
  DefaultOptions = pointerof(GumboDefaultOptions)

  struct Node
    property node

    def initialize(@node : LibGumbo::GumboNode)
    end

    def children
      @children ||= Vector(LibGumbo::GumboNode, Node).new node.v.element.children
    end

    def type
      node.type
    end

    def v
      node.v
    end
  end

  struct Output
    property output

    def initialize(@output : LibGumbo::GumboOutput*)
    end

    def root
      @root ||= Node.new output.value.root.value
    end

    def uninitialize
      LibGumbo.gumbo_destroy_output Gumbo::DefaultOptions, output
    end
  end

  struct Vector(T, U)
    property vector

    def initialize(@vector : LibGumbo::GumboVector)
    end

    def each(&block)
      (0...vector.length).each do |i|
        yield U.new(vector.data[i].as(T*).value)
      end
    end
  end
end

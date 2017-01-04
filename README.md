# gumbo-crystal [![Build Status](https://travis-ci.org/blocknotes/gumbo-crystal.svg)](https://travis-ci.org/blocknotes/gumbo-crystal)

Crystal C bindings for Gumbo library, an HTML5 parsing library made by Google - see [gumbo-parser](https://github.com/google/gumbo-parser)

**NOTE**: actually not all functions are mapped - if you find something missing [contact me](http://www.blocknot.es/me)

## Requirements

- *gumbo* must be installed - see [installation](https://github.com/google/gumbo-parser#installation)
- *pkg-config* must be available

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  gumbo-crystal:
    github: blocknotes/gumbo-crystal
```

## Usage

```ruby
require "gumbo-crystal"
output = LibGumbo.gumbo_parse "<h1>A test</h1>" # lib init
p output.value.root.value.type
LibGumbo.gumbo_destroy_output Gumbo::DefaultOptions, output # lib deinit
```

## More examples

See [examples](https://github.com/blocknotes/gumbo-crystal/tree/master/examples) folder.

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer, Crystal fan :)

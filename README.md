commonmark-lua
==============

This is a lua binding to the libcmark commonmark parser
(https://github.com/jgm/CommonMark).  It requires that libcmark
be installed, and it also requires luajit.

This is work in progress.  The idea is to use libcmark to do the
parsing, and provide pure lua writers and lua hooks for AST
manipulation.  This way authors can easily customize the way
their text is rendered, and create renderers for new formats.

So far we have an `xml` writer (which prints an XML serialization of
the AST) and an `html` writer (which passes the CommonMark spec
tests).

Writers can easily be customized.  For example, suppose you want
to render all regular text content uppercase, leaving code and
HTML tags alone:

``` lua
#!/usr/bin/env luajit

local cmark = require("commonmark")
local W = require("commonmark.writer.html")

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

writer = W.new()
-- customize the writer:
writer.text = function(node)
   local s = cmark.node_get_string_content(node)
   writer.out(writer.escape(s:upper()))
end

io.write(writer.render(doc))

for warning in writer.warnings() do
   print('WARNING', warning)
end
```

Alternatively, you could walk the AST, changing text content to
uppercase, and use the faster libcmark HTML renderer:

``` lua
#!/usr/bin/env luajit

local cmark = require("commonmark")
local W = require("commonmark.writer.html")

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

for node in cmark.walk(doc) do
   if cmark.node_type(node) == 'text' then
      cmark.node_set_string_content(node, cmark.node_get_string_content(node):upper())
   end
end

io.write(cmark.render_html(doc))
```

No doubt the interface can be improved, but this is a start.

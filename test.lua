#!/usr/bin/env luajit

local cmark = require("commonmark")
local generic =require("commonmark.writer.generic")

local cur = doc

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

writer = generic.new()
writer.begin_text = function(node)
   writer.out(cmark.node_get_string_content(node))
   writer.out('\n')
end
print(writer.render(doc))

print("WARNINGS:")
for warning in writer.warnings() do
   print(warning)
end


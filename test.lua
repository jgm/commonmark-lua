#!/usr/bin/env luajit

local cmark = require("commonmark")
local xml =require("commonmark.writer.xml")

local cur = doc

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

writer = xml.new()
print(writer.render(doc))

print("WARNINGS:")
for warning in writer.warnings() do
   print(warning)
end


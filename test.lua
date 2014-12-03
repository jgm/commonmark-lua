#!/usr/bin/env luajit

local cmark = require("commonmark")
local html =require("commonmark.writer.html")

local cur = doc

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

writer = html.new()
io.write(writer.render(doc))

for warning in writer.warnings() do
   print('WARNING', warning)
end


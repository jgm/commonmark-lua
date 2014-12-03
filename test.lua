#!/usr/bin/env luajit

local cmark = require("commonmark")

local format = 'html'
if arg[1] then
   format = arg[1]
end

local W = require("commonmark.writer." .. format)

local cur = doc

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

writer = W.new()
io.write(writer.render(doc))

for warning in writer.warnings() do
   print('WARNING', warning)
end


#!/usr/bin/env luajit

local cmark = require("commonmark")

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

-- TODO remove need for this
ffi = require('ffi')

local cur = doc
local next
local child

local type_table = {
   'BLOCK_QUOTE',
   'LIST',
   'LIST_ITEM',
   'CODE_BLOCK',
   'HTML',
   'PARAGRAPH',
   'HEADER',
   'HRULE',
   'REFERENCE_DEF',
   'TEXT',
   'SOFTBREAK',
   'LINEBREAK',
   'INLINE_CODE',
   'INLINE_HTML',
   'EMPH',
   'STRONG',
   'LINK',
   'IMAGE',
}
type_table[0] = 'DOCUMENT'

local function print_type(direction, node, level)
   local t = tonumber(cmark.node_get_type(node))
   io.write(string.rep('  ', level) .. direction .. ' ' .. type_table[t])
   if t == cmark.NODE_TEXT then
      io.write(' ' .. ffi.string(cmark.node_get_string_content(node)))
   end
   io.write('\n')
end

--[[
for direction, node, level in cmark.walk(doc) do
   print_type(direction, node, level)
end
--]]

local writer = {}
writer.mt = {}
setmetatable(writer, writer.mt)

writer.mt.__index = function(table, key)
   return function(node)
      local direction, kind = unpack(key)
      local indent = string.rep('  ', level)
      if direction == 'enter' then
         io.write(indent .. '<' .. kind .. '>')
         if kind == 'TEXT' then
            io.write('\n' .. indent .. '  ' ..
                        ffi.string(cmark.node_get_string_content(node)))
         end
      else
         io.write(indent .. '</' .. kind .. '>')
      end
      io.write('\n')
   end
end

for direction, node, level in cmark.walk(doc) do
   local key = {direction, type_table[tonumber(cmark.node_get_type(node))]}
   writer[key](node)
end

-- local html = ffi.string(cmark.render_html(doc))
-- print(html)

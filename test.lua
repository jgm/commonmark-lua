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
      io.write(' ' .. cmark.node_get_string_content(node))
   end
   io.write('\n')
end

--[[
for direction, node, level in cmark.walk(doc) do
   print_type(direction, node, level)
end
--]]

local genericwriter = {}
genericwriter.mt = {}
setmetatable(genericwriter, genericwriter.mt)
genericwriter.mt.__index = function(table, key)
   return function(node, level)
      key:gsub('([^_]*)_(.*)',
               function(direction, node_type)
                  local indent = string.rep('  ', level)
                  if direction == 'start' then
                     io.write(indent .. '<' .. node_type .. '>')
                     if node_type == 'TEXT' then
                        io.write('\n' .. indent .. '  ' ..
                                    cmark.node_get_string_content(node))
                     end
                  elseif direction == 'end' then
                     io.write(indent .. '</' .. node_type .. '>')
                  end
                  io.write('\n')
      end)
   end
end

local plainwriter = {}
plainwriter.mt = {}
setmetatable(plainwriter, plainwriter.mt)
plainwriter.mt.__index = function(table, key)
   return function(node, level)
   end
end

plainwriter.start_TEXT = function(node)
   io.write(cmark.node_get_string_content(node))
end
plainwriter.end_TEXT = function(node)
   io.write('\n')
end


for direction, node, level in cmark.walk(doc) do
   local key = direction .. '_' .. type_table[tonumber(cmark.node_get_type(node))]
   genericwriter[key](node, level)
end

for direction, node, level in cmark.walk(doc) do
   local key = direction .. '_' .. type_table[tonumber(cmark.node_get_type(node))]
   plainwriter[key](node, level)
end

-- local html = cmark.render_html(doc)
-- print(html)

#!/usr/bin/env luajit

local cmark = require("commonmark")

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

local cur = doc
local next
local child

local walk = function(action)
   level = 0
   while cur ~= nil do
      action(cur, level)
      child = cmark.node_first_child(cur)
      if child == nil then
         next = cmark.node_next(cur)
         while next == nil do
            cur = cmark.node_parent(cur)
            level = level - 1
            if cur == nil then
               break
            else
               next = cmark.node_next(cur)
            end
         end
         cur = next
      else
         level = level + 1
         cur = child
      end
   end
end

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

local function print_type(node, level)
   local t = tonumber(cmark.node_get_type(node))
   io.write(string.rep('  ', level) .. type_table[t])
   if t == cmark.NODE_TEXT then
      io.write(' ' .. ffi.string(cmark.node_get_string_content(node)))
   end
   io.write('\n')
end

walk(print_type)

-- local html = ffi.string(cmark.render_html(doc))
-- print(html)

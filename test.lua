#!/usr/bin/env luajit

local cmark = require("commonmark")
local generic =require("commonmark.writer.generic")

-- TODO remove need for this
ffi = require('ffi')

local cur = doc

local inp = io.read("*all")
local doc = cmark.parse_document(inp, string.len(inp))

writer = generic.new()
print(writer.render(doc))

--[[
local genericwriter = {}
genericwriter.mt = {}
setmetatable(genericwriter, genericwriter.mt)
genericwriter.mt.__index = function(table, key)
   return function(node)
      key:gsub('([^_]*)_(.*)',
               function(direction, node_type)
                  if direction == 'begin' then
                     io.write('<' .. node_type .. '>')
                     if node_type == 'TEXT' then
                        io.write('\n' ..
                                    cmark.node_get_string_content(node))
                     end
                  elseif direction == 'end' then
                     io.write('</' .. node_type .. '>')
                  end
                  io.write('\n')
      end)
   end
end

local plainwriter = {}
plainwriter.mt = {}
setmetatable(plainwriter, plainwriter.mt)
plainwriter.mt.__index = function(table, key)
   return function(node)
   end
end

plainwriter.begin_TEXT = function(node)
   io.write(cmark.node_get_string_content(node))
end
plainwriter.end_TEXT = function(node)
   io.write('\n')
end

for direction, node in cmark.walk(doc) do
   local key = direction .. '_' .. cmark.node_type(node)
   genericwriter[key](node)
end

for direction, node in cmark.walk(doc) do
   local key = direction .. '_' .. cmark.node_type(node)
   plainwriter[key](node)
end

-- local html = cmark.render_html(doc)
-- print(html)
--]]

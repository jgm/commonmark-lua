cmark = require('commonmark')

local M = {}

--- Returns a table with functions defining a generic writer,
-- which outputs plain text with no formatting.
function M.new(options)


   local W = {}
   local meta = {}
   local buffer = {}
   local warnings = {}

   meta.__index =
      function(_, key)
         table.insert(warnings, string.format("Undefined writer function '%s'",key))
         return (function(node) end)
      end
   setmetatable(W, meta)

  local storing = false
  local stored_buffer = {}

  function W.store()
     storing = true
     stored_buffer = {}
  end

  function W.recall()
     storing = false
     return table.concat(stored_buffer)
  end

   local out = function(s)
      if storing then
         table.insert(stored_buffer, s)
      else
         table.insert(buffer, s)
      end
   end
   W.out = out

  W.indent_level = 0
  W.indent_step = 2

  function W.indent()
     W.out(string.rep(' ', W.indent_level * W.indent_step))
  end

  function W.increase_indent()
     W.indent_level = W.indent_level + 1
  end

  function W.decrease_indent()
     W.indent_level = W.indent_level - 1
  end

   -- ensure a newline if there isn't one already
   local cr = function()
      local laststr = buffer[#buffer]
      if not laststr then return end
      if laststr:sub(-1) ~= '\n' then
         out('\n')
      end
   end
   W.cr = cr

   -- ensure a blankline if there isn't one already
   local blankline = function()
      local laststr = buffer[#buffer]
      if not laststr then return end
      if laststr:sub(-1) ~= '\n' then
         out('\n\n')
      elseif laststr:sub(-2,-2) ~= '\n' then
         out('\n')
      end
   end
   W.blankline = blankline

   W.options = options or {}

   function W.render(doc)
      buffer = {}
      warnings = {}
      for node, direction in cmark.walk(doc) do
         local key
         if direction then
            key = direction .. '_' .. cmark.node_type(node)
         else
            key = cmark.node_type(node)
         end
         W[key](node)
      end
      return table.concat(buffer)
   end

   function W.warnings()
      local i = 0
      local n = table.getn(warnings)
      return function ()
         i = i + 1
         if i <= n then return warnings[i] end
      end
   end

  function W.begin_document(node)
  end

  function W.end_document(node)
  end

  function W.begin_block_quote(node)
  end

  function W.end_block_quote(node)
  end

  function W.begin_list(node)
  end

  function W.end_list(node)
  end

  function W.begin_list_item(node)
  end

  function W.end_list_item(node)
  end

  function W.code_block(node)
  end

  function W.html(node)
  end

  function W.begin_paragraph(node)
  end

  function W.end_paragraph(node)
     blankline()
  end

  function W.begin_header(node)
  end

  function W.end_header(node)
     cr()
  end

  function W.hrule(node)
  end

  function W.begin_reference_def(node)
  end

  function W.end_reference_def(node)
  end

  function W.text(node)
     out(cmark.node_get_string_content(node))
  end

  function W.softbreak(node)
     cr()
  end

  function W.linebreak(node)
     cr()
  end

  function W.inline_code(node)
     out(cmark.node_get_string_content(node))
  end

  function W.inline_html(node)
  end

  function W.begin_emph(node)
  end

  function W.end_emph(node)
  end

  function W.begin_strong(node)
  end

  function W.end_strong(node)
  end

  function W.begin_link(node)
  end

  function W.end_link(node)
  end

  function W.begin_image(node)
  end

  function W.end_image(node)
  end

  --- A cosmo template to be used in producing a standalone document.
  -- `$body` is replaced with the document body, `$title` with the
  -- title, and so on.
  W.template = [[
$body
]]

  return W
end

return M

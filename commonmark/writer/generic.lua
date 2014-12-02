cmark = require('commonmark')

local M = {}

--- Returns a table with functions defining a generic writer,
-- which outputs plain text with no formatting.  `options` is an optional
-- table with the following fields:
--
-- `layout`
-- :   `minimize` (no space between blocks)
-- :   `compact` (no extra blank lines between blocks)
-- :   `default` (blank line between blocks)
function M.new(options)

  options = options or {}

   local W = {}
   local meta = {}
   meta.__index =
      function(_, key)
         io.stderr:write(string.format("WARNING: Undefined writer function '%s'\n",key))
         return (function(node) end)
      end
   setmetatable(W, meta)

   if options.layout == "minimize" then
      W.interblocksep = ""
      W.containersep = ""
   elseif options.layout == "compact" then
      W.interblocksep = "\n"
      W.containersep = "\n"
   else
      W.interblocksep = "\n\n"
      W.containersep = "\n"
   end

   function W.render(doc)
      W.buffer = {}
      for direction, node in cmark.walk(doc) do
         local key = direction .. '_' .. cmark.node_type(node)
         W[key](node)
      end
      return table.concat(W.buffer)
   end

  function W.begin_document()
  end

  --- Finalization tasks at end of document.
  function W.end_document()
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

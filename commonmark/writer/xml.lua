cmark = require('commonmark')
generic = require('commonmark.writer.generic')

local M = {}

function M.new(options)

  local W = generic.new(options)

  local escape = function(s)
     return string.gsub(s, '.',
                  function(c)
                     if c == '<' then return "&lt;"
                     elseif c == '>' then return "&gt;"
                     elseif c == '&' then return "&amp;"
                     elseif c == '"' then return "&quot;"
                     end
     end)
  end

  function W.tag_open(tag, attrs)
     W.out('<' .. tag)
     for k, v in pairs(attrs) do
        W.out(' ' .. k .. '="' .. escape(v) .. '"')
     end
     W.out('>')
  end

  function W.tag_close(tag)
     W.out('</' .. tag .. '>')
  end

  function W.tag_selfclosing(tag, attrs)
     W.out('<' .. tag)
     for k, v in pairs(attrs) do
        W.out(' ' .. k .. '="' .. escape(v) .. '"')
     end
     W.out(' />')
  end

  W.text = function(node)
     local t = escape(cmark.node_get_string_content(node))
     W.tag_selfclosing('text', {value = t})
  end



  return W

end

return M

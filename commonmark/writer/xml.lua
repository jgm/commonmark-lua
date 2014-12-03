cmark = require('commonmark')
generic = require('commonmark.writer.generic')

local M = {}

function M.new(options)

  local W = generic.new(options)

  W.indent_level = 0
  W.indent_step = 2

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

  function W.indent()
     W.out(string.rep(' ', W.indent_level * W.indent_step))
  end

  function W.increase_indent()
     W.indent_level = W.indent_level + 1
  end

  function W.decrease_indent()
     W.indent_level = W.indent_level - 1
  end

  function W.tag_open(tag, attrs)
     W.indent()
     W.out('<' .. tag)
     if attrs then
        for k, v in pairs(attrs) do
           W.out(' ' .. k .. '="' .. escape(v) .. '"')
        end
     end
     W.out('>')
  end

  function W.tag_close(tag)
     W.indent()
     W.out('</' .. tag .. '>')
  end

  function W.tag_selfclosing(tag, attrs)
     W.indent()
     W.out('<' .. tag)
     if attrs then
        for k, v in pairs(attrs) do
           W.out(' ' .. k .. '="' .. escape(v) .. '"')
        end
     end
     W.out(' />')
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
     local t = escape(cmark.node_get_string_content(node))
     W.tag_selfclosing('text', {value = t})
     W.cr()
  end

  function W.softbreak(node)
     W.tag_selfclosing('softbreak')
     W.cr()
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
     W.tag_open('emph')
     W.increase_indent()
     W.cr()
  end

  function W.end_emph(node)
     W.decrease_indent()
     W.tag_close('emph')
     W.cr()
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

  return W

end

return M

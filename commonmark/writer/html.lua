cmark = require('commonmark')
xml = require('commonmark.writer.xml')

local M = {}

function M.new(options)

  local W = xml.new(options)

  local escape = function(s)
     return string.gsub(s, '[<>&"]',
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
     if attrs then
        for k, v in pairs(attrs) do
           W.out(' ' .. k .. '="' .. escape(v) .. '"')
        end
     end
     W.out('>')
  end

  function W.tag_close(tag)
     W.out('</' .. tag .. '>')
  end

  function W.tag_selfclosing(tag, attrs)
     W.out('<' .. tag)
     if attrs then
        for k, v in pairs(attrs) do
           W.out(' ' .. k .. '="' .. escape(v) .. '"')
        end
     end
     W.out(' />')
  end

  local opentag = function(tag, attrs)
     return function(node)
        W.tag_open(tag, attrs)
     end
  end

  local closetag = function(tag, attrs)
     return function(node)
        W.tag_close(tag, attrs)
     end
  end

  local selfclosingtag = function(tag, attrs)
     return function(node)
        W.tag_selfclosing(tag, attrs)
     end
  end

  local cr = W.cr

  W.begin_document = function() return end

  W.end_document = function() return end

  W.begin_block_quote = function(node)
     opentag('blockquote')(node)
     cr()
  end

  W.end_block_quote = function(node)
     cr()
     closetag('blockquote')(node)
  end

  W.begin_list = function(node)
     attrs = {}
     if cmark.node_get_list_type(node) == cmark.ORDERED_LIST then
        tag = 'ol'
     else
        tag = 'ul'
     end
     if cmark.node_get_list_tight(node) then
        attrs.tight = 'true'
     else
        attrs.tight = 'false'
     end
     attrs.start = cmark.node_get_list_start(node)
     opentag(tag, attrs)(node)
     cr()
  end

  W.end_list = function(node)
     if cmark.node_get_list_type(node) == cmark.ORDERED_LIST then
        tag = 'ol'
     else
        tag = 'ul'
     end
     closetag('ul')(node)
     cr()
  end

  W.begin_list_item = opentag('li')

  W.end_list_item = function(node)
     closetag('li')(node)
     cr()
  end

  function W.code_block(node)
     selfclosingtag('code_block',
                    {text = cmark.node_get_string_content(node)})
  end

  function W.html(node)
     W.out(cmark.node_get_string_content(node))
  end

  W.begin_paragraph = opentag('p')

  W.end_paragraph = closetag('p')

  function W.begin_header(node)
     local level = cmark.node_get_header_level(node)
     opentag('h' .. level)(node)
  end

  function W.end_header(node)
     local level = cmark.node_get_header_level(node)
     closetag('h' .. level)(node)
  end

  W.hrule = selfclosingtag('hr')

  function W.text(node)
     W.out(escape(cmark.node_get_string_content(node)))
  end

  W.softbreak = function(node)
     W.out('\n')
  end

  W.linebreak = function(node)
     W.out('<br />')
  end

  function W.inline_code(node)
     selfclosingtag('inline_code',
                    {text = cmark.node_get_string_content(node)})(node)
  end

  function W.inline_html(node)
     selfclosingtag('inline_html',
                    {text = cmark.node_get_string_content(node)})(node)
  end

  W.begin_emph = opentag('em')

  W.end_emph = closetag('em')

  W.begin_strong = opentag('strong')

  W.end_strong = closetag('strong')

  function W.begin_link(node)
     local attrs = {}
     local title = cmark.node_get_title(node)
     if #title > 0 then
        attrs.title = title
     end
     attrs.href = cmark.node_get_url(node)
     opentag('link', attrs)(node)
  end

  W.end_link = closetag('a')

  function W.begin_image(node)
     W.store()
  end

  function W.end_image(node)
     local attrs = {}
     attrs.alt = string.gsub(W.recall(), '[<][^>]*[>]', '')
     local title = cmark.node_get_title(node)
     if #title > 0 then
        attrs.title = title
     end
     attrs.src   = cmark.node_get_url(node)
     selfclosingtag('img', attrs)(node)
  end

  return W

end

return M

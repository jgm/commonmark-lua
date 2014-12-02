#!/usr/bin/env luajit

local ffi = require("ffi")

local c = ffi.load("libcmark")

ffi.cdef[[

      typedef enum {
         /* Block */
         CMARK_NODE_DOCUMENT,
         CMARK_NODE_BLOCK_QUOTE,
         CMARK_NODE_LIST,
         CMARK_NODE_LIST_ITEM,
         CMARK_NODE_CODE_BLOCK,
         CMARK_NODE_HTML,
         CMARK_NODE_PARAGRAPH,
         CMARK_NODE_HEADER,
         CMARK_NODE_HRULE,
         CMARK_NODE_REFERENCE_DEF,

         CMARK_NODE_FIRST_BLOCK = CMARK_NODE_DOCUMENT,
         CMARK_NODE_LAST_BLOCK  = CMARK_NODE_REFERENCE_DEF,

         /* Inline */
         CMARK_NODE_TEXT,
         CMARK_NODE_SOFTBREAK,
         CMARK_NODE_LINEBREAK,
         CMARK_NODE_INLINE_CODE,
         CMARK_NODE_INLINE_HTML,
         CMARK_NODE_EMPH,
         CMARK_NODE_STRONG,
         CMARK_NODE_LINK,
         CMARK_NODE_IMAGE,

         CMARK_NODE_FIRST_INLINE = CMARK_NODE_TEXT,
         CMARK_NODE_LAST_INLINE  = CMARK_NODE_IMAGE,
                   } cmark_node_type;

      typedef enum {
         CMARK_NO_LIST,
         CMARK_BULLET_LIST,
         CMARK_ORDERED_LIST
                   }  cmark_list_type;

      typedef enum {
         CMARK_PERIOD_DELIM,
         CMARK_PAREN_DELIM
                   } cmark_delim_type;

      typedef struct cmark_node cmark_node;
      typedef struct cmark_parser cmark_parser;

      char *cmark_markdown_to_html(const char *text, int len);
      cmark_node* cmark_node_new(cmark_node_type type);
      void cmark_node_free(cmark_node *node);
      cmark_node* cmark_node_next(cmark_node *node);
      cmark_node* cmark_node_previous(cmark_node *node);
      cmark_node* cmark_node_parent(cmark_node *node);
      cmark_node* cmark_node_first_child(cmark_node *node);
      cmark_node* cmark_node_last_child(cmark_node *node);
      cmark_node_type cmark_node_get_type(cmark_node *node);
      const char* cmark_node_get_string_content(cmark_node *node);
      int cmark_node_set_string_content(cmark_node *node, const char *content);
      int cmark_node_get_header_level(cmark_node *node);
      int cmark_node_set_header_level(cmark_node *node, int level);
      cmark_list_type cmark_node_get_list_type(cmark_node *node);
      int cmark_node_set_list_type(cmark_node *node, cmark_list_type type);
      int cmark_node_get_list_start(cmark_node *node);
      int cmark_node_set_list_start(cmark_node *node, int start);
      int cmark_node_get_list_tight(cmark_node *node);
      int cmark_node_set_list_tight(cmark_node *node, int tight);
      const char* cmark_node_get_fence_info(cmark_node *node);
      int cmark_node_set_fence_info(cmark_node *node, const char *info);
      const char* cmark_node_get_url(cmark_node *node);
      int cmark_node_set_url(cmark_node *node, const char *url);
      const char* cmark_node_get_title(cmark_node *node);
      int cmark_node_set_title(cmark_node *node, const char *title);
      int cmark_node_get_start_line(cmark_node *node);
      int cmark_node_get_start_column(cmark_node *node);
      int cmark_node_get_end_line(cmark_node *node);
      void cmark_node_unlink(cmark_node *node);
      int cmark_node_insert_before(cmark_node *node, cmark_node *sibling);
      int cmark_node_insert_after(cmark_node *node, cmark_node *sibling);
      int cmark_node_prepend_child(cmark_node *node, cmark_node *child);
      int cmark_node_append_child(cmark_node *node, cmark_node *child);
      cmark_parser *cmark_parser_new();
      void cmark_parser_free(cmark_parser *parser);
      cmark_node *cmark_parser_finish(cmark_parser *parser);
      void cmark_parser_feed(cmark_parser *parser, const char *buffer, size_t len);
      cmark_node *cmark_parse_document(const char *buffer, size_t len);
      char *cmark_render_ast(cmark_node *root);
      char *cmark_render_html(cmark_node *root);
]]

local cmark = {}

cmark.DOCUMENT      = c.CMARK_NODE_DOCUMENT
cmark.BLOCK_QUOTE   = c.CMARK_NODE_BLOCK_QUOTE
cmark.LIST          = c.CMARK_NODE_LIST
cmark.LIST_ITEM     = c.CMARK_NODE_LIST_ITEM
cmark.CODE_BLOCK    = c.CMARK_NODE_CODE_BLOCK
cmark.HTML          = c.CMARK_NODE_HTML
cmark.PARAGRAPH     = c.CMARK_NODE_PARAGRAPH
cmark.HEADER        = c.CMARK_NODE_HEADER
cmark.HRULE         = c.CMARK_NODE_HRULE
cmark.REFERENCE_DEF = c.CMARK_NODE_REFERENCE_DEF
cmark.TEXT          = c.CMARK_NODE_TEXT
cmark.SOFTBREAK     = c.CMARK_NODE_SOFTBREAK
cmark.LINEBREAK     = c.CMARK_NODE_LINEBREAK
cmark.INLINE_CODE   = c.CMARK_NODE_INLINE_CODE
cmark.INLINE_HTML   = c.CMARK_NODE_INLINE_HTML
cmark.EMPH          = c.CMARK_NODE_EMPH
cmark.STRONG        = c.CMARK_NODE_STRONG
cmark.LINK          = c.CMARK_NODE_LINK
cmark.IMAGE         = c.CMARK_NODE_IMAGE
cmark.NO_LIST       = c.CMARK_NO_LIST
cmark.BULLET_LIST   = c.CMARK_BULLET_LIST
cmark.ORDERED_LIST  = c.CMARK_ORDERED_LIST
cmark.PERIOD_DELIM  = c.CMARK_PERIOD_DELIM
cmark.PAREN_DELIM   = c.CMARK_PAREN_DELIM
cmark.markdown_to_html = c.cmark_markdown_to_html
cmark.node_new = c.cmark_node_new
cmark.node_free = c.cmark_node_free
cmark.node_next = c.cmark_node_next
cmark.node_previous = c.cmark_node_previous
cmark.node_parent = c.cmark_node_parent
cmark.node_first_child = c.cmark_node_first_child
cmark.node_last_child = c.cmark_node_last_child
cmark.node_get_type = c.cmark_node_get_type
cmark.node_get_string_content = c.cmark_node_get_string_content
cmark.node_set_string_content = c.cmark_node_set_string_content
cmark.node_get_header_level = c.cmark_node_get_header_level
cmark.node_set_header_level = c.cmark_node_set_header_level
cmark.node_get_list_type = c.cmark_node_get_list_type
cmark.node_set_list_type = c.cmark_node_set_list_type
cmark.node_get_list_start = c.cmark_node_get_list_start
cmark.node_set_list_start = c.cmark_node_set_list_start
cmark.node_get_list_tight = c.cmark_node_get_list_tight
cmark.node_set_list_tight = c.cmark_node_set_list_tight
cmark.node_get_fence_info = c.cmark_node_get_fence_info
cmark.node_set_fence_info = c.cmark_node_set_fence_info
cmark.node_get_url = c.cmark_node_get_url
cmark.node_set_url = c.cmark_node_set_url
cmark.node_get_title = c.cmark_node_get_title
cmark.node_set_title = c.cmark_node_set_title
cmark.node_get_start_line = c.cmark_node_get_start_line
cmark.node_get_start_column = c.cmark_node_get_start_column
cmark.node_get_end_line = c.cmark_node_get_end_line
cmark.node_unlink = c.cmark_node_unlink
cmark.node_insert_before = c.cmark_node_insert_before
cmark.node_insert_after = c.cmark_node_insert_after
cmark.node_prepend_child = c.cmark_node_prepend_child
cmark.node_append_child = c.cmark_node_append_child
cmark.parser_new = c.cmark_parser_new
cmark.parser_free = c.cmark_parser_free
cmark.parser_finish = c.cmark_parser_finish
cmark.parser_feed = c.cmark_parser_feed
cmark.parse_document = c.cmark_parse_document
cmark.render_ast = c.cmark_render_ast
cmark.render_html = c.cmark_render_html

local walk_ast = function(cur)
   level = 0
   while cur ~= nil do
      coroutine.yield(cur, level)
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

cmark.walk = function(cur)
   local co = coroutine.create(function() walk_ast(cur) end)
   return function()  -- iterator
      local status, res, level = coroutine.resume(co)
      return res, level
   end
end

return cmark

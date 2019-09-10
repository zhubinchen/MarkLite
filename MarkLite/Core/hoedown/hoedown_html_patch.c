//
//  hoedown_html_patch.c
//  MacDown
//
//  Created by Tzu-ping Chung  on 14/06/2014.
//  Copyright (c) 2014 Tzu-ping Chung . All rights reserved.
//

#include <string.h>
#include "escape.h"
#include "document.h"
#include "html.h"
#include "hoedown_html_patch.h"

#define USE_XHTML(opt) (opt->flags & HOEDOWN_HTML_USE_XHTML)
#define USE_TASK_LIST(opt) (opt->flags & HOEDOWN_HTML_USE_TASK_LIST)

// Supports task list syntax if HOEDOWN_HTML_USE_TASK_LIST is on.
// Implementation based on hoextdown.
void hoedown_patch_render_listitem(
    hoedown_buffer *ob, const hoedown_buffer *text, hoedown_list_flags flags,
    const hoedown_renderer_data *data)
{
	if (text)
    {
        hoedown_html_renderer_state *state = data->opaque;
        size_t offset = 0;
        if (flags & HOEDOWN_LI_BLOCK)
            offset = 3;

        // Do task list checkbox ([x] or [ ]).
        if (USE_TASK_LIST(state) && text->size >= 3)
        {
            if (strncmp((char *)(text->data + offset), "[ ]", 3) == 0)
            {
                HOEDOWN_BUFPUTSL(ob, "<li class=\"task-list-item\">");
                hoedown_buffer_put(ob, text->data, offset);
                if (USE_XHTML(state))
                    HOEDOWN_BUFPUTSL(ob, "<input type=\"checkbox\" />");
                else
                    HOEDOWN_BUFPUTSL(ob, "<input type=\"checkbox\">");
				offset += 3;
            }
            else if (strncmp((char *)(text->data + offset), "[x]", 3) == 0)
            {
                HOEDOWN_BUFPUTSL(ob, "<li class=\"task-list-item\">");
                hoedown_buffer_put(ob, text->data, offset);
                if (USE_XHTML(state))
                    HOEDOWN_BUFPUTSL(ob, "<input type=\"checkbox\" checked />");
                else
                    HOEDOWN_BUFPUTSL(ob, "<input type=\"checkbox\" checked>");
				offset += 3;
            }
            else
            {
                HOEDOWN_BUFPUTSL(ob, "<li>");
                offset = 0;
            }
        }
        else
        {
            HOEDOWN_BUFPUTSL(ob, "<li>");
            offset = 0;
        }
		size_t size = text->size;
		while (size && text->data[size - offset - 1] == '\n')
			size--;

		hoedown_buffer_put(ob, text->data + offset, size - offset);
	}
	HOEDOWN_BUFPUTSL(ob, "</li>\n");
}

// Adds a "toc" class to the outmost UL element to support TOC styling.
void hoedown_patch_render_toc_header(
    hoedown_buffer *ob, const hoedown_buffer *content, int level,
    const hoedown_renderer_data *data)
{
    hoedown_html_renderer_state *state = data->opaque;

    if (level <= state->toc_data.nesting_level) {
        /* set the level offset if this is the first header
         * we're parsing for the document */
        if (state->toc_data.current_level == 0)
            state->toc_data.level_offset = level - 1;

        level -= state->toc_data.level_offset;

        if (level > state->toc_data.current_level) {
            while (level > state->toc_data.current_level) {
                if (state->toc_data.current_level == 0)
                    HOEDOWN_BUFPUTSL(ob, "<ul class=\"toc\">\n<li>\n");
                else
                    HOEDOWN_BUFPUTSL(ob, "<ul>\n<li>\n");
                state->toc_data.current_level++;
            }
        } else if (level < state->toc_data.current_level) {
            HOEDOWN_BUFPUTSL(ob, "</li>\n");
            while (level < state->toc_data.current_level) {
                HOEDOWN_BUFPUTSL(ob, "</ul>\n</li>\n");
                state->toc_data.current_level--;
            }
            HOEDOWN_BUFPUTSL(ob,"<li>\n");
        } else {
            HOEDOWN_BUFPUTSL(ob,"</li>\n<li>\n");
        }

        hoedown_buffer_printf(ob, "<a href=\"#toc_%d\">", state->toc_data.header_count++);
        if (content) hoedown_buffer_put(ob, content->data, content->size);
        HOEDOWN_BUFPUTSL(ob, "</a>\n");
    }
}

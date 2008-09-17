#include <stdio.h>
#include <ctype.h>

#include "lua.h"
#include "lauxlib.h"

#include "markdown.h"

/* copied from mkdio.h */
/* special flags for markdown() and mkd_text()
 */
#define MKD_NOLINKS	0x0001	/* don't do link processing, block <a> tags  */
#define MKD_NOIMAGE	0x0002	/* don't do image processing, block <img> */
#define MKD_NOPANTS	0x0004	/* don't run smartypants() */
#define MKD_NOHTML	0x0008	/* don't allow raw html through AT ALL */
#define MKD_TAGTEXT	0x0020	/* don't expand `_` and `*` */
#define MKD_NO_EXT	0x0040	/* don't allow pseudo-protocols */
#define MKD_CDATA	0x0080	/* generate code for xml ![CDATA[...]] */
#define MKD_EMBED	MKD_NOLINKS|MKD_NOIMAGE|MKD_TAGTEXT

/* special flags for mkd_in() and mkd_string()
 */
#define MKD_NOHEADER	0x0100	/* don't process header blocks */
#define MKD_TABSTOP	0x0200	/* expand tabs to 4 spaces */

static const char *const discount_opts[] = {
  "nolinks",
  "noimages",
  "nopants",
  "nohtml",
  "tagtext",
  "noext",
  "cdata",
  "embed",
  NULL
};

static const int discount_opts_codes[] = {
  MKD_NOLINKS,
  MKD_NOIMAGE,
  MKD_NOPANTS,
  MKD_NOHTML,
  MKD_TAGTEXT,
  MKD_NO_EXT,
  MKD_CDATA,
  MKD_EMBED
};

/* routines duplicated from markdown source without filesystem access */

/* write output in XML format */
static void local___mkd_xml(char *p, int size, luaL_Buffer *b) {
  char c;

  while (size-- > 0) {
    if (!isascii(c = *p++))
      continue;
    switch (c) {
      case '<': luaL_addlstring(b, "&lt;", 4);   break;
      case '>': luaL_addlstring(b, "&gt;", 4);   break;
      case '&': luaL_addlstring(b, "&amp;", 5);  break;
      case '"': luaL_addlstring(b, "&quot;", 6); break;
      case '\'':luaL_addlstring(b, "&apos;", 6); break;
      default:  luaL_addchar(b, c);
    }
  }
}

/* write the html to a buffer (xmlified if necessary) */
static int local_mkd_generatehtml(Document *p, luaL_Buffer *b) {
  char *doc;
  int szdoc;

  if ((szdoc = mkd_document(p, &doc)) != EOF) {
    if (p->ctx->flags & CDATA_OUTPUT)
      local___mkd_xml(doc, szdoc, b);
    else
      luaL_addlstring(b, doc, szdoc);
    luaL_addchar(b, '\n');
    return 0;
  }
  return -1;
}

/* convert some markdown text to html. */
static int local_markdown(Document *document, luaL_Buffer *b, int flags) {
  if (mkd_compile(document, flags)) {
    local_mkd_generatehtml(document, b);
    mkd_cleanup(document);
    return 0;
  }
  return -1;
}

static int ldiscount(lua_State *L) {
  size_t len;
  const char *str = luaL_checklstring(L, 1, &len);
  int flags = 0;
  int num_args = lua_gettop(L);
  luaL_Buffer b;
  Document *doc;
  int ret, i;

  for (i = 2; i <= num_args; i++) {
    int opt_index = luaL_checkoption(L, i, NULL, discount_opts);
    flags |= discount_opts_codes[opt_index];
  }

  luaL_buffinit(L, &b);
  doc = mkd_string(str, len, MKD_TABSTOP|MKD_NOHEADER);
  ret = local_markdown(doc, &b, flags);
  luaL_pushresult(&b);
  if (ret < 0)
    return luaL_error(L, "error in markdown conversion");
  return 1;
}

LUALIB_API int luaopen_discount(lua_State *L) {
  lua_pushcfunction(L, ldiscount);
  return 1;
}

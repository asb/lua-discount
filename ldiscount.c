#if defined(HAVE_FOPENCOOKIE)
#  define _GNU_SOURCE
#endif

#include <stdio.h>

#include "lua.h"
#include "lauxlib.h"

#include "mkdio.h"

static int fakehandle_write(void *cookie, const char *data, int len) {
  luaL_Buffer *b = (luaL_Buffer*)cookie;
  luaL_addlstring(b, data, len);
  return len;
}

#if defined(HAVE_FOPENCOOKIE)
static cookie_io_functions_t fakehandle_functions = {
  (cookie_read_function_t*)NULL,
  (cookie_write_function_t*)fakehandle_write,
  (cookie_seek_function_t*)NULL,
  (cookie_close_function_t*)NULL
};
#endif

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

static int ldiscount(lua_State *L) {
  size_t len;
  const char *str = luaL_checklstring(L, 1, &len);
  int flags = 0;
  int num_args = lua_gettop(L);
  FILE *fh;
  int i;
  for (i = 2; i <= num_args; i++) {
    int opt_index = luaL_checkoption(L, i, NULL, discount_opts);
    flags |= discount_opts_codes[opt_index];
  }

  luaL_Buffer b;
  luaL_buffinit(L, &b);

#if defined(HAVE_FOPENCOOKIE)
  fh = fopencookie((void*)&b, "w", fakehandle_functions);
#else
  fh = funopen((void*)&b, NULL, fakehandle_write, NULL, NULL);
#endif

  MMIOT *doc = mkd_string(str, len, MKD_TABSTOP|MKD_NOHEADER);
  int ret = markdown(doc, fh, flags);
  fclose(fh);
  luaL_pushresult(&b);
  if (ret < 0)
    return luaL_error(L, "error in markdown conversion");
  return 1;
}

int luaopen_discount(lua_State *L) {
  lua_pushcfunction(L, ldiscount);
  return 1;
}

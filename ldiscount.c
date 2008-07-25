#define _GNU_SOURCE

#include <stdio.h>

#include "lua.h"
#include "lauxlib.h"

#include "mkdio.h"

static int fakehandle_write(void *cookie, const char *data, int len) {
  luaL_Buffer *b = (luaL_Buffer*)cookie;
  luaL_addlstring(b, data, len);
  return len;
}

static cookie_io_functions_t fakehandle_functions = {
  (cookie_read_function_t*)NULL,
  (cookie_write_function_t*)fakehandle_write,
  (cookie_seek_function_t*)NULL,
  (cookie_close_function_t*)NULL
};

static int ldiscount(lua_State *L) {
  size_t len;
  const char *str = luaL_checklstring(L, 1, &len);
  int flags = MKD_TABSTOP | MKD_NOHEADER;

  luaL_Buffer b;
  luaL_buffinit(L, &b);

  FILE *fh = fopencookie((void*)&b, "w", fakehandle_functions);

  MMIOT *doc = mkd_string(str, len, flags);
  int ret = markdown(doc, fh, flags);
  fclose(fh);
  if (ret < 0)
    return luaL_error(L, "error in markdown conversion");
  luaL_pushresult(&b);
  return 1;
}

int luaopen_discount(lua_State *L) {
  lua_pushcfunction(L, ldiscount);
  return 1;
}

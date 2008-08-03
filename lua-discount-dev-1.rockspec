package="lua-discount"
version="dev-1"
source = {
   url = ""
}
description = {
   summary = "Binding to a fast C implementation of the Markdown text-to-html markup system",
   homepage = "http://asbradbury.org/projects/lua-discount/",
   license = "BSD"
}
supported_platforms = {"unix"}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      discount = {
         "docheader.c",
         "dumptree.c",
         "generate.c",
         "markdown.c",
         "mkdio.c",
         "resource.c",
         "ldiscount.c"
      }
   },
   platforms = {
      linux = {
         modules = {
            discount = {
               defines = {"HAVE_FOPENCOOKIE"}
            }
         }
      }
   }
}

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
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      discount = {
         "basename.c",
         "Csio.c",
         "css.c",
         "docheader.c",
         "dumptree.c",
         "emmatch.c",
         "generate.c",
         "markdown.c",
         "mkdio.c",
         "resource.c",
         "toc.c",
         "xml.c",
         "ldiscount.c"
      }
   },
   platforms = {
      windows = {
         modules = {
            discount = {
               defines = {"WINDOWS"}
            }
         }
      }
   }
}

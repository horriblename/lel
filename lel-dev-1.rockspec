package = "lel"
version = "dev-1"
source = {
   url = "https://github.com/horriblename"
}
description = {
   homepage = "https://github.com/horriblename",
   license = "MIT"
}
dependencies = { "lgi", "lua >= 5.1" }
build = {
   type = "builtin",
   modules = {
      lel = "lel/init.lua",
      ['lel.app'] = "lel/app.lua",
   }
}

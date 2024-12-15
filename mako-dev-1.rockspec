rockspec_format = "3.0"
package = "mako"
version = "dev-1"
source = {
  url = "git+https://github.com/mtdowling/mako.git",
  branch = "main",
}
description = {
  summary = "Task reactor for Lua and Teal, used to schedule and run tasks",
  detailed = [[
    * Designed to work with Love 2D, but can work with any event loop.
    * Schedule functions to run after a delay.
    * Schedule functions to run at a fixed interval.
    * Schedule and run coroutines.
    * Schedule tasks that run until they decide to stop.
    * Can explicitly remove tasks.
    ]],
  homepage = "https://github.com/mtdowling/mako",
  license = "MIT <http://opensource.org/licenses/MIT>",
}
dependencies = {
  "lua >= 5.1",
}
test_dependencies = {
  "busted",
  --"busted-tl",
}
build_dependencies = {
  "tl >= 0.24.1",
  "cyan >= 0.4.0",
  "luacheck >= 0.2.0",
}
test = {
  type = "busted",
  flags = {
    "--loaders=teal",
  },
}
build = {
  type = "builtin",
  modules = {
    mako = "src/mako.lua",
  },
  install = {
    lua = {
      mako = "src/mako.tl",
    },
  },
}
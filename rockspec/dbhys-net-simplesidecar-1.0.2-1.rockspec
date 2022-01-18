package = "dbhys-net-simplesidecar"
version = "1.0.2-1"
supported_platforms = {"linux", "macosx"}
source = {
   url = "file:///usr/local/sidecar/src/init.lua",
}
description = {
   summary = "dbhys-net-simplesidecar is a simple sidecar",
   detailed = [[
      DBHYS net-simplesidecar is a simple sidecar, can be used for record access log,
      traffic migration, app oauth, monitor etc.
   ]],
   homepage = "https://github.com/dbhys/net-simplesidecar.git",
   issues = "https://github.com/dbhys/net-simplesidecar/issues",
   labels = { "sidecar", "traffic migration", "openresty", "oidc", "apm" },
   maintainer = "dbhys<official@dbhys.com>",
   license = "MIT/X11",
}
dependencies = {
    "luafilesystem = 1.8.0-1",
    "penlight = 1.12.0-1",
    "jsonschema = 0.9.6-0",
    "api7-lua-tinyyaml = 0.4.2-0",
    "dbhys-openresty-skywalking = 0.1.0-1",
    "lua-resty-openidc = 1.7.5-1",
}
build = {
   type = "none"
}
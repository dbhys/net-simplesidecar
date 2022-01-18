local pl_stringio = require "pl.stringio"
local pl_file = require "pl.file"
local pl_config = require "pl.config"

local runtime_config = require "sidecar.config"

local sidecar = {
}


function sidecar.init()
    print(runtime_config.default_upstream_ip)
    local ok, err = runtime_config.load()
    if not ok then
        ngx.log(ngx.ERR, "config load failed: ", err)
        ngx.exit(1)
    end

    -- ngx.INFO won't work in init_by_lua_block
    ngx.log(ngx.WARN, "init complete")
end

function sidecar.access()
    ngx.var.upstream_host =  runtime_config.config.ntm.upstream_ip .. ":" .. runtime_config.config.ntm.upstream_port
end


function sidecar.config_reload()
    return runtime_config.reload()
end

function sidecar.config()
    return runtime_config.config_raw
end

function sidecar.is_admin(admin_secret)
    if not runtime_config.config.admin_secret then
        return true
    end
    return admin_secret == runtime_config.config.admin_secret
end

return sidecar


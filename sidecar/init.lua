local pl_stringio = require "pl.stringio"
local pl_file = require "pl.file"
local pl_config = require "pl.config"

local tool = require "sidecar.tool"
local runtime_config = require "sidecar.config"
local rs_verifier = require "sidecar.rs_verifier"

local sidecar = {
}

function sidecar.init()
    local ok, err = runtime_config.load()
    if not ok then
        ngx.log(ngx.ERR, "config load failed: ", err)
        ngx.exit(1)
    end

    rs_verifier.init()
    -- ngx.INFO won't work in init_by_lua_block
    ngx.log(ngx.WARN, "init complete")
end

function sidecar.access()
    local _, err = rs_verifier.verify()
    if err ~= nil then
        ngx.log(ngx.ERR, "verify failed: ", err)
        tool.simple_response(ngx.HTTP_FORBIDDEN, err)
        return
    end

    ngx.var.upstream_host =  runtime_config.config.ntm.upstream_ip .. ":" .. runtime_config.config.ntm.upstream_port
end


function sidecar.config_reload()
    return runtime_config.reload()
end

function sidecar.config_raw()
    return runtime_config.config
end

function sidecar.config_raw()
    return runtime_config.config_raw
end

function sidecar.is_admin(admin_secret)
    if not runtime_config.config.admin_secret then
        return true
    end
    return admin_secret == runtime_config.config.admin_secret
end

return sidecar


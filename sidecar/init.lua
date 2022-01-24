local pl_stringio = require "pl.stringio"
local pl_file = require "pl.file"
local pl_config = require "pl.config"

local tool = require "sidecar.tool"
local runtime_config = require "sidecar.config"
local rs_verifier = require "sidecar.rs_verifier"
local apm = require "sidecar.apm"

local sidecar = {
}

function sidecar.init()
    local ok, err = runtime_config.load()
    if not ok then
        ngx.log(ngx.ERR, "config load failed: ", err)
        ngx.exit(1)
    end
    apm.init()
    -- ngx.INFO won't work in init_by_lua_block
    ngx.log(ngx.WARN, "init complete")
end

function sidecar.init_worker()
    local ok, err = ngx.timer.at(2, do_worker_init)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
end

function do_worker_init(premature)
    if premature then
        return
    end
    -- Notice: if client register failed, nginx won not exit, just print error logs.
    apm.init_worker()
    rs_verifier.init_worker()
end


function sidecar.access()
    -- if the config is reload, reread config from shared dict
    local config
    if not runtime_config.is_latest_config() then
        config = runtime_config.load_and_parse()
        do_worker_init()
    else
        config = runtime_config.config()
    end

    if config then
        -- we can read it from ctx within a request
        ngx.ctx.config = config
    end
    
    if apm.status().enable then
        apm.tracer.start(ngx.var.request_uri)
    end
    if rs_verifier.status().enable then
        local _, err = rs_verifier.verify()
        if err ~= nil then
            ngx.log(ngx.ERR, "verify failed: ", err)
            tool.simple_response(ngx.HTTP_FORBIDDEN, err)
            return
        end
    end

    ngx.var.upstream_host =  config.proxy.upstream_ip .. ":" .. config.proxy.upstream_port
end

function sidecar.body_filter()
    if apm.status().enable and ngx.arg[2] then
        apm.tracer.finish()
    end
end

function sidecar.log()
    if apm.status().enable then
        apm.tracer.prepareForReport()
    end
end

function sidecar.status(plugin)
    local res
    if plugin == "rs_verifier" then
        res = rs_verifier.status()
    elseif plugin == "apm" then
        res = apm.status()
    else
        res = "{\"error\": \"no this plugin!\"}"
    end
    return res
end

function sidecar.config_reload()
    return runtime_config.reload()
end

function sidecar.config_str()
    return runtime_config.config_str()
end

function sidecar.is_admin(admin_secret)
    local config = runtime_config.config()
    if not config.admin_secret then
        return true
    end
    return admin_secret == config.admin_secret
end

return sidecar


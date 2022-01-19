local cjson = require "cjson.safe"
function object2string(obj)
    return cjson.encode(obj)

end

function simple_response(status_code, content, config)
    ngx.log(ngx.INFO, "Sidecar response directly")

    if ngx.ctx.delay_response and not ctx.delayed_response then
        ngx.ctx.delayed_response = {
            status_code = status_code,
            content = content,
            headers = config.headers,
        }

        coroutine.yield()
    end

    if not content then
        if not content then
            content = "Unknown"
        end
    end

    ngx.status = status_code
    ngx.header["Content-Type"] = "application/json; charset=utf-8"
    ngx.header["Server"] = "Sidecar-Response-Directly"

    if config.headers then
        for k, v in pairs(config.headers) do
            ngx.header[k] = v
        end
    end

    local encoded, err = cjson.encode(type(content) == "table" and content or
            {message = content})
    if err then
        ngx.log(ngx.ERR, "could not encode message: " .. content, err)
        encoded = "could not encode content, please check the log"
    end

    if status_code ~= _M.status_codes.HTTP_OK then
        ngx.log(ngx.ERR, "status: ", status_code, ", message: ", encoded)
    end
    ngx.say(encoded)
    return ngx.exit(status_code)
end
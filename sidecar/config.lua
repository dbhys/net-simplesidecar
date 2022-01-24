local pl_file       = require("pl.file")
local jsonschema    = require("jsonschema")
local yaml          = require("tinyyaml")
local json          = require("cjson.safe")

local default_upstream_ip = "127.0.0.1"

local config_schema = {
    type = "object",
    properties = {
        admin_secret = {
            type = "string"
        },
        proxy = {
            type = "object",
            properties = {
                listen_port = {
                    type = "integer",
                    minimum = 10,
                    maximum = 65535
                },
                upstream_ip = {
                    type = "string",
                    format = "ipv4, hostname"
                },
                upstream_port = {
                    type = "integer",
                    minimum = 10,
                    maximum = 65535
                },
                oidc_rs_verifier = {
                    type = "object",
                    properties = {
                        enable = {
                            type = "boolean",
                        },
                        issuer = {
                            type = "string",
                        },
                        well_known_uri = {
                            type = "string",
                        },
                        token_header_name = {
                            type = "string",
                        },
                        checkers = {
                            type = "array",
                            minItems = 1,
                            items = {
                                checker = {
                                    type = "object",
                                    required = {"route"},
                                    properties = {
                                        route = {
                                            type = "string",
                                            minLength = 1
                                        },
                                        anyOf = {
                                            scope = {
                                                type = "string",
                                            },
                                            referrer = {
                                                type = "boolean",
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
            
                    },
                    required = {"issuer", "checkers"},
                },

            },
            required = {"upstream_port"},

        },
        apm = {
            type = "object",
            properties = {
                enable = {
                    type = "boolean"
                },
                collector_url = {
                    type = "string"
                },
                instance_name = {
                    type = "string"
                },
                client_id = {
                    type = "string"
                },
                client_secret = {
                    type = "string"
                }, 
            },
            required = {"enable", "collector_url", "client_id"},
        },
        required = {"proxy"}

    }

}
local shared_config_name = "config"
local shared_config_version = "config_version"
local worker_version = 0
local shared_config = ngx.shared.sidecar_config

local _M = {
    _path = "config/config.yaml",
    config_validator = nil,
}

function _M._init()
    local validator = jsonschema.generate_validator(config_schema)
    if validator == nil then
        return "error for generate validator, config_schema is invalid"
    end
    _M.config_validator = validator
end

function _M.parse(config_yaml)
    local config = yaml.parse(config_yaml)
    if not config then
        return nil, "failed to parse the content: " .. config_yaml
    end
    return config, nil
end

function _M.check(config_json)
    return _M.config_validator(config_json)
end

function _M.load()
    local err = _M._init()
    if err then
        return false, err
    end
    return _M.reload()
end

function _M.reload()
    local config_raw, err = pl_file.read(_M._path)
    if not config_raw or err then
        return false, err
    end

    local config, err = _M.parse(config_raw)
    if err then
        return false, err
    end

    local ok, err = _M.check(config)
    if not ok then
        return ok, err
    end
    if not config.proxy.upstream_ip then
        config.proxy.upstream_ip = default_upstream_ip
    end
    config_str, err = json.encode(config)
    -- actually, it won't happen too
    if err then
        ngx.log(ngx.ERR, "The worst thing happened, config encode err: ", err)
        return false, err
    end

    shared_config:set(shared_config_name, config_str)
    incr_latest_version()
    return true, nil
end

function incr_latest_version()
    local latest_version = _M.latest_version()
    shared_config:set(shared_config_version, latest_version + 1)
end

function _M.latest_version()
    return shared_config:get(shared_config_version) or 0
end

function _M.worker_version()
    return worker_version
end

function _M.is_latest_config()
    return worker_version == _M.latest_version()
end

function _M.config(ctx) 
    return ctx and ctx.config or _M.load_and_parse()
end

function _M.load_and_parse()
    ngx.log(ngx.WARN, "load config from shared dict")
    local config_raw = _M.config_str()
    -- actually, it won't happen, we guarantee that it is not empty when setting
    if not config_raw then
        ngx.log(ngx.ERR, "The worst thing happened, shared config is empty")
        return nil
    end
    local config, err = json.decode(config_raw)
    -- actually, it won't happen too
    if err then
        ngx.log(ngx.ERR, "The worst thing happened, shared config decode err: ", err)
        return nil
    end
    return config
end

function _M.config_str() 
    return shared_config:get(shared_config_name)
end

return _M
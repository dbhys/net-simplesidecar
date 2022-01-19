local pl_file       = require("pl.file")
local jsonschema    = require("jsonschema")
local yaml          = require("tinyyaml")

local default_upstream_ip = "127.0.0.1"

local config_schema = {
    type = "object",
    properties = {
        admin_secret = {
            type = "string"
        },
        ntm = {
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
                        issuer = {
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
                client_id = {
                    type = "string"
                },
                client_secret = {
                    type = "string"
                }, 
            },
            required = {"enable", "collector_url", "client_id"},
        },
        required = {"ntm"}

    }

}

local _M = {
    _path = "config/config.yaml",
    config_validator = nil,
    config = nil,
    config_raw = "",
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
    local f, err = pl_file.read(_M._path)
    if not f or err then
        return false, err
    end

    local config, err = _M.parse(f)
    if err then
        return false, err
    end

    local ok, err = _M.check(config)
    if not ok then
        return ok, err
    end
    if not config.ntm.upstream_ip then
        config.ntm.upstream_ip = default_upstream_ip
    end
    _M.config = config
    _M.config_raw = f
    return true, nil
end

function _M.config() 
    return _M.content
end


return _M
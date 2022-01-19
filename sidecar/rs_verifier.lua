local openidc = require "resty.openidc"
local json = require "cjson.safe"

local runtime_config = require "sidecar.config"

local opts
_M = {
    available = false
}

function _M.init_worker()
    if not runtime_config.config.ntm.oidc_rs_verifier or not runtime_config.config.ntm.oidc_rs_verifier.enable then
        return
    end

    opts = {
        discovery = runtime_config.config.ntm.oidc_rs_verifier.issuer.."/.well-known/openid-configuration",
        timeout = 5,
        jwk_expires_in = 1000,
        discovery_expires_in = 1000,
        system_leeway = 60*60*24,
        token_header_name = runtime_config.config.ntm.oidc_rs_verifier.token_header_name or "",
    }

    ngx.timer.at(0, _M._discovery())
end

function _M._discovery()
    opts.discovery = openidc.get_discovery_doc(opts)
    _M.available = true
end

function _M.verify()
    if not _M.available then
        return nil, "not available"
    end
    opts.discovery = openidc.get_discovery_doc(opts)

    local credential, err = openidc.bearer_jwt_verify(opts)

    if err then
        return nil, err
    end

    local credential_str, _ = json.encode(credential)
    if credential_str then
        ngx.log(ngx.INFO, "credential: ", credential_str)
    end

    if not credential.scope or credential.scope=="" then
        return nil, "invalid scope"
    end
    return credential, nil
end

return _M
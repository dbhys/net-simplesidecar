local openidc = require "resty.openidc"
local json = require "cjson.safe"

local config = require "sidecar.config"

local opts
_M = {
}

function _M:init()
    opts = {
        discovery = config.ntm.oidc_rs_verifier.issuer.."/.well-known/app-oauth-configuration",
        timeout = 5,
        jwk_expires_in = 1000,
        discovery_expires_in = 1000,
        system_leeway = 60*60*24,
        token_header_name = config.ntm.oidc_rs_verifier.token_header_name or "",
    }
end

function _M:verify()
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
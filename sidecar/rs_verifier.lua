local openidc = require "resty.openidc"
local json = require "cjson.safe"

local enum = require "sidecar.enum"
local runtime_config = require "sidecar.config"

local opts

local status = {
	enable = false,
	health = enum.health.RED,
	info = "Unknown"
}

_M = {
}

function _M.status()
    local verifier_config = runtime_config.config().oidc_rs_verifier
    if not verifier_config or not verifier_config.enable then
		status.enable = true
	else	
		status.enable = false
	end
	return {worker_id= ngx.worker.id(), status = status}
end

function _M.init_worker()
    local verifier_config = runtime_config.config().oidc_rs_verifier

    if not verifier_config or not verifier_config.enable then
        return
    end
    local well_known_uri = "/.well-known/openid-configuration"
    if verifier_config.well_known_uri then
        well_known_uri = verifier_config.well_known_uri
    end

    opts = {
        discovery = verifier_config.issuer .. well_known_uri,
        timeout = 5,
        jwk_expires_in = 1000,
        discovery_expires_in = 1000,
        system_leeway = 60*60*24,
        token_header_name = verifier_config.token_header_name or "",
    }

    opts.discovery, err = openidc.get_discovery_doc(opts)
    status.health = (err) and enum.health.RED or enum.health.GREEN
end

function _M.verify()
    if not status.enable then
        return nil, "verifier disabled"
    end
    opts.discovery, err = openidc.get_discovery_doc(opts)

    status.health = (err) and enum.health.RED or enum.health.GREEN

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
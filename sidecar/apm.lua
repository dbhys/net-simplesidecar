local enum = require "sidecar.enum"
local runtime_config = require "sidecar.config"

local _M = {
	tracer = {}
}

local status = {
	enable = false,
	-- TODO do something to check it
	health = enum.health.RED,
	info = "Unknown"
}

local client
local origin_tracer

function _M.init()
	local apm_config = runtime_config.config().apm
	if apm_config and apm_config.enable then
		if not apm_config.client_id or not apm_config.instance_name or not apm_config.collector_url then
			return false, "invalid apm config"
		end
		local metadata_buffer = ngx.shared.tracing_buffer
		metadata_buffer:set('serviceName', apm_config.client_id)
		-- Instance means the number of Nginx deloyment, does not mean the worker instances
		metadata_buffer:set('serviceInstanceName', apm_config.instance_name)
	end
end

function _M.init_worker()
	local apm_config = runtime_config.config().apm
	if apm_config and apm_config.enable then
		origin_tracer = require "skywalking.tracer"
		client = require("skywalking.client")
		client:startBackendTimer(apm_config.collector_url)
	end
end

function _M.status()
	local apm_config = runtime_config.config().apm
	if apm_config and apm_config.enable then
		status.enable = true
	else	
		status.enable = false
	end
	-- TODO do more things to check health
	status.health = status.enable and enum.health.GREEN or enum.health.RED
	return {worker_id= ngx.worker.id(), status = status}
end

function _M.tracer.start(endpoint)
	if origin_tracer then
		origin_tracer:start(endpoint)
	end
end

function _M.tracer.finish()
	origin_tracer:finish()
end

function _M.prepareForReport()
	origin_tracer:prepareForReport()
end

return _M
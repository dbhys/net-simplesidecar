local runtime_config = require "sidecar.config"
local _M = {
	available = false,
	tracer = {}
}
local origin_tracer
function _M.init_worker()
	if runtime_config.config.apm and runtime_config.config.apm.enable then
		if not runtime_config.config.apm.client_id or not runtime_config.config.apm.instance_Name or not runtime_config.config.apm.collector_url then
			return false, "invalid apm config"
		end
		local metadata_buffer = ngx.shared.tracing_buffer
		metadata_buffer:set('serviceName', runtime_config.config.apm.client_id)
		-- Instance means the number of Nginx deloyment, does not mean the worker instances
		metadata_buffer:set('serviceInstanceName', runtime_config.config.apm.instance_Name)
		origin_tracer = require "skywalking.tracer"

		require("skywalking.client"):startBackendTimer(runtime_config.config.apm.collector_url)

		_M.available = true
		return true
	end
end

function _M.tracer.start(endpoint)
	origin_tracer:start(endpoint)
end

function _M.tracer.finish()
	origin_tracer:finish()
end

function _M.prepareForReport()
	origin_tracer:prepareForReport()
end

return _M
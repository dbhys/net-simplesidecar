local config = require "sidecar.config"
local _M = {
	available = false,
	tracer = {}
}
local origin_tracer
function _M.init_worker()
	if config.apm and config.apm.enable then
		if not config.apm.client_id or not config.apm.instance_Name or not config.apm.collector_url then
			return false, "invalid apm config"
		end
		local metadata_buffer = ngx.shared.tracing_buffer
		metadata_buffer:set('serviceName', config.apm.client_id)
		-- Instance means the number of Nginx deloyment, does not mean the worker instances
		metadata_buffer:set('serviceInstanceName', config.apm.instance_Name)
		origin_tracer = require "skywalking.tracer"

		require("skywalking.client"):startBackendTimer(config.apm.collector_url)

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
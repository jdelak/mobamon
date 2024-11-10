-- Thread/post-frame queue library

local singletonThreads = {}

libThread = libThread or {
	threadFunc = function(execFunc)	-- Execute func in a separate thread (useful for independent sequential actions that don't interrupt other lua calls).
		local function funcThread()
			execFunc()
		end
		return newthread(funcThread)
	end,

	fireSingletonThread = function(threadFunc, ...)
		local thread = singletonThreads[threadFunc]
		if (thread and thread:IsValid()) then
			thread:kill()
		end
		singletonThreads[threadFunc] = libThread.threadFunc(function()
			threadFunc(unpack(arg))
		end)
	end,
}
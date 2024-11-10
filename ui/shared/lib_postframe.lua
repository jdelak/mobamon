-- PostFrame actions

libPostFrame = libPostFrame or {
	postFrameQueue = nil,
	postFrameActions = false,
	
	addPostFrameAction = function(actionKey, funcToExec)	-- Add action to post-frame queue
		libPostFrame.postFrameActions = true
		if libPostFrame.postFrameQueue == nil then
			libPostFrame.postFrameQueue = {}
		end
		libPostFrame.postFrameQueue[actionKey] = funcToExec
	end
}

object:RegisterWatchLua(	-- Allows actions to be lumped post all possible triggers in a frame (effectively an everything-sequence trigger.  Also reduces redundant actions that would normally be required for every relevant trigger).
	'EndUpdate',
	function(widget, trigger)
		if libPostFrame.postFrameActions and libPostFrame.postFrameQueue ~= nil then
			libPostFrame.postFrameActions = false
				for key,funcToExec in pairs(libPostFrame.postFrameQueue) do
					funcToExec()
				end
			libPostFrame.postFrameQueue = nil
		end
	end
)
-- Generic way of broadcasting and responding to events that don't require a particular feature to exist.

-- Allows a portion of the UI to respond to events and interaction with a different portion of the UI
-- while still remaining loosely interconnected.


genericEvent = genericEvent or {}

genericEvent.trigger = LuaTrigger.CreateCustomTrigger('genericEvent', {
	{ name	= 'name',		type	= 'string' }
})

function genericEvent.register(widget, event, callback)
	if widget and type(widget) == 'userdata' and widget:IsValid() then
		widget:RegisterWatchLua('genericEvent', function(widget, trigger)
			if trigger.name == event then
				callback()
			end
		end, true)	-- in this case, we kind of need multiple possible callbacks on a widget
	else
		print('Invalid widget for genericEvent.register - '..event..'\n')
	end


end

function genericEvent.broadcast(event)
	if event and type(event) == 'string' and string.len(event) > 0 then
		genericEvent.trigger.name = event
		genericEvent.trigger:Trigger(true)
	end
end
-- (C)2013 S2 Games
-- main.lua
--
-- Main Lua initialization
--=============================================================================

function TestCustomCommand(s)
	print("TestCustomCommand " .. s .. "\n")
end
ConsoleRegistry.Register("TestCustomCommand", TestCustomCommand, 1)

function TestCustomAction(button, axis, value, delta, cursorX, cursorY, param)
	print("TestCustomAction " .. button .. " " .. value .. " " .. delta .. "\n")
end
ActionRegistry.Register("TestCustomAction", "button", TestCustomAction, true)

function DebugFriendListUpdates()
	local function watch(s)
		WatchLuaTrigger(s, function() Cmd("LuaTriggerShowParams " .. s) end)
	end

	watch("FriendListEvent")
	watch("IgnoredList")
	watch("FriendListOnline")
	watch("FriendListOffline")
	watch("FriendListGame")
end
ConsoleRegistry.Register("DebugFriendListUpdates", DebugFriendListUpdates, 0)

function PrintAllMonitorRects()
	printr(System.GetAllMonitorRects())
end
ConsoleRegistry.Register("PrintAllMonitorRects", PrintAllMonitorRects, 0)

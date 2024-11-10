mainUI = mainUI or {}
Windows = Windows or {}
Windows.state = {}
Windows.state.BiggieMapVisible = false
Windows.state.consoleVisible = false

local interface = object

local function InitMainControlClient(object)

	UnwatchLuaTriggerByKey('GamePhase', 'WindowControlGamePhase')
	WatchLuaTrigger('GamePhase', function(trigger)
		if (trigger.gamePhase >= 4) and GetCvarBool('ui_multiWindowShenanigans') then					
			if (Windows.BiggieMap) then
				Windows.BiggieMap:Restore()
				Windows.state.BiggieMapVisible = true
			else
				Windows.SpawnBiggieMap()			
			end		
		else
			Windows.state.BiggieMapVisible = false
			if (Windows.BiggieMap) then
				Windows.BiggieMap:Hide()	
			end			
		end
	end, 'WindowControlGamePhase')

	function Windows.SpawnBiggieMap()
		if (Windows.BiggieMap) then
			Windows.BiggieMap:Restore()	
			Windows.state.BiggieMapVisible = true
		else
			local width = interface:GetWidthFromString('90h')
			local height = interface:GetHeightFromString('90h')
			Windows.BiggieMap = Windows.BiggieMap or Window.New(
				0,
				0,
				width,
				height,
				{
					Window.BORDERLESS,
					Window.THREADED,
					Window.COMPOSITE,
					-- Window.RESIZABLE,
					Window.CENTER,
				},
				"/ui_dev/biggie_map.interface",
				"Strife BiggieMap"
			)
			Windows.state.BiggieMapVisible = true
		end
	end	
	
	function Windows.ToggleBiggieMap()
		if Windows.state.BiggieMapVisible then
			Windows.state.BiggieMapVisible = false
			if (Windows.BiggieMap) then
				Windows.BiggieMap:Hide()	
			end			
		else
			Windows.state.BiggieMapVisible = true
			Windows.SpawnBiggieMap()
		end
	end		
	
end

if GetCvarBool('ui_multiWindowShenanigans') then
	InitMainControlClient(object)
end

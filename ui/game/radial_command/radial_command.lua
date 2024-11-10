local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface = object
local interfaceName = interface:GetName()

local menus = {
	{	-- Normal
		-- missing (top, mid, bot)
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function(lane)
				HeroAnnouncement('missing'..lane)
			end, desc='radial_missing', visible='1', ping='command_missing',
		},
		-- Danger
		{texture='/ui/game/radial_command/textures/icon_danger.tga', onclick= function(lane)
				if lane ~= "" then
					HeroAnnouncement('care'..lane)
				else
					HeroAnnouncement('back')
				end
			end, desc='radial_back', visible='1', ping='command_careful',
		},
		-- On My Way (Top, Mid, Bottom)
		{texture='/ui/game/radial_command/textures/icon_omw.tga', onclick= function(lane) 
				HeroAnnouncement('on_my_way'..lane)
			end, desc='radial_on_my_way', visible='1', ping='command_onmyway',
		},
		-- help (top, mid, bot)
		{texture='/ui/game/radial_command/textures/icon_assist.tga', onclick= function(lane)
				HeroAnnouncement('help'..lane)
			end, desc='radial_help', visible='1', ping='command_help',
		},
		-- Close
		{texture='/ui/game/radial_selection/textures/close.tga', onclick="self:GetWidget('radial_selection_command'):SetVisible(false)", desc='general_cancel'},
	},
	{	-- Minimap
		-- missing (top, mid, bot)
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function(lane)
				HeroAnnouncement('missing'..lane)
			end, desc='radial_missing', visible='1', ping='command_missing',
		},
		-- Danger
		{texture='/ui/game/radial_command/textures/icon_danger.tga', onclick= function(lane)
				if lane ~= "" then
					HeroAnnouncement('care'..lane)
				else
					HeroAnnouncement('back')
				end
			end, desc='radial_back', visible='1', ping='command_careful',
		},
		-- On My Way (Top, Mid, Bottom)
		{texture='/ui/game/radial_command/textures/icon_omw.tga', onclick= function(lane) 
				HeroAnnouncement('on_my_way'..lane)
			end, desc='radial_on_my_way', visible='1', ping='command_onmyway',
		},
		-- help (top, mid, bot)
		{texture='/ui/game/radial_command/textures/icon_assist.tga', onclick= function(lane)
				HeroAnnouncement('help'..lane)
			end, desc='radial_help', visible='1', ping='command_help',
		},
		-- Close
		{texture='/ui/shared/textures/target.tga', onclick="self:GetWidget('radial_selection_command'):SetVisible(false)", desc='general_cancel', ping=true},
	},
}

-- 1 = default
function openRadialCommand(menuType, mouseXOffset, mouseYOffset, pingCoords, minimap)
	menuType = menuType or 1 --DEFAULT
	--							  radialType, selectionList,  mouseXOffset, mouseYOffset, pingCoords,       scale,        displayLabels, displayTitle
	GameUI.RadialSelection:hide('chat')
	GameUI.RadialSelection:create('command', menus[menuType], mouseXOffset, mouseYOffset, pingCoords, minimap and 0.4 or 1, not minimap, false)
end
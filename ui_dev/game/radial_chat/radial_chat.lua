local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface = object
local interfaceName = interface:GetName()

local menus = {
	{	
		-- I'm Retreatring
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('well') end, desc='chat_wheel_retreat', visible='0'
		},
		-- Assist
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('assist') end, desc='chat_wheel_assist', visible='0'
		},
		-- Push
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('push') end, desc='chat_wheel_push', visible='0'
		},
		-- Together
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('together') end, desc='chat_wheel_together', visible='0'
		},
		-- Get Back
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('back') end, desc='chat_wheel_watch_out', visible='0'
		},
		-- Farm
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('farm') end, desc='chat_wheel_farm', visible='0'
		},
		-- Thanks
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('thanks') end, desc='chat_wheel_thanks', visible='0'
		},
		-- Well Played
		{texture='/ui/game/radial_command/textures/icon_missing.tga', onclick= function() HeroAnnouncement('well_played') Cmd('Action OrderEmote') end, desc='chat_wheel_well_played', visible='0'
		},				
		-- Close
		{texture='/ui/game/radial_selection/textures/close.tga', onclick="self:GetWidget('radial_selection_chat'):SetVisible(false)", desc='general_cancel'},
	},
}

-- 2 = default
function openRadialChat(menuType)
	menuType = menuType or 2 --DEFAULT
	GameUI.RadialSelection:create('chat', menus[menuType], 0, 0, nil)
end
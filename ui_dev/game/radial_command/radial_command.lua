local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface = object
local interfaceName = interface:GetName()

local menus = {
	{	-- Normal
		--[[
		-- Attack (crux, generator, tower)
		{texture='/ui/game/radial_command/dial_attackhere.tga',  onclick="HeroAnnouncement('attack')",         desc='radial_attack',
			subButtons = {
				{texture='/ui/game/event_log/textures/icon_crux.tga',     onclick="HeroAnnouncement('attack_crux')",       desc='radial_attack_crux'}, 
				{texture='/ui/game/event_log/textures/icon_generator.tga',     onclick="HeroAnnouncement('attack_generator')",       desc='radial_attack_generator'}, 
				{texture='/ui/game/event_log/textures/icon_tower1.tga',     onclick="HeroAnnouncement('attack_tower')",       desc='radial_attack_tower'}
			}
		},
		-- defend (crux, generator, tower)
		{texture='/ui/game/radial_command/dial_defendstructure.tga', onclick=nil,        desc='radial_defend',
			subButtons = {
				{texture='/ui/game/event_log/textures/icon_tower1.tga',     onclick="HeroAnnouncement('defend_tower')",       desc='radial_defend_tower'},
				{texture='/ui/game/event_log/textures/icon_generator.tga',     onclick="HeroAnnouncement('defend_generator')",       desc='radial_defend_generator'}, 
				{texture='/ui/game/event_log/textures/icon_crux.tga',     onclick="HeroAnnouncement('defend_crux')",       desc='radial_defend_crux'}, 
			}
		},
		-- Krytos
		{texture='/ui/game/event_log/textures/icon_krytos.tga',  onclick="HeroAnnouncement('krytos')",         desc='radial_krytos'
		},
		--]]
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
}

-- 1 = default
function openRadialCommand(menuType, mouseXOffset, mouseYOffset, pingCoords)
	menuType = menuType or 1 --DEFAULT
	GameUI.RadialSelection:create('command', menus[menuType], mouseXOffset, mouseYOffset, pingCoords)
end
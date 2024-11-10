local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind, len, lower, gsub = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind, _G.string.len, _G.string.lower, _G.string.gsub

local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}

local function RegisterClansLadder(object)
	
	-- println('RegisterClansLadder 1/2')
	
	local sortedTop100Data = {}
	function mainUI.Clans.UpdateLadder(allMembers, sortType)
		
		sortType = sortType or 'medals'
		
		local ladder_row_scrollbar = GetWidget('clanLadder_row_scrollbar_clan_internal')
		local ladder_row_scrollbar_vscroll = GetWidget('clanLadder_row_scrollbar_clan_internal_vscroll')
		
		local oldRows = ladder_row_scrollbar:GetChildren()
		for i,v in pairs(oldRows) do
			if (v) and (v:IsValid()) then
				v:Destroy()
			end
		end
		
		libThread.threadFunc(function()
			wait(1)
		
			if (allMembers) then
				sortedTop100Data = {}
				for i,v in pairs(allMembers) do
					if (v) and (v.medalRating) and tonumber(v.medalRating) then
						local playerTable = {}
						playerTable.name 			= v.name
						playerTable.uniqueID 		= v.uniqueID
						playerTable.clanSeals 		= v.clanSeals
						playerTable.medalRating 	= v.medalRating
						playerTable.identID 		= v.identID
						table.insert(sortedTop100Data, playerTable)
					end
				end
			end
			
			if (sortType == 'seals') then
				table.sort(sortedTop100Data, function(a, b)
					if tonumber(a.clanSeals) and tonumber(b.clanSeals) and tonumber(a.clanSeals) ~= tonumber(b.clanSeals) then
						return tonumber(a.clanSeals) > tonumber(b.clanSeals)
					else
						return false
					end
				end)
			elseif (sortType == 'name') then
				table.sort(sortedTop100Data, function(a, b)
					if (a.name) and (b.name) and (a.name) ~= (b.name) then
						return lower(a.name) < lower(b.name)
					else
						return false
					end
				end)
			else -- rank or medals
				table.sort(sortedTop100Data, function(a, b)
					if tonumber(a.medalRating) and tonumber(b.medalRating) and tonumber(a.medalRating) ~= tonumber(b.medalRating) then
						return tonumber(a.medalRating) > tonumber(b.medalRating)
					else
						return false
					end
				end)
			end
			
			for i,v in ipairs(sortedTop100Data) do
				local color = '#ebebeb'
				local medalRating = tonumber(v.medalRating) or 0
				local clanSeals = tonumber(v.clanSeals) or 0
				if (IsMe(v.identID)) then
					color = '#ec6e31'
				elseif (i % 2) == 0 then 
					color = '#ebebeb'
				end
				ladder_row_scrollbar:Instantiate('clanLadderRow',
					'id', 'clan1' .. i,
					'displayname', (v.name or '?'),
					'rank', i or '?',
					'medals', math.ceil(medalRating),
					'seals', math.ceil(clanSeals),
					'color', color
				)
				local parent = GetWidget('clanLadderEntry_parent_' .. 'clan1' .. i)
				if (parent) and (v.identID) then
					parent:SetCallback('onclick', function() 
						-- ContextMenuTrigger.selectedUserIdentID = v.identID
						-- Profile.OpenProfile()	
					end)
					parent:SetCallback('onmouseover', function(widget) 
						-- Profile.OpenProfilePreview(v.identID)
						-- UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, canDrag = false })
					end)
					parent:SetCallback('onmouseout', function(widget) 
						-- Profile.CloseProfilePreview()
						-- UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, canDrag = false })
					end)					
					FindChildrenClickCallbacks(parent)
				end
			end
			
			ladder_row_scrollbar:SetClipAreaToChild()
			ladder_row_scrollbar_vscroll:SetValue(0)
			
		end)
		
	end		
	
	local clanLadderHeaderEntry_ladder_slot_caps			= interface:GetWidget('clanLadderHeaderEntry_ladder_slot_caps')
	local clanLadderHeaderEntry_ladder_playername_caps		= interface:GetWidget('clanLadderHeaderEntry_ladder_playername_caps')
	-- local clanLadderHeaderEntry_ladder_seals_caps			= interface:GetWidget('clanLadderHeaderEntry_ladder_seals_caps')
	local clanLadderHeaderEntry_ladder_medals_caps			= interface:GetWidget('clanLadderHeaderEntry_ladder_medals_caps')
	
	clanLadderHeaderEntry_ladder_slot_caps:SetCallback('onclick', function(widget)
		mainUI.Clans.UpdateLadder(nil, 'medals')
	end)
	clanLadderHeaderEntry_ladder_playername_caps:SetCallback('onclick', function(widget)
		mainUI.Clans.UpdateLadder(nil, 'name')
	end)
	-- clanLadderHeaderEntry_ladder_seals_caps:SetCallback('onclick', function(widget)
		-- mainUI.Clans.UpdateLadder(nil, 'seals')
	-- end)
	clanLadderHeaderEntry_ladder_medals_caps:SetCallback('onclick', function(widget)
		mainUI.Clans.UpdateLadder(nil, 'medals')
	end)
	
	-- println('RegisterClansLadder 2/2')
	
end

RegisterClansLadder(object)
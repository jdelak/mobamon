mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
-- In-Game endgame scoreboard

local function endgameScoreboardRegister(object)
	
	local container		= object:GetWidget('endgame_scoreboard')
	local leaveButton	= object:GetWidget('endgame_scoreboard_leavegame')
	local IwasInThisGame = false
	container:RegisterWatchLua('GameReinitialize', function(widget, trigger)
		widget:SetVisible(false)
	end)
	
	leaveButton:SetCallback('onclick', function(widget)
		FinishMatch()
	end)
	
	local function PopulateScoreboardEndgame(object, matchStatsTable, submitTime, incMatchID)
		println("PopulateScoreboardEndgame!")
		println("matchStatsTable:")
		printr(matchStatsTable)
		println("submitTime:")
		println(tostring(submitTime))
		println("incMatchID:")
		println(tostring(incMatchID))
		container:Sleep(math.max(1, math.min(5000, (5000 - submitTime))), function()
			if (not matchStatsTable) or (type(matchStatsTable) ~= 'table') or (not matchStatsTable.matchStats) then
				SevereError('PopulateScoreboard called with no matchStats table '.. tostring(matchStatsTable), 'main_reconnect_thatsucks', '', nil, nil, false)
				return nil
			end
			
			IwasInThisGame = false
			
			for i = 0,10 do
				local rowbutton_0 						= object:GetWidget('endgame_scoreboard_row_' .. i .. '_rowbutton_0')				
				local rowbutton_1 						= object:GetWidget('endgame_scoreboard_row_' .. i .. '_rowbutton_1')							
				if (rowbutton_0) then
					rowbutton_0:SetVisible(0)
				end
				if (rowbutton_1) then
					rowbutton_1:SetVisible(0)	
				end
			end			
			
			for playerIndex, playerInfo in pairs(matchStatsTable.matchStats.stats) do
				if (playerInfo) then
				
					if playerInfo.ident_id == GetIdentID() then
						IwasInThisGame = true
					end					
				
					if (not playerInfo.slot) then
						SevereError('playerInfo Player Slot Missing #0: '.. tostring(playerInfo.slot), 'main_reconnect_thatsucks', '', nil, nil, false)
						return
					end
					
					local slot 								= playerInfo.slot
					local postgame_scoreboard_row 			= object:GetWidget('endgame_scoreboard_row_' .. slot)
					local bg_1 								= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_bg_1')
					local bg_2 								= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_bg_2')
					local hero_icon 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_hero_icon')
					local player_name 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_player_name')
					local pet_name 							= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_pet_name')
					
					local rowlabel_1 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_rowlabel_1')
					local rowlabel_2 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_rowlabel_2')
					local rowlabel_3 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_rowlabel_3')
					local rowlabel_4 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_rowlabel_4')
					local rowlabel_5 						= object:GetWidget('endgame_scoreboard_row_' .. slot .. '_rowlabel_5')
					
					local identID							 = playerInfo.ident_id or 0
					playerInfo.isBot = (math.floor(tonumber(playerInfo.ident_id or 0)) == 0)
					
					--
					if (playerInfo.nickname) and (playerInfo.ident_id) and (playerInfo.uniqid) and (not playerInfo.isBot) and (not IsMe(playerInfo.ident_id))  then
						AddRecentlyPlayedWith(playerInfo.nickname, playerInfo.uniqid, playerInfo.ident_id, Translate('general_strife_beta'))
					end

					if (playerInfo.nickname) then
						if playerInfo.isBot then
							local botName = playerInfo.nickname
							if (botName) then
								if ValidateEntity(botName)  then
									player_name:SetText(GetEntityDisplayName(botName))
								else
									player_name:SetText(Translate(botName))
								end
							else
								player_name:SetText(Translate('general_bot'))
							end
						else
							player_name:SetText(playerInfo.nickname)
						end
					else
						player_name:SetText('')
					end			
						
					if (playerInfo.matchmakingFamiliarStats) then
						local familiarEntity		= tostring(playerInfo.matchmakingFamiliarStats.entityName)
						if ValidateEntity(familiarEntity) then
							local familiarDisplayName	= GetEntityDisplayName(familiarEntity)
							
							if familiarDisplayName and string.len(familiarDisplayName) > 0 then
								pet_name:SetText(Translate('heroselect_withpet', 'petname', familiarDisplayName))
							end
						end
					elseif (not playerInfo.isBot) then
						SevereError('No matchmakingFamiliarStats in EndMatch (gamescoreboard) data', 'main_reconnect_thatsucks', '', nil, nil, false)
					end
					
					hero_icon:SetTexture('$invis')
					if (playerInfo.matchmakingHeroStats) then
						if (playerInfo.matchmakingHeroStats.entityName) and ValidateEntity(playerInfo.matchmakingHeroStats.entityName) and (GetEntityIconPath(playerInfo.matchmakingHeroStats.entityName)) then
							hero_icon:SetTexture(GetEntityIconPath(playerInfo.matchmakingHeroStats.entityName))
						else
							hero_icon:SetTexture('$checker')
						end			
					elseif (not playerInfo.isBot) then
						SevereError('No matchmakingHeroStats in EndMatch (gamescoreboard) data', 'main_reconnect_thatsucks', '', nil, nil, false)
					end
					
					if (playerInfo.kills and playerInfo.kills ~= "?") then
						rowlabel_1:SetText(playerInfo.heroLevel)
						rowlabel_2:SetText(playerInfo.kills)
						rowlabel_3:SetText(playerInfo.assists)
						rowlabel_4:SetText(playerInfo.deaths)
						rowlabel_5:SetText(playerInfo.gpm)
					else
						local trigger = LuaTrigger.GetTrigger('SpectatorUnit'..slot)
						if (trigger and trigger.exists) then
							rowlabel_1:SetText(trigger.level)
							rowlabel_2:SetText(trigger.kills)
							rowlabel_3:SetText(trigger.assists)
							rowlabel_4:SetText(trigger.death)
							rowlabel_5:SetText(trigger.gpm)
						end
					end
					
					for i = 1, 7 do
						if playerInfo.items['item_'..i] and string.len(playerInfo.items['item_'..i]) > 0 then
							if ValidateEntity(playerInfo.items['item_'..i]) then
								object:GetWidget('endgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(GetEntityIconPath(playerInfo.items['item_'..i]))
							else
								object:GetWidget('endgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture('$checker')
							end
						elseif playerInfo.items['item'..i] and string.len(playerInfo.items['item'..i]) > 0 then
							if ValidateEntity(playerInfo.items['item'..i]) then
								object:GetWidget('endgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(GetEntityIconPath(playerInfo.items['item'..i]))
							else
								object:GetWidget('endgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture('$checker')
							end
						else
							-- Did it just not send any items? Work them out from slot numbers
							local itemSlot = i % 7 -- We want 7 to be 0 here
							local trigger = LuaTrigger.GetTrigger('Spectator'..itemSlot..'HeroInventory'..slot)
							if (trigger and trigger.exists) then
								local path = trigger.iconPath
								if (path == "") then path = style_item_emptySlot end
								object:GetWidget('endgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(path)
							else
								object:GetWidget('endgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(style_item_emptySlot)
							end
						end
					end
					
				else
					print('no stats for index ' .. playerIndex)
				end
				
			end
			
			if (IwasInThisGame) then
				mainUI.savedLocally = mainUI.savedLocally or {}
				mainUI.savedLocally.lastMatchID = incMatchID
				SaveState()			
			end
			
			container:FadeIn(250)
		end)
	
	end
	
	local waitingForStats	= true
	
	container:RegisterWatchLua('GameReinitialize', function(widget, trigger)
		container:SetVisible(false)
	end)
	
	container:RegisterWatchLua('EndMatch', function(widget, trigger)
		if trigger.display then
			if tonumber(GetMatchID()) > 4000000 then
				
				println('Was A Practice Game (ingame)')

				-- endgame_reopen_rewards_button:SetEnabled(0)				

				matchStatsTable = {}
				matchStatsTable.matchStats = {}
				matchStatsTable.matchStats.stats = {}				

				local localMatchStatsTable = EndMatch.GetLocalStats()

				for index,statTable in pairs(localMatchStatsTable) do
					matchStatsTable.matchStats.stats[index] = statTable
					matchStatsTable.matchStats.stats[index].matchmakingHeroStats = {}
					matchStatsTable.matchStats.stats[index].matchmakingHeroStats.entityName = statTable.hero
					matchStatsTable.matchStats.stats[index].matchmakingFamiliarStats = {}
					matchStatsTable.matchStats.stats[index].matchmakingFamiliarStats.entityName = statTable.familiar					
					matchStatsTable.matchStats.stats[index].nickname = statTable.name					
				end

				rewardsChestsTable = nil
				
				if (matchStatsTable) then
					showSomething = true
					PopulateScoreboardEndgame(object, matchStatsTable, 0)
				else
					print('match stats table is nil?!\n')
				end
				
			end
		end
	end, false, nil)
	
	container:RegisterWatchLua('MatchSubmissionState', function(widget, trigger)
		local state			= trigger.state
		local submitTime	= trigger.submitTime
		
		if state ~= 1 then
			waitingForStats	= true
		end
		
		if state == 0 or state == 3 then	-- Sending or fail/retry
		elseif state == 1 then	-- Success
			if waitingForStats then
				-- request stats
				waitingForStats = false
				local incMatchID = GetMatchID()

				local matchStatsTable
		
				if (tonumber(incMatchID) and (tonumber(incMatchID) >= 0) and (tonumber(incMatchID) <= 4000000)) then -- (not trigger.isPractice) or 
					
					local function successFunction(request)	-- response handler
						local responseData = request:GetBody()
						if responseData == nil or responseData.matchStats == nil or responseData.matchStats.stats == nil then
							SevereError('No Match Stats in EndMatch (gamescoreboard) data', 'main_reconnect_thatsucks', '', nil, nil, false)
							return nil
						else
							PopulateScoreboardEndgame(object, responseData, submitTime, incMatchID)
							return true
						end
					end				
					
					local function failureFunction(request)	-- error handler
						SevereError('GetMatchStatsLite (gamescoreboard) Request Error: ' .. Translate(request:GetError() or ''), 'main_reconnect_thatsucks', '', nil, nil, false)
						return nil
					end				
					
					matchStatsTable 	= Strife_Web_Requests:GetMatchStatsLite(incMatchID, successFunction, failureFunction)					
				end

					
			end
		end
	end)

end

endgameScoreboardRegister(object)

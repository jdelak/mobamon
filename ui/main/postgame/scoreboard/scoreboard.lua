PostGame = PostGame or {}
PostGame.Scoreboard = PostGame.Scoreboard or {}
mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}

local tinsert, tremove, tsort = table.insert, table.remove, table.sort
endMatch = endMatch or {}

-- =====================================

local function endMatchRegisterMain(object)
	local container							= object:GetWidget('endMatchMainScriptWidget')
	
	local rewardsBody						= object:GetWidget('endMatchRewardsBody')
	local postgame_scoreboard				= object:GetWidget('postgame_scoreboard')
	local postgame_left_content				= object:GetWidget('postgame_left_content')

	local mainPanelStatus					= LuaTrigger.GetTrigger('mainPanelStatus')

	local rewardsChooseAnotherYes			= object:GetWidget('endMatchRewardsChooseAnotherYes')
	local rewardsChooseAnotherNo			= object:GetWidget('endMatchRewardsChooseAnotherNo')

	local rewardsChooseAnotherYesContainer	= object:GetWidget('endMatchRewardsChooseAnotherYesContainer')
	local rewardsChooseAnotherNoContainer	= object:GetWidget('endMatchRewardsChooseAnotherNoContainer')

	local downVoteMatchID, upVoteMatchID	= nil, nil

	local function ShowItemTip(itemEntity)
		if (itemEntity) and (not Empty(itemEntity)) then
			local itemInfoTable = ShopItem(itemEntity)
			if (itemInfoTable) then
				craftedItemTipPopulate(nil, true, nil, true, itemInfoTable.isRecipe, true, itemInfoTable, true)
				local trigger = LuaTrigger.GetTrigger('shopItemTipInfo')
				trigger.index = 1
				trigger.itemType = 'craftedItemInfoShop'
				trigger.isComponent = false
				trigger:Trigger(false)	
			end
		end
	end	
	
	function PostGame.Scoreboard.PopulateScoreboard(object, matchStatsTable)

		if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['stats'])) then
			trigger_postGameLoopStatus.scoreboardAvailable = false
			return
		end

		if (not matchStatsTable) or (type(matchStatsTable) ~= 'table') or (not matchStatsTable.matchStats) then
			SevereError('PopulateScoreboard called with no matchStats table '.. tostring(matchStatsTable), 'main_reconnect_thatsucks', '', nil, nil, false)
			trigger_postGameLoopStatus.scoreboardAvailable = false
			return nil
		end

		local selfInfo
		local usePlayerIndex
		
		PostGame.Splash.AssignAwards(matchStatsTable)
		
		for playerIndex, playerInfo in pairs(matchStatsTable.matchStats.stats) do

			if playerInfo.ident_id == GetIdentID() then
				selfInfo = playerInfo
			end

			if (playerInfo) then
				if (not playerInfo.slot) then
					SevereError('playerInfo Player Slot Missing #0: '.. tostring(playerInfo.slot), 'main_reconnect_thatsucks', '', nil, nil, false)
					return
				end

				if playerInfo.ident_id then
					if playerInfo.ident_id == '0.000' then
						usePlayerIndex = playerInfo.slot
						for i=1,math.max(0, (2 - string.len(playerInfo.slot))),1 do
							usePlayerIndex = '0'..usePlayerIndex
						end
						usePlayerIndex = '0.0'..usePlayerIndex
					else
						usePlayerIndex = playerInfo.ident_id
					end
				else
					print('no valid or even empty ident_id for '..playerIndex..'\n')
					usePlayerIndex = playerIndex
				end

				local slot 								= playerInfo.slot
				local postgame_scoreboard_row 			= GetWidget('postgame_scoreboard_row_' .. slot)
				
				if (not postgame_scoreboard_row) then
					return
				end
				
				local bg_1 								= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_bg_1')
				local bg_2 								= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_bg_2')
				local hero_icon 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_hero_icon')
				local player_name 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_player_name')
				local pet_name 							= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_pet_name')

				local rowlabel_1 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_rowlabel_1')
				local rowlabel_2 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_rowlabel_2')
				local rowlabel_3 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_rowlabel_3')
				local rowlabel_4 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_rowlabel_4')
				local rowlabel_5 						= object:GetWidget('postgame_scoreboard_row_' .. slot .. '_rowlabel_5')

				local identID							 = playerInfo.ident_id or 0
				playerInfo.isBot = (math.floor(tonumber(playerInfo.ident_id or 0)) == 0)

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

				if (playerInfo.kills) then
					rowlabel_1:SetText(playerInfo.heroLevel or '?')
					rowlabel_2:SetText(playerInfo.kills or '?')
					rowlabel_3:SetText(playerInfo.assists or '?')
					rowlabel_4:SetText(playerInfo.deaths or '?')
					rowlabel_5:SetText(playerInfo.gpm or '?')
				end

				for i=1,7,1 do
					if object:GetWidget('postgame_scoreboard_inventory_' .. slot .. '_'..i) then
						object:GetWidget('postgame_scoreboard_inventory_' .. slot .. '_'..i):ClearCallback('onmouseover')
					end
					if playerInfo.items['item_'..i] and string.len(playerInfo.items['item_'..i]) > 0 then
						if (playerInfo.items['item_'..i]) and ValidateEntity(playerInfo.items['item_'..i]) then
							object:GetWidget('postgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(GetEntityIconPath(playerInfo.items['item_'..i]))
							object:GetWidget('postgame_scoreboard_inventory_' .. slot .. '_'..i):SetCallback('onmouseover', function(widget)
								-- simpleTipGrowYUpdate(true, GetEntityIconPath(playerInfo.items['item_'..i]), GetEntityDisplayName(playerInfo.items['item_'..i]), GetEntityDisplayName(playerInfo.items['item_'..i]), libGeneral.HtoP(34))
								ShowItemTip(playerInfo.items['item_'..i])
							end)
							object:GetWidget('postgame_scoreboard_inventory_' .. slot .. '_'..i):SetCallback('onmouseout', function(widget)
								simpleTipGrowYUpdate(false)
								shopItemTipHide()
							end)
						else
							object:GetWidget('postgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture('$checker')
						end
					elseif playerInfo.items['item'..i] and string.len(playerInfo.items['item'..i]) > 0 then
						if (playerInfo.items['item'..i]) and ValidateEntity(playerInfo.items['item'..i]) then
							object:GetWidget('postgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(GetEntityIconPath(playerInfo.items['item'..i]))
							object:GetWidget('postgame_scoreboard_inventory_' .. slot .. '_'..i):SetCallback('onmouseover', function(widget)
								-- simpleTipGrowYUpdate(true, GetEntityIconPath(playerInfo.items['item'..i]), GetEntityDisplayName(playerInfo.items['item'..i]), GetEntityDisplayName(playerInfo.items['item'..i]), libGeneral.HtoP(34))
								ShowItemTip(playerInfo.items['item'..i])							
							end)
							object:GetWidget('postgame_scoreboard_inventory_' .. slot .. '_'..i):SetCallback('onmouseout', function(widget)
								simpleTipGrowYUpdate(false)
								shopItemTipHide()
							end)							
						else
							object:GetWidget('postgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture('$checker')
						end
					else
						object:GetWidget('postgame_scoreboard_inventory_icon_' .. slot .. '_'..i):SetTexture(style_item_emptySlot)
					end
				end

			else
				println('no stats for index ' .. playerIndex)
			end
		end	-- end player loop

		trigger_postGameLoopStatus.scoreboardAvailable = true
		trigger_postGameLoopStatus:Trigger(false)
	end



end	-- /endMatchRegisterMain

endMatchRegisterMain(object)
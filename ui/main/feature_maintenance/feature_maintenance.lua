mainUI = mainUI or {}
mainUI.featureMaintenance = {}
	
local function FeatureMaintenanceRegister(object)
	
	local function Update()

		mainUI.featureMaintenance = {}
	
		local featureMaintenanceTrigger 	= LuaTrigger.GetTrigger('featureMaintenanceTrigger')
		local chatAvailabilityTrigger 		= LuaTrigger.GetTrigger('ChatAvailability')
			
		local disabledFeatures = {

		}

		local allFeatures = {
			'chat',
			'chat_create_channel',
			'friends',
			'pets',
			'crafting',
			'enchanting',
			'groups',
			'groups_create',
			'party',
			'play',
			'play_pvp',
			'play_pve',
			'purchasing_gems',
			'lobby',
			'profile',
			'mentor',
			'notifications',
			-- 'options', -- this is enabled while logged out
			'spectate',
			'spending_gems',
			'twitch_stream',
			'twitch_vods',
			'stats',
			'replays',
			'rewards',
			'watch',
			'khanquest',
		}		
		
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		if (not mainPanelStatus.isLoggedIn) or (not mainPanelStatus.hasIdent) then	-- disable all if logged out
			for i, v in pairs(allFeatures) do
				mainUI.featureMaintenance[v] = true
			end	
		else
			for i, v in pairs(allFeatures) do
				mainUI.featureMaintenance[v] = nil								-- initially enabled all on login
			end	
		end
		
		-- local AccountInfo = LuaTrigger.GetTrigger('AccountInfo')	-- can restrict features by account level etc
		-- if (AccountInfo.accountLevel <= 10) then
			-- mainUI.featureMaintenance['friends'] = true
		-- end
		 
		if (Strife_Region.regionTable) and (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].new_player_experience) then
			local newPlayerExperience = LuaTrigger.GetTrigger('newPlayerExperience')
			if (not newPlayerExperience.tutorialComplete) then
				if (newPlayerExperience.tutorialProgress < NPE_PROGRESS_FINISHTUT2) then
					mainUI.featureMaintenance['friends'] = true
					mainUI.featureMaintenance['pets'] = true
					mainUI.featureMaintenance['crafting'] = true
					mainUI.featureMaintenance['enchanting'] = true
					mainUI.featureMaintenance['play'] = true
					mainUI.featureMaintenance['lobby'] = true
					mainUI.featureMaintenance['party'] = true
					mainUI.featureMaintenance['watch'] = true
				elseif (newPlayerExperience.tutorialProgress < NPE_PROGRESS_ACCOUNTCREATED) then
					mainUI.featureMaintenance['friends'] = true
					mainUI.featureMaintenance['pets'] = true
					mainUI.featureMaintenance['crafting'] = true
					mainUI.featureMaintenance['enchanting'] = true
					mainUI.featureMaintenance['play'] = true
					mainUI.featureMaintenance['lobby'] = true
					mainUI.featureMaintenance['party'] = true				
					mainUI.featureMaintenance['watch'] = true				
				elseif (newPlayerExperience.tutorialProgress < NPE_PROGRESS_SELECTEDPET) then
					mainUI.featureMaintenance['friends'] = true
					mainUI.featureMaintenance['crafting'] = true
					mainUI.featureMaintenance['enchanting'] = true
					mainUI.featureMaintenance['play'] = true
					mainUI.featureMaintenance['lobby'] = true
					mainUI.featureMaintenance['party'] = true
					mainUI.featureMaintenance['watch'] = true
				elseif (newPlayerExperience.tutorialProgress < NPE_PROGRESS_FINISHTUT3) then
					mainUI.featureMaintenance['pets'] = true
					mainUI.featureMaintenance['crafting'] = true
					mainUI.featureMaintenance['enchanting'] = true
					mainUI.featureMaintenance['play'] = true
					mainUI.featureMaintenance['lobby'] = true
					mainUI.featureMaintenance['party'] = true
					mainUI.featureMaintenance['watch'] = true
				end
			end
		end

		-- printr(mainUI.featureMaintenance)
		
		-- Get Feature Maintenance info from chat server here
		if (chatAvailabilityTrigger) and (chatAvailabilityTrigger.lobby) and (chatAvailabilityTrigger.lobby.enabled == false) then
			mainUI.featureMaintenance['lobby'] = true
		end
		if ((chatAvailabilityTrigger) and (chatAvailabilityTrigger.matchmaking) and (chatAvailabilityTrigger.matchmaking.enabled == false)) or GetCvarBool('ui_disableMatchmaking') then
			mainUI.featureMaintenance['party'] = true
		end			

		if ((chatAvailabilityTrigger) and (chatAvailabilityTrigger.matchmaking) and (chatAvailabilityTrigger.matchmaking.queues) and (chatAvailabilityTrigger.matchmaking.queues)) then
			for i,v in pairs(chatAvailabilityTrigger.matchmaking.queues) do
				if (v.name) and (v.visible == false) then
					mainUI.featureMaintenance[v.name] = true
				elseif (v.name) and (v.enabled == false) then
					mainUI.featureMaintenance[v.name] = 'comingsoon'
				end
			end
		end			
		
		-- printr( chatAvailabilityTrigger.lobby )
		-- printr( chatAvailabilityTrigger.matchmaking )
		
		-- Disabled For Region
		if (Strife_Region.regionTable) and (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures) then
			for i, v in pairs(Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures) do			
				if (v) and (type(v) == 'table') then
					for i2, v2 in pairs(v) do
						mainUI.featureMaintenance[i2] = v2
					end
				else
					mainUI.featureMaintenance[v] = true
				end
			end
		end
		
		-- printr(mainUI.featureMaintenance)
		
		-- Hardcoded disabled
		for i, v in pairs(disabledFeatures) do
			if (type(v) == 'table') then
				mainUI.featureMaintenance[v[1]] = v[2]
			else
				mainUI.featureMaintenance[v] = true
			end
		end		
		
		-- Cvar disablage
		if GetCvarBool('ui_disablePVP') then
			mainUI.featureMaintenance['pvp'] = 'disabled'
		end
		
		if GetCvarBool('ui_disablePVE') then
			mainUI.featureMaintenance['pve'] = 'disabled'
		end		
		
		if GetCvarBool('ui_disableRanked') then
			mainUI.featureMaintenance['ranked'] = 'disabled'
		end		
		
		if GetCvarBool('ui_disableKhanquest') then
			mainUI.featureMaintenance['khanquest'] = 'disabled'
		end			
		
		if GetCvarBool('ui_disableLobby') then
			mainUI.featureMaintenance['lobby'] = 'disabled'
		end	
		
		if GetCvarBool('ui_disableTut1') then
			mainUI.featureMaintenance['play_tut_1'] = 'disabled'
		end			
		
		if GetCvarBool('ui_disableTut2') then
			mainUI.featureMaintenance['play_tut_2'] = 'disabled'
		end			
		
		if GetCvarBool('ui_disableTut3') then
			mainUI.featureMaintenance['play_tut_3'] = 'disabled'
		end	

		if GetCvarBool('ui_disableTut4') then
			mainUI.featureMaintenance['play_tut_4'] = 'disabled'
		end
		
		if GetCvarBool('ui_disableSpe1') then
			mainUI.featureMaintenance['play_spe_1'] = 'disabled'
		end			
		
		if GetCvarBool('ui_disableGems') then
			mainUI.featureMaintenance['purchasing_gems'] = true
		end	
		
		if GetCvarBool('ui_disableParty') then
			mainUI.featureMaintenance['party'] = true
		end			
		
		featureMaintenanceTrigger.update = false
		featureMaintenanceTrigger:Trigger(true)
	end
	
	Update()

	UnwatchLuaTriggerByKey('ChatAvailability', 'featureMaintenanceUpdateKey')
	UnwatchLuaTriggerByKey('mainPanelStatus', 'featureMaintenanceUpdateKey')
	-- UnwatchLuaTriggerByKey('AccountInfo', 'featureMaintenanceUpdateKey')

	WatchLuaTrigger('ChatAvailability', Update, 'featureMaintenanceUpdateKey')
	WatchLuaTrigger('mainPanelStatus', Update, 'featureMaintenanceUpdateKey')
	-- WatchLuaTrigger('AccountInfo', Update, 'featureMaintenanceUpdateKey')

	if (Strife_Region.regionTable) and (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].new_player_experience) then
		UnwatchLuaTriggerByKey('newPlayerExperience', 'featureMaintenanceUpdateKey')
		WatchLuaTrigger('newPlayerExperience', Update, 'featureMaintenanceUpdateKey', nil, 'tutorialProgress', 'tutorialComplete')
	end
	
end

FeatureMaintenanceRegister(object)
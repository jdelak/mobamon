-- Tutorial
local interface = object
gameTutorial = gameTutorial or {
	objectiveIndex			= 0,	-- Just provide a unique id per objective
	hintIndex				= 0,	-- Just provide a unique id per hint
	activeObjectives		= {},
	activeHints				= {},
	hintDisplayOrder		= {},
	objectiveDisplayOrder	= {},
	initWidgetSoundEnabled	= false,
	blackOverlayVisible		= true,
	activeMessage			= nil,
	activeMessage2			= nil,
	activeTip				= nil,
	initialized				= false,
	panelVis				= {}
}

local tutorialMessageStatus = LuaTrigger.CreateCustomTrigger('tutorialMessageVis', {
	{ name		= 'tutorialMessageVis',			type		= 'boolean' },
	{ name		= 'tutorialMessage2Vis',		type		= 'boolean' },
	{ name		= 'tutorialTipVis',				type		= 'boolean' },
})


if not gameTutorial.initialized then
	tutorialMessageStatus.tutorialMessageVis			= false
	tutorialMessageStatus.tutorialMessage2Vis			= false
	tutorialMessageStatus.tutorialTipVis				= false
	tutorialMessageStatus:Trigger(false)
	gameTutorial.initialized = true
end

-- trigger to prevent the pause from showing in the tutorial
local tutorialPauseTrigger = LuaTrigger.CreateCustomTrigger("TutorialPause", {{name = "hidePaused", type = "boolean"}})
tutorialPauseTrigger.hidePaused = false
tutorialPauseTrigger:Trigger(true)

--cinematic bars
--interface:GetWidget('cinematicModeOverlay'):RegisterWatch('campaign_startCinematicOverlay', function(widget)
--    widget.SetVisible(true);
--    widget:FadeIn(500)
--	widget:SlideY('400h', 2000)
--end)

--interface:GetWidget('cinematicModeOverlay'):RegisterWatch('campaign_endCinematicOverlay', function(widget)
--    gameTutorial.cinematicOverlayVisible = false
--    widget:FadeOut(500)
--end)

--Objective Functions
function arrangeWidgets()
	local messageContainer = interface:GetWidget('tutorialMessageContainer')

	messageContainer:Sleep(1, function()
		local thisBody
		local currentPos = 0
		local padding = libGeneral.HtoP(0.5)
		for k, childWidget in ipairs(messageContainer:GetChildren()) do
			thisBody = interface:GetWidget(childWidget:GetName()..'Contents')
			if tutorialMessageStatus[childWidget:GetName()..'Vis'] then
				childWidget:SlideY(currentPos, 250, true)
				currentPos = currentPos + padding + thisBody:GetHeight()
			end
		end
	end)
end


interface:GetWidget('tutorialScriptWidget1'):RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
	if trigger.moreInfoKey then
		widget:UICmd("SendScriptMessage('ui_moreInfoOn', '1')")
	else
		widget:UICmd("SendScriptMessage('ui_moreInfoOff', '1')")
	end
end, false, nil, 'moreInfoKey')


interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_getSeenTowerDamageWarning', function(widget)
	if NewPlayerExperience and NewPlayerExperience.data and NewPlayerExperience.data.seenTowerDamageWarning then
		widget:UICmd("SendScriptMessage('tutorial_seenTowerDamageWarningTrue', '1')")
	else
		widget:UICmd("SendScriptMessage('tutorial_seenTowerDamageWarningFalse', '1')")
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_lockTabOn', function(widget)
	TutorialToggleTab(true)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_lockTabOff', function(widget)
	TutorialToggleTab(false)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setSeenTowerDamageWarningTrue', function(widget)
	NewPlayerExperience.data.seenTowerDamageWarning = true
	NewPlayerExperience.saveDB()
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setSeenTowerDamageWarningFalse', function(widget)
	NewPlayerExperience.data.seenTowerDamageWarning = false
	NewPlayerExperience.saveDB()
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_getSeenAttackHeroWarning', function(widget)
	if NewPlayerExperience.data.seenAttackHeroWarning then
		widget:UICmd("SendScriptMessage('tutorial_seenAttackHeroWarningTrue', '1')")
	else
		widget:UICmd("SendScriptMessage('tutorial_seenAttackHeroWarningFalse', '1')")
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setSeenAttackHeroWarningTrue', function(widget)
	NewPlayerExperience.data.seenAttackHeroWarning = true
	NewPlayerExperience.saveDB()
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setSeenAttackHeroWarningFalse', function(widget)
	NewPlayerExperience.data.seenAttackHeroWarning = false
	NewPlayerExperience.saveDB()
end)


interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setCamMode0', function(widget)
	Cvar.GetCvar('cam_mode'):Set('0')
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setCamMode1', function(widget)
	Cvar.GetCvar('cam_mode'):Set('1')
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_setCamMode2', function(widget)
	Cvar.GetCvar('cam_mode'):Set('2')
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spawnCreepsOn', function(widget)
	Cvar.GetCvar('sv_spawncreeps'):Set('true')
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spawnCreepsOff', function(widget)
	Cvar.GetCvar('sv_spawncreeps'):Set('false')
end)

interface:GetWidget('tutorialMessageContainer'):RegisterWatchLua('tutorialMessageVis', function(widget, trigger)
	arrangeWidgets()
end)

-- ========



interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_armorFocusOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.armorFocus = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_armorFocusOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.armorFocus = false
		trigger:Trigger(true)
	end
end)


interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_magicArmorFocusOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.magicArmorFocus = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_magicArmorFocusOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.magicArmorFocus = false
		trigger:Trigger(true)
	end
end)



interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_DPSFocusOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.DPSFocus = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_DPSFocusOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.DPSFocus = false
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_PowerFocusOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.powerFocus = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_PowerFocusOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.powerFocus = false
		trigger:Trigger(true)
	end
end)



interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_armorOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.armor = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_armorOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.armor = false
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_powerOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.power = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_powerOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.power = false
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_dpsOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.dps = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_dpsOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.dps = false
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_magicArmorOn', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.magicArmor = true
		trigger:Trigger(true)
	end
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_tabExplain_magicArmorOff', function(widget)
	local trigger = LuaTrigger.GetTrigger('altInfoSelfTabExplain')

	if trigger then
		trigger.magicArmor = false
		trigger:Trigger(true)
	end
end)

-- ========


interface:GetWidget('tutorialMessageContainer'):RegisterWatchLua('EventLeaveGame', function(widget, trigger)
	tutorialPauseTrigger.hidePaused = false
	tutorialPauseTrigger:Trigger(true)
end)

interface:GetWidget('tutorialBlackOverlay'):RegisterWatch('tutorial_fadeBlackIn', function(widget)
	gameTutorial.blackOverlayVisible = true
	widget:FadeIn(500)
end)

interface:GetWidget('tutorialBlackOverlay'):RegisterWatch('tutorial_fadeBlackOut', function(widget)
	gameTutorial.blackOverlayVisible = false
	widget:FadeOut(500)
end)

interface:GetWidget('tutorialBlackOverlay'):RegisterWatch('tutorial_fadeBlackOutSlow', function(widget)
	gameTutorial.blackOverlayVisible = false
	widget:FadeOut(3000)
end)

interface:GetWidget('tutorialLogo'):RegisterWatch('tutorial_fadeLogoIn', function(widget) widget:FadeIn(500) end)
interface:GetWidget('tutorialLogo'):RegisterWatch('tutorial_fadeLogoOut', function(widget) widget:FadeOut(500) end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_toggleLockedCam', function(widget) Cmd("Action ToggleLockedCam") end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatchLua('CameraMode', function(widget, trigger)
	widget:UICmd("SendScriptMessage('ui_camModeSetting', '"..tostring(trigger.camMode).."')")
end, false, nil, 'camMode')

interface:UICmd("SendScriptMessage('ui_camModeSetting', '"..tostring(LuaTrigger.GetTrigger('CameraMode').camMode).."')")

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_objectivePanelShow', function(widget)
	widget:FadeIn(500)
end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_objectivePanelHide', function(widget)
	widget:FadeOut(500)
end)

function tutorialForceShopCategory(categoryName)
	categoryName = categoryName or ''

	if categoryName and string.len(categoryName) > 0 then
		trigger_shopFilter.shopCategory			= categoryName
		trigger_shopFilter.forceCategory		= categoryName
	else
		trigger_shopFilter.forceCategory		= ''
	end

	trigger_shopFilter:Trigger(false)
end

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_pauseGame', function(widget)
	Cmd("ServerPause")
end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_shopBootsOnly', function(widget)
	tutorialForceShopCategory('boots')
end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_shopRecommendedItems', function(widget)
	tutorialForceShopCategory('crafted+itembuild')
end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_shopAbilityOnly', function(widget)
	tutorialForceShopCategory('ability')
end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_shopManaOnly', function(widget)
	tutorialForceShopCategory('mana')
end)

interface:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_shopAllItems', function(widget)
	tutorialForceShopCategory('')
end)

local function tutorialRegisterGameWidgetVis(object, paramName)
	local objectiveContainer	= interface:GetWidget('tutorialObjectiveList')	-- Any widget will do!

	if gameTutorial.panelVis[paramName] == nil then
		gameTutorial.panelVis[paramName] = trigger_gamePanelInfo[paramName]
	else
		trigger_gamePanelInfo[paramName] = gameTutorial.panelVis[paramName]
		trigger_gamePanelInfo:Trigger(false)
	end

	objectiveContainer:RegisterWatch(paramName..'_show', function(widget)
		trigger_gamePanelInfo[paramName] = true
		gameTutorial.panelVis[paramName] = true
		trigger_gamePanelInfo:Trigger(false)
	end)

	objectiveContainer:RegisterWatch(paramName..'_hide', function(widget)
		trigger_gamePanelInfo[paramName] = false
		gameTutorial.panelVis[paramName] = false
		trigger_gamePanelInfo:Trigger(false)
	end)
end

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_shopClickable_enable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_shopClickable = true
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_shopClickable_disable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_shopClickable = false
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_canToggleShop_enable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_canToggleShop = true
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_canToggleShop_disable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_canToggleShop = false
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_shopRightClick_enable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_shopRightClick = true
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_shopRightClick_disable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_shopRightClick = false
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_setItemBuild_Caprice', function(widget)
	SetItemBuild(GetDefaultItemBuild('Hero_Caprice'))
end)


object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_buildControls_enable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_buildControls = true
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_buildControls_disable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_buildControls = false
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_shopBootsGlow_enable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_shopBootsGlow = true
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('mapWidgetVis_shopBootsGlow_disable', function(widget)
	trigger_gamePanelInfo.mapWidgetVis_shopBootsGlow = false
	trigger_gamePanelInfo:Trigger(false)
end)

object:GetWidget('tutorialObjectiveList'):RegisterWatch('tutorial_shopForceListView', function(widget)
	local gamePanelInfo	= LuaTrigger.GetTrigger('gamePanelInfo')
	gamePanelInfo.shopItemView = 1
	gamePanelInfo:Trigger(false)
end)

tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_minimap')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_abilityBarPet')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_pushBar')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_heroInfos')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_shopItemList')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_courierButton')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_portHomeButton')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_shopQuickSlots')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_abilityPanel')
tutorialRegisterGameWidgetVis(object, 'mapWidgetVis_arcadeText')

local function PopulateQuests(objectiveContainerName)
	for i=1,3 do
		local container		= interface:GetWidget('tutorialObjective'..i..objectiveContainerName)

		if (gameTutorial.objectiveDisplayOrder[objectiveContainerName][i]) then
			local buttonPing	= interface:GetWidget('tutorialObjective'..i..objectiveContainerName..'Ping')
			local buttonHelp	= interface:GetWidget('tutorialObjective'..i..objectiveContainerName..'Help')
			local check			= interface:GetWidget('tutorialObjective'..i..objectiveContainerName..'Check')
			local label			= interface:GetWidget('tutorialObjective'..i..objectiveContainerName..'Label')

			local info = gameTutorial.objectiveDisplayOrder[objectiveContainerName][i]
			info.orderIndex = i

			label:SetText(Translate(info.label, 'countLeft', info.completedCount, 'countMax', info.completionCount))

			if info.pingScriptValue then
				buttonPing:SetVisible(true)
				buttonPing:SetCallback('onclick', function(widget)
					print('clicked objective ping button.\n')
					widget:UICmd("SendScriptMessage('"..info.pingScriptValue.."', 1)")
				end)
				buttonPing:DoEventN(9)
			else
				buttonPing:SetVisible(false)
			end

			if info.extraInfo then
				buttonHelp:SetVisible(true)
				buttonHelp:SetCallback('onclick', function(widget)
					print('clicked objective help button.\n')
					Trigger(info.extraInfo)
				end)
			else
				buttonHelp:SetVisible(false)
			end

			check:SetVisible(info.complete)

			if container then
				container:SetVisible(1)
			end
		else
			if container then
				container:SetVisible(0)
			end
		end
	end

	-- set the order index on tips above 3 (if they are pushed off)
	if ((#(gameTutorial.objectiveDisplayOrder[objectiveContainerName])) > 3) then
		for i=4, (#(gameTutorial.objectiveDisplayOrder[objectiveContainerName])) do
			gameTutorial.objectiveDisplayOrder[objectiveContainerName][i].orderIndex = i
		end
	end
end

function tutorialRegisterObjective(objectiveInfo)
	local objectiveContainer
	local objectiveList
	local objectiveContainerName
	if objectiveInfo.objectiveContainer then
		objectiveContainer	= interface:GetWidget(objectiveInfo.objectiveContainer)
		objectiveContainerName = objectiveInfo.objectiveContainer
	else
		objectiveContainer	= interface:GetWidget('tutorialObjectiveList')
		objectiveContainerName = 'tutorialObjectiveList'
	end

	if objectiveInfo.objectiveList then
		objectiveList	= interface:GetWidget(objectiveInfo.objectiveList)
	else
		objectiveList	= interface:GetWidget('tutorialObjectiveList')
	end

	if not (gameTutorial.activeObjectives[objectiveContainerName] and type(gameTutorial.activeObjectives[objectiveContainerName]) == 'table') then
		gameTutorial.activeObjectives[objectiveContainerName] = {}
	end
	if not (gameTutorial.objectiveDisplayOrder[objectiveContainerName] and type(gameTutorial.objectiveDisplayOrder[objectiveContainerName]) == 'table') then
		gameTutorial.objectiveDisplayOrder[objectiveContainerName] = {}
	end

	objectiveContainer:RegisterWatch(objectiveInfo.showEvent, function(widget) -- , ...
		objectiveInfo.completionCount = objectiveInfo.completionCount or 1
		objectiveInfo.index				= gameTutorial.objectiveIndex
		objectiveInfo.completedCount	= 0
		objectiveInfo.complete 			= false
		if objectiveInfo.showOptions == nil then
			objectiveInfo.showOptions = true
		end
		objectiveInfo.orderIndex = (#gameTutorial.objectiveDisplayOrder[objectiveContainerName]) + 1

		objectiveContainer:SetVisible(true)

		if gameTutorial.initWidgetSoundEnabled then
			PlaySound('/ui/sounds/sfx_quest.wav', 0.7, 9)
		end

		gameTutorial.activeObjectives[objectiveContainerName][objectiveInfo.showEvent] = true
		table.insert(gameTutorial.objectiveDisplayOrder[objectiveContainerName], objectiveInfo.orderIndex, objectiveInfo)

		-- remove the oldest quests beyond 3 quests
		-- while (#(gameTutorial.objectiveDisplayOrder[objectiveContainerName]) > 3) do
		-- 	table.remove(gameTutorial.objectiveDisplayOrder[objectiveContainerName], 4)
		-- end
		-- don't do this, old quests that fall off will reappear at the bottom

		objectiveContainer:RegisterWatch(objectiveInfo.completionEvent, function(widget) -- , ...
			if (gameTutorial.activeObjectives[objectiveContainerName][objectiveInfo.showEvent]) then
				objectiveInfo.completedCount = objectiveInfo.completedCount + 1

				if objectiveInfo.completedCount >= objectiveInfo.completionCount then
					objectiveInfo.complete = true

					if (objectiveInfo.orderIndex <= 3) then
						local container = interface:GetWidget('tutorialObjective'..objectiveInfo.orderIndex..objectiveContainerName)
						local check	= interface:GetWidget('tutorialObjective'..objectiveInfo.orderIndex..objectiveContainerName..'Check')

						check:SetVisible(1)
						container:FadeOut(1000)
						container:Sleep(1000, function()
							-- remove the quest from the table
							table.remove(gameTutorial.objectiveDisplayOrder[objectiveContainerName], objectiveInfo.orderIndex)
							gameTutorial.activeObjectives[objectiveContainerName][objectiveInfo.showEvent] = nil
							local hasRemainingObjectives = false
							for k,v in pairs(gameTutorial.activeObjectives[objectiveContainerName]) do
								hasRemainingObjectives = true
							end

							if hasRemainingObjectives then
								objectiveContainer:SetVisible(true)
							else
								objectiveContainer:SetVisible(false)
							end

							PopulateQuests(objectiveContainerName)
						end)
					else
						table.remove(gameTutorial.objectiveDisplayOrder[objectiveContainerName], objectiveInfo.orderIndex)
						gameTutorial.activeObjectives[objectiveContainerName][objectiveInfo.showEvent] = nil
						PopulateQuests(objectiveContainerName)
					end
				else
					PopulateQuests(objectiveContainerName)
				end
			end
		end)

		gameTutorial.objectiveIndex = gameTutorial.objectiveIndex + 1

		PopulateQuests(objectiveContainerName)
	end)
end

--Message Functions

function tutorialShowMessage(messageInfo, value)
	local messageBG 			= interface:GetWidget('tutorialMessageBG')
	local message				= interface:GetWidget('tutorialMessageContents')
	local messageTitle			= interface:GetWidget('tutorialMessageTitle')
	local messageBody			= interface:GetWidget('tutorialMessageBody')
	local messageIcon			= interface:GetWidget('tutorialMessageIcon')
	local messageModel
	local messageModelGroup		= interface:GetGroup('tutorialMessageModels')
	local messageModelSpace		= interface:GetWidget('tutorialMessageModelSpace')
	local messageTextSpace		= interface:GetWidget('tutorialMessageTextSpace')
	local messageIconSpace		= interface:GetWidget('tutorialMessageIconSpace')
	local messageContinue		= interface:GetWidget('tutorialMessageContinueContainer')
	local messageForceHeight	= interface:GetWidget('tutorialMessageForceHeight')

	-- playSoundOnShowTutorialMessage
	-- PlaySound('/path_to/file.wav')
	
	if value and tonumber(value) then	
		if (tonumber(value) > 0) then
			messageInfo.showTime = tonumber(value)
		end
	end

	if not messageInfo.showTime or messageInfo.showTime <= 0 then
		messageInfo.showTime = 0
		messageInfo.pause = true
	end

	if messageInfo.forceHeight then
		messageForceHeight:SetHeight(libGeneral.HtoP(messageInfo.forceHeight))
	else
		messageForceHeight:SetHeight(libGeneral.HtoP(3))
	end

	if messageInfo.model then
		messageModel = interface:GetWidget(messageInfo.model)
		for k,v in ipairs(messageModelGroup) do
			if v:GetName() ~= messageInfo.model then
				v:SetVisible(false)
			end
		end

		messageModelSpace:SetVisible(true)
		messageModel:SetVisible(true)
		messageIconSpace:SetVisible(false)
		messageTextSpace:SetWidth('-90@')
		-- messageModel:SetModel(messageInfo.model)
		if messageInfo.anim then
			messageModel:SetAnim(messageInfo.anim)
		end

		--[[
		if messageInfo.modelScale then
			messageModel:SetModelScale(messageInfo.modelScale)
		else
			messageModel:SetModelScale(1)
		end

		if messageInfo.modelAngles then
			messageModel:SetModelOrientation(unpack(messageInfo.modelAngles))
		else
			messageModel:SetModelOrientation(0, 0, 0)
		end

		if messageInfo.modelPosition then
			messageModel:SetModelPosition(unpack(messageInfo.modelPosition))
		else
			messageModel:SetModelPosition(0, 0, 0)
		end
		--]]

		--[[
		if messageInfo.cameraPos then
			messageModel:SetCameraPos(unpack(messageInfo.cameraPos))
		else
			messageModel:SetCameraPos(0, 90, 105)
		end

		if messageInfo.cameraAngles then
			messageModel:SetCameraAngles(unpack(messageInfo.cameraAngles))
		else
			messageModel:SetCameraAngles(0, 0, 180)
		end

		if messageInfo.cameraFov then
			messageModel:SetCameraFov(messageInfo.cameraFov)
		else
			messageModel:SetCameraFov(22)
		end

		if messageInfo.cameraNear then
			messageModel:SetCameraNear(messageInfo.cameraNear)
		else
			messageModel:SetCameraNear(1)
		end

		if messageInfo.cameraFar then
			messageModel:SetCameraFar(messageInfo.cameraFar)
		else
			messageModel:SetCameraFar(100)
		end

		if messageInfo.sunAzimuth then
			messageModel:SetSunAzimuth(messageInfo.sunAzimuth)
		else
			messageModel:SetSunAzimuth(130)
		end

		if messageInfo.sunAltitude then
			messageModel:SetSunAltitude(messageInfo.sunAltitude)
		else
			messageModel:SetSunAltitude(20)
		end

		if messageInfo.sunColor then
			messageModel:SetSunColor(unpack(messageInfo.sunColor))
		else
			messageModel:SetSunColor(0.9, 0.8, 0.8)
		end

		if messageInfo.ambientColor then
			messageModel:SetAmbientColor(unpack(messageInfo.ambientColor))
		else
			messageModel:SetAmbientColor(1, 1, 1)
		end

		if messageInfo.lookAt ~= nil then
			messageModel:SetLookAt(messageInfo.lookAt)
		else
			messageModel:SetLookAt(false)
		end
		--]]

		--[[
			Set model propertahs
		--]]
	elseif messageInfo.icon then

		for k,v in ipairs(messageModelGroup) do
			v:SetVisible(false)
		end

		messageIcon:SetTexture(messageInfo.icon)
		messageModelSpace:SetVisible(false)
		messageIconSpace:SetVisible(true)
		messageTextSpace:SetWidth('-100@')
	else

		for k,v in ipairs(messageModelGroup) do
			v:SetVisible(false)
		end

		messageIconSpace:SetVisible(false)
		messageModelSpace:SetVisible(false)
		messageTextSpace:SetWidth('+0.75h')
	end

	if messageInfo.title then
		messageTitle:SetText(Translate(messageInfo.title))
	end

	if messageInfo.body then
		messageBody:SetText(Translate(messageInfo.body))
	end

	message:FadeIn(250)
	tutorialMessageStatus.tutorialMessageVis = true
	tutorialMessageStatus:Trigger(false)

	if messageInfo.darkenBG then
		messageBG:FadeIn(250)
	else
		messageBG:FadeOut(250)
	end

	if messageInfo.pause then
		tutorialPauseTrigger.hidePaused = true
		tutorialPauseTrigger:Trigger(true)
		Cmd("ServerPause")
		messageBG:SetNoClick(false)
	else
		messageBG:SetNoClick(true)
	end

	messageContinue:SetVisible(messageInfo.pause or messageInfo.showContinue)

	if messageInfo.showTime > 0 then
		message:Sleep(messageInfo.showTime, tutorialHideMessage)
	end

	if messageInfo.sound and string.len(messageInfo.sound) > 0 then
		interface:UICmd("StopSound(6)")
		interface:UICmd("StopSound(7)")
		interface:UICmd("StopSound(8)")
		PlayStream(messageInfo.sound, 1, 6, 0)	-- [vol 0-1], [channel]
	end

	if messageInfo.grayscale then
		Cvar.GetCvar('vid_postEffectPath'):Set('/core/post/grayscale.posteffect')
	else
		Cvar.GetCvar('vid_postEffectPath'):Set('')
	end
end

function tutorialShowMessage2(messageInfo, value)
	local messageBG 			= interface:GetWidget('tutorialMessage2BG')
	local message				= interface:GetWidget('tutorialMessage2Contents')
	local messageTitle			= interface:GetWidget('tutorialMessage2Title')
	local messageBody			= interface:GetWidget('tutorialMessage2Body')
	local messageImage			= interface:GetWidget('tutorialMessage2Image')
	local messageModel
	local messageImageSpace		= interface:GetWidget('tutorialMessage2ImageSpace')
	local messageImageSize		= interface:GetWidget('tutorialMessage2ImageSize')
	local messageContinue		= interface:GetWidget('tutorialMessage2ContinueContainer')
	local messageHotkeyContainer		= interface:GetWidget('tutorialMessage2HotkeyContainer')

	-- playSoundOnShowTutorialMessage2
	-- PlaySound('/path_to/file.wav')

	message:SetCallback('onhide', function(widget)
		if messageInfo.hideScriptValue and string.len(messageInfo.hideScriptValue) > 0 then
			widget:UICmd("SendScriptMessage('"..messageInfo.hideScriptValue.."', 1)")
		end
	end)
	
	if value and tonumber(value) then
		if (tonumber(value) > 0) then
			messageInfo.showTime = tonumber(value)
		end
	end

	if not messageInfo.showTime or messageInfo.showTime <= 0 then
		messageInfo.showTime = 0
		messageInfo.pause = true
	end

	if messageInfo.image then

		local imageHeight = libGeneral.HtoP(messageInfo.imageHeight) or libGeneral.HtoP(6)
		local imageWidth = libGeneral.HtoP(messageInfo.imageWidth) or imageHeight or libGeneral.HtoP(6)
		local imageSpaceHeight = libGeneral.HtoP(messageInfo.imageSpaceHeight) or imageHeight or libGeneral.HtoP(6)
		messageImageSize:SetWidth(imageWidth)
		messageImageSize:SetHeight(imageHeight)
		messageImage:SetTexture(messageInfo.image)
		messageImageSpace:SetHeight(imageSpaceHeight)
		messageImageSpace:SetVisible(true)
	else
		messageImageSpace:SetVisible(false)
	end

	if messageInfo.title then
		messageTitle:SetText(Translate(messageInfo.title))
	end

	if messageInfo.body then
		messageBody:SetText(Translate(messageInfo.body))
	end

	message:FadeIn(250)
	tutorialMessageStatus.tutorialMessage2Vis = true
	tutorialMessageStatus:Trigger(false)

	if messageInfo.darkenBG then
		messageBG:FadeIn(250)
	else
		messageBG:FadeOut(250)
	end

	if messageInfo.pause then
		tutorialPauseTrigger.hidePaused = true
		tutorialPauseTrigger:Trigger(true)
		Cmd("ServerPause")
		messageBG:SetNoClick(false)
	else
		messageBG:SetNoClick(true)
	end

	messageContinue:SetVisible(messageInfo.pause or messageInfo.showContinue)

	if messageInfo.showTime > 0 then
		message:Sleep(messageInfo.showTime, tutorialHideMessage2)
	end

	if messageInfo.sound and string.len(messageInfo.sound) > 0 then
		interface:UICmd("StopSound(6)")
		interface:UICmd("StopSound(7)")
		interface:UICmd("StopSound(8)")
		PlayStream(messageInfo.sound, 1, 8, 0)	-- [vol 0-1], [channel]
	end

	if messageInfo.grayscale then
		Cvar.GetCvar('vid_postEffectPath'):Set('/core/post/grayscale.posteffect')
	else
		Cvar.GetCvar('vid_postEffectPath'):Set('')
	end
	
	if messageHotkeyContainer and messageHotkeyContainer:IsValid() then
		messageHotkeyContainer:ClearChildren()
		if messageInfo.hotKeyInfo then
			for n = 1, #messageInfo.hotKeyInfo do
				local info = messageInfo.hotKeyInfo[n]
				messageHotkeyContainer:InstantiateAndReturn('tipFloatingKeyLabel', 'x', info.x, 'y', info.y, 'content', info.content, 'style', info.style)
			end
		end
	end
end

function tutorialHideMessage()
	gameTutorial.activeMessage = nil
	tutorialMessageStatus.tutorialMessageVis = false
	tutorialMessageStatus:Trigger(false)
	interface:GetWidget('tutorialMessageBG'):FadeOut(250)
	interface:GetWidget('tutorialMessageContents'):FadeOut(250)
	interface:UICmd("StopSound(6)")
	Cvar.GetCvar('vid_postEffectPath'):Set('')
end

function tutorialHideMessage2()
	interface:GetWidget('tutorialMessage2BG'):FadeOut(250)
	interface:GetWidget('tutorialMessage2Contents'):FadeOut(250)
	interface:UICmd("StopSound(8)")
	Cvar.GetCvar('vid_postEffectPath'):Set('')

	gameTutorial.activeMessage2 = nil
	tutorialMessageStatus.tutorialMessage2Vis = false
	tutorialMessageStatus:Trigger(false)
end


function tutorialRegisterChatEvent(chatInfo)
	if chatInfo.event and string.len(chatInfo.event) > 0 then
		interface:RegisterWatch(chatInfo.event, function(widget)
			chatInfo.relation = chatInfo.relation or 1
			AllStrifeChatMessages(
				widget,
				{
					channel			= '',		-- Unused
					entityName		= chatInfo.entity,
					message			= Translate(chatInfo.message),
					playerIndex		= 0,
					senderName		= Translate(chatInfo.sender),
					senderRelation	= chatInfo.relation,			-- Team
					timestamp		= '00:00',	-- We don't actually use this.
					type			= 3,
				}
			)
		end)
	else
		print('^960Error:^w Attempted to create a tutorial chat message entry with no event.\n')
	end
end

function tutorialRegisterMessage(messageInfo)
	local event = messageInfo.event
	if event and string.len(event) > 0 then
		local eventTrigger = UITrigger.GetTrigger(event)
		if eventTrigger then
			interface:RegisterWatch(event, function(widget, param, value)
				tutorialShowMessage(messageInfo, value)
				gameTutorial.activeMessage = event
			end)
		else
			print('^960Error:^w Attempted to create a tutorial entry with nonexistent event ^069'..event..'^w.\n')
		end
	else
		print('^960Error:^w Attempted to create a tutorial entry with no event.\n')
	end
end

function tutorialRegisterMessage2(messageInfo)
	local event = messageInfo.event
	if event and string.len(event) > 0 then
		local eventTrigger = UITrigger.GetTrigger(event)
		if eventTrigger then
			interface:RegisterWatch(event, function(widget, param, value)
				tutorialShowMessage2(messageInfo, value)
				gameTutorial.activeMessage2 = event
			end)
		else
			print('^960Error:^w Attempted to create a tutorial entry with nonexistent event ^069'..event..'^w.\n')
		end
	else
		print('^960Error:^w Attempted to create a tutorial entry with no event.\n')
	end
end

--Play Sound Functions

function tutorialRegisterSound(soundInfo)
	local event = soundInfo.event
	if event and string.len(event) > 0 then
		local eventTrigger = UITrigger.GetTrigger(event)
		if eventTrigger then
			interface:RegisterWatch(event, function(widget, value)
				tutorialPlaySound(soundInfo)
			end)
		else
			print('^960Error:^w Attempted to create a tutorial entry with nonexistent event ^069'..event..'^w.\n')
		end
	else
		print('^960Error:^w Attempted to create a tutorial entry with no event.\n')
	end
end

function tutorialPlaySound(soundInfo)
	if soundInfo.sound and string.len(soundInfo.sound) > 0 then
		interface:UICmd("StopSound(6)")
		interface:UICmd("StopSound(7)")
		interface:UICmd("StopSound(8)")
		PlayStream(soundInfo.sound, 0.9, 7, 0)	-- [vol 0-1], [channel]
	end
end

--Tip Functions

local function getTutorialStringHotkey(keyAction, keyParam)
	local hotkey = GetKeybindButton('game', keyAction, keyParam, 0)

	if keyAction == 'ActivateTool' then
		hotkey = hotkey or GetKeybindButton('game', 'QuickActivateTool', keyParam, 0)
	end

	if keyAction == 'QuickActivateTool' then
		hotkey = hotkey or GetKeybindButton('game', 'ActivateTool', keyParam, 0)
	end

	return hotkey or ''
end

function tutorialShowTip(tipInfo, value)
	local tipBG 		= interface:GetWidget('tutorialTipBG')
	local tip			= interface:GetWidget('tutorialTipContents')
	local tipBody		= interface:GetWidget('tutorialTipBody')
	local tipTextSpace	= interface:GetWidget('tutorialTipTextSpace')

	-- playSoundOnShowTutorialTip
	-- PlaySound('/path_to/file.wav')
	
	if value and tonumber(value) then	
		if (tonumber(value) > 0) then
			tipInfo.showTime = tonumber(value)
		end
	end

	if not tipInfo.showTime or tipInfo.showTime <= 0 then
		tipInfo.showTime = 0
	end

	local hotkey1	= ''
	local hotkey2	= ''


	if tipInfo.hotkey1Action and tipInfo.hotkey1Param then
		hotkey1 = getTutorialStringHotkey(tipInfo.hotkey1Action, tipInfo.hotkey1Param)
	end

	if tipInfo.hotkey2Action and tipInfo.hotkey2Param then
		hotkey2 = getTutorialStringHotkey(tipInfo.hotkey2Action, tipInfo.hotkey2Param)
	end

	if tipInfo.body then
		tipBody:SetText(Translate(tipInfo.body, 'hotkey1', hotkey1, 'hotkey2', hotkey2))
	end

	tip:FadeIn(250)

	tutorialMessageStatus.tutorialTipVis = true
	tutorialMessageStatus:Trigger(false)

	if tipInfo.showTime > 0 then
		tip:Sleep(tipInfo.showTime, tutorialHideTip)
	end

	tip:RegisterWatch(tipInfo.hideTipEvent, function(widget)
		tutorialHideTip()
	end)

	if tipInfo.sound and string.len(tipInfo.sound) > 0 then
		interface:UICmd("StopSound(6)")
		interface:UICmd("StopSound(7)")
		interface:UICmd("StopSound(8)")
		PlayStream(tipInfo.sound, 0.7, 7, 0)	-- [vol 0-1], [channel]
	end

end

function tutorialHideTip()
	gameTutorial.activeTip = nil
	tutorialMessageStatus.tutorialTipVis = false
	tutorialMessageStatus:Trigger(false)

	interface:GetWidget('tutorialTipBG'):FadeOut(250)
	interface:GetWidget('tutorialTipContents'):FadeOut(250)
	interface:UICmd("StopSound(7)")
end

function tutorialRegisterTip(tipInfo)
	local event = tipInfo.event
	if event and string.len(event) > 0 then
		local eventTrigger = UITrigger.GetTrigger(event)
		if eventTrigger then
			interface:RegisterWatch(event, function(widget, param, value)
				tutorialShowTip(tipInfo, value)
				gameTutorial.activeTip = event
			end)
		else
			print('^960Error:^w Attempted to create a tutorial entry with nonexistent event ^069'..event..'^w.\n')
		end
	else
		print('^960Error:^w Attempted to create a tutorial entry with no event.\n')
	end
end

interface:GetWidget('tutorialMessageContinue'):SetCallback('onclick', function(widget)
	tutorialHideMessage()
	Cmd("ServerUnpause")
	tutorialPauseTrigger.hidePaused = false
	tutorialPauseTrigger:Trigger(true)
end)
interface:GetWidget('tutorialMessageBG'):SetCallback('onclick', function(widget)
	tutorialHideMessage()
	Cmd("ServerUnpause")
	tutorialPauseTrigger.hidePaused = false
	tutorialPauseTrigger:Trigger(true)
end)

interface:GetWidget('tutorialMessage2Continue'):SetCallback('onclick', function(widget)
	tutorialHideMessage2()
	Cmd("ServerUnpause")
	tutorialPauseTrigger.hidePaused = false
	tutorialPauseTrigger:Trigger(true)
end)

--[[
interface:GetWidget('tutorialMessage2BG'):SetCallback('onclick', function(widget)
	tutorialHideMessage2()
	Cmd("ServerUnpause")
end)
--]]


local tutorial_shopStatus = LuaTrigger.CreateCustomTrigger('tutorial_shopStatus', {
	{ name	= 'shopOpen', 	type	= 'boolean'},
	{ name	= 'abilityPanel', 	type	= 'boolean'},
})

tutorial_shopStatus.shopOpen			= false
tutorial_shopStatus.abilityPanel		= false
tutorial_shopStatus:Trigger(true)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatchLua('tutorial_shopStatus', function(widget, trigger)
	if trigger.shopOpen then
		print('shop 1\n')
		widget:UICmd("SendScriptMessage('ui_shopOpen', '1')")
	else
		print('shop 0\n')
		-- widget:UICmd("SendScriptMessage('ui_shopOpen', '0')")
		widget:UICmd("SendScriptMessage('ui_shopClose', '1')")
	end
end, false, nil, 'shopOpen')

interface:GetWidget('tutorialScriptWidget2'):RegisterWatchLua('tutorial_shopStatus', function(widget, trigger)
	if trigger.abilityPanel then
		print('ability 1\n')
		widget:UICmd("SendScriptMessage('ui_levelUpPanelOpen', '1')")
	else
		print('ability 0\n')
		-- widget:UICmd("SendScriptMessage('ui_levelUpPanelOpen', '0')")
		widget:UICmd("SendScriptMessage('ui_levelUpPanelClose', '1')")
	end
end, false, nil, 'abilityPanel')

interface:GetWidget('tutorialScriptWidget1'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)
	if trigger.abilityPanel and trigger.shopOpen then
		tutorial_shopStatus.abilityPanel = true
		tutorial_shopStatus:Trigger(false)
	else
		tutorial_shopStatus.abilityPanel = false
		tutorial_shopStatus:Trigger(false)
	end

end, false, nil, 'abilityPanel', 'shopOpen')

interface:GetWidget('tutorialScriptWidget2'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)
	if trigger.shopOpen and not trigger.abilityPanel then
		tutorial_shopStatus.shopOpen = true
		tutorial_shopStatus:Trigger(false)
	else
		tutorial_shopStatus.shopOpen = false
		tutorial_shopStatus:Trigger(false)
	end
end, false, nil, 'shopOpen', 'abilityPanel')

local function getShopButtonFromSlotData(slotData)
	local useWidget
	if type(slotData) == 'table' then
		useWidget = shopGetWidget('gameShopItemListRow'..slotData[1]..'Item'..slotData[2]..'Button')
	elseif (slotData) then
		useWidget = shopGetWidget('gameShopItemListItem'..slotData..'Button')
	end

	return useWidget
end

local function getShopButton(index)
	local slotData = gameShopGetItemSlotID(index)

	return getShopButtonFromSlotData(slotData)
end

local function shopGetComponentButton(slotData, componentID)
	local rowID

	if componentID == 4 then
		componentID = 'Scroll'
	end

	if type(slotData) == 'table' then
		rowID = slotData[1]
	else
		rowID = slotData
	end

	return shopGetWidget('gameShopItemSelectedRow'..rowID..'Item'..componentID..'Button')
end

for i=0,5,1 do
	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_darkenWidgetShopItem'..i, function(widget)
		darkenAroundWidget(getShopButton(i))
	end)

	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spotlightWidgetShopItem'..i, function(widget)
		spotlightWidget(getShopButton(i), true)
	end)

	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_pointWidgetShopItem'..i, function(widget)
		pointAtWidget(getShopButton(i))
	end)
end

for i=1,4,1 do
	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_darkenWidgetShopComponent'..i, function(widget)
		local slotData = gameShopGetItemSlotID(LuaTrigger.GetTrigger('gamePanelInfo').selectedShopItem)
		darkenAroundWidget(shopGetComponentButton(slotData, i))
	end)

	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spotlightWidgetShopComponent'..i, function(widget)
		local slotData = gameShopGetItemSlotID(LuaTrigger.GetTrigger('gamePanelInfo').selectedShopItem)
		spotlightWidget(shopGetComponentButton(slotData, i), true)
	end)

	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_pointWidgetShopComponent'..i, function(widget)
		local slotData = gameShopGetItemSlotID(LuaTrigger.GetTrigger('gamePanelInfo').selectedShopItem)
		pointAtWidget(shopGetComponentButton(slotData, i))
	end)
end

local function tutorialSetupStashPlaceholder()
	local stashButtons	= {}
	for i=128,133,1 do
		table.insert(stashButtons, gameGetWidget('gameInventory'..i..'Button'))
	end

	table.insert(stashButtons, shopGetWidget('gameShopStashLabel'))

	widgetHighlightPlacePlaceholder(stashButtons, true)
end

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_SpotlightPetAbility', function(widget)
	spotlightWidget(gameGetWidget('gameInventory18Backer'), true)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_PointAtPetAbility', function(widget)
	pointAtWidget(gameGetWidget('gameInventory18Backer'))
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_DarkenAroundPetAbility', function(widget)
	darkenAroundWidget(gameGetWidget('gameInventory18Backer'))
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_SpotlightStash', function(widget)
	tutorialSetupStashPlaceholder()
	spotlightWidget(widgetHighlightGetPlaceholder(), true)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_PointAtStash', function(widget)
	tutorialSetupStashPlaceholder()
	pointAtWidget(widgetHighlightGetPlaceholder())
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_DarkenAroundStash', function(widget)
	-- tutorialSetupStashPlaceholder()
	-- darkenAroundWidget(widgetHighlightGetPlaceholder())
	darkenAroundWidget(shopGetWidget('gameShopStashContainer'))
end)

local function tutorialSetUpComponentPlaceholder()
	local componentButtons = {}

	local slotData = gameShopGetItemSlotID(LuaTrigger.GetTrigger('gamePanelInfo').selectedShopItem)

	for i=1,3,1 do
		table.insert(componentButtons, shopGetComponentButton(slotData, i))
	end

	widgetHighlightPlacePlaceholder(componentButtons)
end

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spotlightWidgetShopComponents', function(widget)
	tutorialSetUpComponentPlaceholder()
	spotlightWidget(widgetHighlightGetPlaceholder(), true)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_pointWidgetShopComponents', function(widget)
	tutorialSetUpComponentPlaceholder()
	pointAtWidget(widgetHighlightGetPlaceholder())
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_darkenWidgetShopComponents', function(widget)
	tutorialSetUpComponentPlaceholder()
	darkenAroundWidget(widgetHighlightGetPlaceholder())
end)

function tutorial_registerForceOpenEntity(entityName)
	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_forceSelect_Item_Gauntlet', function(widget)
		if entityName and string.len(entityName) > 0 then
			local slotIndex = -1
			local itemInfo
			for i=0,100,1 do
				itemInfo = LuaTrigger.GetTrigger('ShopItem'..i)
				if itemInfo.exists and itemInfo.entity == entityName then
					slotIndex = i
					break
				end
			end
			if slotIndex >= 0 then
				trigger_gamePanelInfo.selectedShopItem = slotIndex
				trigger_gamePanelInfo.selectedShopItemType = ''
				trigger_gamePanelInfo:Trigger(false)
			else
				print('')
			end
		end
	end)
end

function tutorial_registerPointAtShopEntity(entityName)
	if entityName and string.len(entityName) > 0 then
		interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_pointWidgetShop_'..entityName, function(widget)
			local slotData = gameShopGetItemSlotIDFromEntity(entityName)
			pointAtWidget(getShopButtonFromSlotData(slotData))
		end)
	end
end

function tutorial_registerSpotlightShopEntity(entityName)
	if entityName and string.len(entityName) > 0 then
		interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spotlightWidgetShop_'..entityName, function(widget)
			local slotData = gameShopGetItemSlotIDFromEntity(entityName)
			spotlightWidget(getShopButtonFromSlotData(slotData), true)
		end)
	end
end

function tutorial_registerDarkenShopEntity(entityName)
	if entityName and string.len(entityName) > 0 then
		interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_darkenWidgetShop_'..entityName, function(widget)
			local slotData = gameShopGetItemSlotIDFromEntity(entityName)
			darkenAroundWidget(getShopButtonFromSlotData(slotData))

		end)
	end
end


function tutorial_registerPointAtInventory(index, suffix)
	suffix = suffix or ''
	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_PointAtInventory'..index..suffix, function(widget)
		pointAtWidget(gameGetWidget('gameInventory'..index..suffix..'Container'))
	end)
end

function tutorial_registerSpotlightInventory(index, suffix)
	suffix = suffix or ''
	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_SpotlightInventory'..index..suffix, function(widget)
		spotlightWidget(gameGetWidget('gameInventory'..index..suffix..'Container'), true)
	end)
end

function tutorial_registerDarkenInventory(index, suffix)
	suffix = suffix or ''
	interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_DarkenAroundInventory'..index..suffix, function(widget)
		darkenAroundWidget(gameGetWidget('gameInventory'..index..suffix..'Container'))
	end)
end

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_PointAtLevelUpButton', function(widget)
	pointAtWidget(gameGetWidget('abilitiesLevelUpButton'))
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_SpotlightLevelUpButton', function(widget)
	spotlightWidget(gameGetWidget('abilitiesLevelUpButton'), true)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_DarkenAroundLevelUpButton', function(widget)
	darkenAroundWidget(gameGetWidget('abilitiesLevelUpButton'))
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_PointAtGoldContainer', function(widget)
	pointAtWidget(gameGetWidget('gameHeroGoldContainer'))
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_SpotlightGoldContainer', function(widget)
	spotlightWidget(gameGetWidget('gameHeroGoldContainer'), true)
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_DarkenAroundGoldContainer', function(widget)
	darkenAroundWidget(gameGetWidget('gameHeroGoldContainer'))
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_pointWidgetHide', function(widget) pointAtWidgetStop() end)
interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spotlightWidgetHide', function(widget) spotlightWidget() end)
interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_darkenWidgetHide', function(widget) darkenAroundWidget() end)

interface:GetWidget('tutorialPromptLockCam'):RegisterWatch('tutorial_promptLockCameraShow', function(widget)
	widget:FadeIn(250)
end)

interface:GetWidget('tutorialPromptLockCam'):RegisterWatch('tutorial_promptLockCameraHide', function(widget)
	widget:FadeOut(250)
end)

interface:GetWidget('tutorialPromptLockCamYes'):SetCallback('onclick', function(widget)
	Cmd("ServerUnpause")
	-- widget:UICmd("SendScriptMessage('tutorialLockCamYes', 1)")
	interface:GetWidget('tutorialPromptLockCam'):FadeOut(250)
	Cvar.GetCvar('cam_mode'):Set('2')
end)

interface:GetWidget('tutorialPromptLockCamNo'):SetCallback('onclick', function(widget)
	Cmd("ServerUnpause")
	-- widget:UICmd("SendScriptMessage('tutorialLockCamNo', 1)")
	interface:GetWidget('tutorialPromptLockCam'):FadeOut(250)
	Cvar.GetCvar('cam_mode'):Set('0')
end)


interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_closeShop', function(widget)
	widget:UICmd("CloseShop()")
end)

for i=0,3,1 do
	object:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_darkenWidgetAbilityPanel'..i, function(widget)
		local abilityView = LuaTrigger.GetTrigger('gamePanelInfo').abilityPanelView
		local useWidget
		if abilityView == 0 then
			useWidget = gameGetWidget('abilityLevelUpEntry'..i..'ButtonSimple')
		else
			useWidget = gameGetWidget('abilityLevelUpEntry'..i..'Button')
		end
		darkenAroundWidget(useWidget)
	end)

	object:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_spotlightWidgetAbilityPanel'..i, function(widget)
		local abilityView = LuaTrigger.GetTrigger('gamePanelInfo').abilityPanelView
		local useWidget
		if abilityView == 0 then
			useWidget = gameGetWidget('abilityLevelUpEntry'..i..'ButtonSimple')
		else
			useWidget = gameGetWidget('abilityLevelUpEntry'..i..'Button')
		end
		spotlightWidget(useWidget, true)
	end)

	object:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_pointWidgetAbilityPanel'..i, function(widget)
		local abilityView = LuaTrigger.GetTrigger('gamePanelInfo').abilityPanelView
		local useWidget
		if abilityView == 0 then
			useWidget = gameGetWidget('abilityLevelUpEntry'..i..'ButtonSimple')
		else
			useWidget = gameGetWidget('abilityLevelUpEntry'..i..'Button')
		end
		pointAtWidget(useWidget)
	end)
end

interface:GetWidget('tutorialExitButton'):SetCallback('onclick', function(widget)
	Client.FinishGame()
end)

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_endTutorial', function(widget, trigger)
	interface:GetWidget('tutorialPromptExit'):FadeIn(500)
	widget:Sleep(30000, function()
		local tutorialProgressRequest = LuaTrigger.GetTrigger('setTutorialProgressStatus')

		if tutorialProgressRequest and (not tutorialProgressRequest.busy) and tutorialProgressRequest.lastStatus ~= 2 then
			Client.FinishGame()
		end
	end)
end)

interface:GetWidget('tutorialExitButton'):RegisterWatchLua('setTutorialProgressStatus', function(widget, trigger)
	widget:SetEnabled((not trigger.busy) and trigger.lastStatus ~= 2)
end)

interface:GetWidget('newPlayerExperience_saveIndicator_tutorial'):RegisterWatchLua('setTutorialProgressStatus', function(widget, trigger)
	libGeneral.fade(widget, (trigger.busy and trigger.lastStatus == 1), 250)
end)

--[[
	0	Do nothing (assume regular lobby / hero select)
	1	Rook /w Tortus
	2	Moxie /w Mystic
	3	Hale /w Tortus
	4	Vermillion /w Tortus
	5	Minerva /w Tortus
--]]

interface:GetWidget('tutorialScriptWidget1'):RegisterWatch('tutorial_getTutorialHeroPet', function(widget)
	local tutorial3_preselect = Cvar.GetCvar('tutorial3_preselect')
	local tutorial3PreselectOption = 0
	if tutorial3_preselect then
		tutorial3PreselectOption = tutorial3_preselect:GetNumber()
	end

	widget:UICmd("SendScriptMessage('tutorial3preselect', '"..tostring(tutorial3PreselectOption).."')")

end)

-- ===================================================================================

local function PopulateHints()
	for i=1,3 do
		local container		= interface:GetWidget('tutorialHint'..i)

		if (gameTutorial.hintDisplayOrder[i]) then
			local button	= interface:GetWidget('tutorialHint'..i..'Button')
			local icon		= interface:GetWidget('tutorialHint'..i..'Icon')
			local label1	= interface:GetWidget('tutorialHint'..i..'Label1')
			local label2	= interface:GetWidget('tutorialHint'..i..'Label2')
			local glow		= interface:GetWidget('tutorialHint'..i..'Glow')

			local info = gameTutorial.hintDisplayOrder[i]

			info.orderIndex = i

			label1:SetText(info.label1)
			label2:SetText(info.label2)
			icon:SetTexture(info.icon)

			if (info.glow) then
				glow:SetVisible(1)
				info.glowEndTime = Game.GetTotalTime() + 5000

				glow:Sleep(5000, function()
					glow:FadeOut(100)
				end)

				info.glow = false
			elseif (Game.GetTotalTime() < info.glowEndTime) then
				local timeDiff = info.glowEndTime - Game.GetTotalTime()

				glow:SetVisible(1)
				glow:Sleep(timeDiff, function()
					glow:FadeOut(100)
				end)
			else
				glow:Sleep(1, function() end)
				glow:SetVisible(0)
			end

			-- setup events
			if info.extraInfo then
				local extraInfoEvent = UITrigger.GetTrigger(info.extraInfo)

				if extraInfoEvent then
					button:SetCallback('onclick', function(widget)
						glow:Sleep(1, function() glow:SetVisible(false) end)
						extraInfoEvent:Trigger()
					end)
				end
			else
				if info.alternateScriptValue and string.len(info.alternateScriptValue) > 0 then
					button:SetCallback('onclick', function(widget)
						widget:UICmd("SendScriptMessage('"..info.alternateScriptValue.."', 1)")
					end)
				end
			end

			container:SetVisible(1)
		else
			container:SetVisible(0)
		end
	end

	-- set the order index on tips above 3 (if they are pushed off)
	if ((#(gameTutorial.hintDisplayOrder)) > 3) then
		for i=4, (#(gameTutorial.hintDisplayOrder)) do
			gameTutorial.hintDisplayOrder[i].orderIndex = i
		end
	end
end

function tutorialRegisterHint(hintInfo)
	local hintContainer		= interface:GetWidget('tutorialHintContainer')

	hintContainer:RegisterWatch(hintInfo.showEvent, function(widget)
		hintInfo.index				= gameTutorial.hintIndex

		hintInfo.icon				= hintInfo.icon or ''	-- Pref a default icon?

		hintInfo.label1				= hintInfo.label1 or ''
		hintInfo.label2				= hintInfo.label2 or ''

		hintInfo.label1				= Translate(hintInfo.label1)
		hintInfo.label2				= Translate(hintInfo.label2)

		hintInfo.orderIndex			= 1
		hintInfo.glow 				= true

		if not gameTutorial.activeHints[hintInfo.showEvent] then
			table.insert(gameTutorial.hintDisplayOrder, 1, hintInfo)

			-- remove the oldest tips beyond 3 tips
			-- while (#(gameTutorial.hintDisplayOrder) > 3) do
			-- 	table.remove(gameTutorial.hintDisplayOrder, 4)
			-- end
			-- don't do this, old tips that fall off will reappear at the bottom

			-- playSoundOnShowTutorialHint
			-- PlaySound('/ui/sounds/sfx_tip.wav')
			PlaySound('/ui/sounds/sfx_tip.wav', 0.7, 9)

			gameTutorial.hintIndex = gameTutorial.hintIndex + 1

			gameTutorial.activeHints[hintInfo.showEvent] = true

			hintContainer:RegisterWatch(hintInfo.hideEvent, function(widget)
				if (hintInfo.orderIndex <= 3) then
					local container = interface:GetWidget("tutorialHint"..hintInfo.orderIndex)
					container:FadeOut(1000)

					container:Sleep(1000, function()
						gameTutorial.activeHints[hintInfo.showEvent] = false

						-- remove the hint from the table
						table.remove(gameTutorial.hintDisplayOrder, hintInfo.orderIndex)
						PopulateHints()
					end)
				else
					table.remove(gameTutorial.hintDisplayOrder, hintInfo.orderIndex)
					gameTutorial.activeHints[hintInfo.showEvent] = false

					-- call populate to update the order indexes
					PopulateHints()
				end
			end)

			PopulateHints()
		end
	end)
end

-- ==============================

local movieEscTextbox		= object:GetWidget('movieEscTextbox')
local videoWidget			= object:GetWidget('videowidget')

if movieEscTextbox and videoWidget then

	local function skipTutorialVideo()
		videoWidget:StopMovie()
	end

	movieEscTextbox:SetCallback('onlosefocus', function(widget)
		skipTutorialVideo()
	end)

end

-- ==============================

function tutorialReinitialize(object)
	object:GetWidget('tutorialBlackOverlay'):Sleep(1, function()

		gameTutorial.initWidgetSoundEnabled = false

		if not gameTutorial.blackOverlayVisible then
			object:GetWidget('tutorialBlackOverlay'):SetVisible(false)
			local movieEscTextbox = object:GetWidget('movieEscTextbox')
			if movieEscTextbox then
				movieEscTextbox:SetVisible(false)
			end

		end

		for k,v in pairs(gameTutorial.activeObjectives) do
			if type(v) == 'table' then
				PopulateQuests(k)
			end
		end

		if gameTutorial.activeMessage then
			UITrigger.GetTrigger(gameTutorial.activeMessage):Trigger()
			printr('triggered active message '..gameTutorial.activeMessage..'\n')
		end

		if gameTutorial.activeMessage2 then
			UITrigger.GetTrigger(gameTutorial.activeMessage2):Trigger()
			printr('triggered active message2 '..gameTutorial.activeMessage2..'\n')
		end

		if gameTutorial.activeTip then
			UITrigger.GetTrigger(gameTutorial.activeTip):Trigger()
			printr('triggered active tip '..gameTutorial.activeTip..'\n')
		end

		PopulateHints()

		gameTutorial.initWidgetSoundEnabled = true
	end)
end
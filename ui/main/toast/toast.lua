local interface = object
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
Toasts						= {}

local ToastsTrigger = LuaTrigger.CreateCustomTrigger('PartyPlayerInfo0Test',
	{
		{ name	= 'isTalking',				type	= 'bool' },
	}
)


function PopulateToastSlot(object, index)
	local widgets		= socialEntry.getEntryWidgets(object, 'toastEntry'..index)
	local isWaiting		= object:GetWidget('toastEntry'..index..'IsWaiting')
	local userName		= widgets.userName
	local userGroup		= widgets.userGroup
	local userDarken	= widgets.userDarken
	
	local isSelf = (index == 0)

	local playerInfo				= LuaTrigger.GetTrigger('PartyPlayerInfo' .. index)
	local socialPanelInfo			= LuaTrigger.GetTrigger('socialPanelInfo')
	local socialPanelInfoHovering	= LuaTrigger.GetTrigger('socialPanelInfoHovering')

	if (not playerInfo) then
		isWaiting:SetVisible(0)
		widgets.userIcon:SetTexture('/ui/shared/textures/account_icons/default.tga')
		userName:SetVisible(1)
		userName:SetText(Translate('party_empty_slot_host'))
		userName:SetColor('.4 .4 .4 1')
		userName:SetHeight('100%')
		userGroup:SetText('')
		return
	end

	if (playerInfo.isTalking) then
		widgets.VOIP:SetVisible(1)
		widgets.VOIPIcon1:SetVisible(1)
		widgets.VOIPIcon2:SetVisible(1)
	else
		widgets.VOIP:SetVisible(0)
		widgets.VOIPIcon1:SetVisible(0)
		widgets.VOIPIcon2:SetVisible(0)	
	end
	
	local playerIsWaiting = (playerInfo.playerName and (not Empty(playerInfo.playerName)) and (not playerInfo.isLocalPlayer))
	
	libGeneral.fade(isWaiting, playerIsWaiting, socialEntry.actionItemSlideTime)

	if (playerInfo.isReady) then
		isWaiting:SetTexture('/ui/main/party/textures/icon_ready.tga')
	else
		isWaiting:SetTexture('/ui/main/party/textures/icon_waiting.tga')
	end

	local slotIsOccupied = (playerInfo.playerName and (not Empty(playerInfo.playerName)) and (not playerInfo.isLocalPlayer))

	if (playerInfo.playerName) and (not Empty(playerInfo.playerName)) then
		if (playerInfo.heroIconPath) and (not Empty(playerInfo.heroIconPath)) then
			widgets.userIcon:SetTexture(playerInfo.heroIconPath)
		elseif (playerInfo.accountIconPath) and (not Empty(playerInfo.accountIconPath)) then
			widgets.userIcon:SetTexture(playerInfo.accountIconPath)
		else
			widgets.userIcon:SetTexture('/ui/shared/textures/account_icons/default.tga')
		end

		widgets.userIcon:SetColor('1 1 1 1')
	else
		widgets.userIcon:SetColor('1 1 1 .7')
		widgets.userIcon:SetTexture('/ui/shared/textures/drag_target.tga')
	end

	if (playerInfo.playerName) and (not Empty(playerInfo.playerName)) then
		userName:SetVisible(1)
		userName:SetHeight('50%')

		local playerName = playerInfo.playerName

		if (mainUI.savedRemotely.friendDatabase) and (mainUI.savedRemotely.friendDatabase[playerInfo.identID]) and (mainUI.savedRemotely.friendDatabase[playerInfo.identID].nicknameOverride) then
			playerName = mainUI.savedRemotely.friendDatabase[playerInfo.identID].nicknameOverride
		end

		if (ClientInfo.duplicateUsernameTable[playerName]) then
			if (not IsInTable(ClientInfo.duplicateUsernameTable[playerName], playerInfo.playerUniqueID)) then
				tinsert(ClientInfo.duplicateUsernameTable[playerName], playerInfo.playerUniqueID)
			end
		else
			ClientInfo.duplicateUsernameTable[playerName] = {playerInfo.playerUniqueID}
		end
		if (#ClientInfo.duplicateUsernameTable[playerName] > 1)	then
			if (playerInfo.isPending) then
				userName:SetText('('.. playerName .. ' ' .. playerInfo.playerUniqueID ..')')
				userName:SetColor('.7 .7 .7 1')
			else
				userName:SetText(playerName .. ' ' .. playerInfo.playerUniqueID)
				userName:SetColor('1 1 1 1')
			end
		else
			if (playerInfo.isPending) then
				userName:SetText('('..playerName..')')
				userName:SetColor('.7 .7 .7 1')
			else
				userName:SetText(playerName)
				userName:SetColor('1 1 1 1')
			end
		end
		if (playerInfo.isPending) then
			userGroup:SetText(Translate('general_pending_invite'))
			userGroup:SetColor('.4 .4 .4 1')
		else
			userGroup:SetText(Translate('general_strife_beta'))
			-- userGroup:SetText(playerInfo.playerGroup)
			userGroup:SetColor('.8 .8 .8 1')
		end
	else
		userName:SetVisible(1)
		userName:SetText(Translate('party_empty_slot_host'))
		userName:SetColor('.4 .4 .4 1')
		userName:SetHeight('100%')
		userGroup:SetText('')
	end

	userGroup:SetVisible(((playerInfo.playerName) and (not Empty(playerInfo.playerName))) or false)

end

local function PartyVOIPToastRegister(index)
	local widget = GetWidget('voip_party_toast_' .. index)
	
	local widgetsParty		= socialEntry.getEntryWidgets(object, 'partyEntry'..index)
	local widgetsTeam		= socialEntry.getEntryWidgets(object, 'playTeamEntry'..index)
	local widgetsToast		= socialEntry.getEntryWidgets(object, 'toastEntry'..index)
	
	local topOffset = 50
	local fromTopOffset = 25
	
	local function AnimateIn(widget)
		widget:SetY(((-1 * topOffset) + (fromTopOffset + (index * 40))) .. 's')
		widget:SetX('180s')
		
		widget:SlideY((fromTopOffset + (index * 40)) .. 's', 250)
		widget:SlideX('-5s', 250)
		
		widget:FadeIn(150)
	end
	
	local function AnimateOut(widget)
		widget:SlideY(((-1 * topOffset) + (fromTopOffset + (index * 40))) .. 's', 250)
		widget:SlideX('180s', 250)
		
		widget:FadeOut(250)
	end		
	
	if (VoiceClient) then
		widget:RegisterWatchLua('PartyPlayerInfo' .. index, function(widget, trigger)
			if (trigger.isTalking) and (not widgetsParty.userButton:IsVisible()) and (not widgetsTeam.userButton:IsVisible()) then
				if (not widget:IsVisible()) then
					AnimateIn(widget)
				end		
				local widgets		= socialEntry.getEntryWidgets(widget, 'toastEntry' .. index)
				widgets.VOIP:SetVisible(1)
				widgets.VOIPIcon1:SetVisible(1)
				widgets.VOIPIcon2:SetVisible(1)
			else
				if (widget:IsVisible()) then
					AnimateOut(widget)			
				end				
			end
		end, false, nil, 'isTalking')
	end
	
end
	
local function ToastRegister()	
	for index = 0,4,1 do
		PartyVOIPToastRegister(index)
	end
end
ToastRegister()

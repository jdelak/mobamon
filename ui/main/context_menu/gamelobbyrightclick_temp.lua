Lobby = Lobby or {}
Lobby.selectedTeam				= nil

local function lobbyRightClickMenuColorRegister(object, index)
	local button		= object:GetWidget('lobbyRightClickMenuColor'..index)
	local buttonBody	= object:GetWidget('lobbyRightClickMenuColor'..index..'Body')
	local teamID		= 1
	if index >= 5 then teamID = 2 end
	
	button:RegisterWatchLua('LobbyTeamInfo'..teamID, function(widget, trigger)
		local teamSlotIndex = index - ((teamID - 1) * 5)
		widget:SetVisible(
			(teamSlotIndex + 1) <= trigger.maxPlayers
		)
	end, false, nil, 'maxPlayers')
	
	button:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		local slotTeam = libGeneral.getSlotTeam(index)
		local slotIndex = libGeneral.getTeamSlotIndex(slotTeam, index)
		local playerTeam = Lobby.selectedTeam or libGeneral.getSlotTeam(getLobbySelectedSlot())
		local playerIndex = libGeneral.getTeamSlotIndex(playerTeam, getLobbySelectedSlot())

		RequestSwapPlayerSlots(playerTeam, playerIndex, slotTeam, slotIndex)
		
		lobbyRightClickClose()
	end)

end

local function lobbyRightClickRegister(object, index)
	local container					= object:GetWidget('lobbyRightClickMenu')
	local body						= object:GetWidget('lobbyRightClickMenuBody')
	local closeButton				= object:GetWidget('lobbyRightClickMenuClose')

	local selectedPlayer			= ''
	local selectedSlot				= 0
	local selectedIdentID			= ''

	function getLobbySelectedSlot()
		return selectedSlot
	end
	
	function lobbyRightClickOpen(newSelectedPlayer, newSelectedSlot, team, identID)
		selectedPlayer	= newSelectedPlayer
		selectedSlot	= newSelectedSlot
		selectedIdentID	= identID
		Lobby.selectedTeam	= team
		println('Lobby.selectedTeam ' .. tostring(Lobby.selectedTeam))
		container:SetX(
			math.min(
				GetScreenWidth() - container:GetWidth(),
				Input.GetCursorPosX() - libGeneral.HtoP(4)
			)
		)
		
		container:SetY(
			math.min(
				GetScreenHeight() - container:GetHeight(),
				Input.GetCursorPosY() - libGeneral.HtoP(4)
			)
		)
		
		container:SetVisible(true)
	end
	
	function lobbyRightClickClose()
		container:SetVisible(false)
	end
	
	
	for i=0,9,1 do
		lobbyRightClickMenuColorRegister(object, i)
	end

	
	object:GetWidget('lobbyRightClickHost'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		RequestAssignHost(selectedIdentID)
		lobbyRightClickClose()
	end)
	
	-- object:GetWidget('lobbyRightClickReferee'):SetCallback('onclick', function(widget)
		-- PlaySound('/ui/sounds/sfx_button_generic.wav')
		-- PromoteRef(selectedIdentID)
		-- lobbyRightClickClose()
	-- end)

	object:GetWidget('lobbyRightClickSpectator'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		-- RequestAssignSpectator(selectedIdentID)
	
		local playerIndex = libGeneral.getTeamSlotIndex(Lobby.selectedTeam, getLobbySelectedSlot())

		RequestSwapPlayerSlots(Lobby.selectedTeam, playerIndex, 0, 0)	
		
		lobbyRightClickClose()
	end)
	
	object:GetWidget('lobbyRightClickKick'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Kick(selectedIdentID)
		lobbyRightClickClose()
	end)
	
	closeButton:SetCallback('onclick', function(widget)
		lobbyRightClickClose()
	end)
	
	container:SetCallback('onclick', function(widget)
		lobbyRightClickClose()
	end)
	
	body:SetCallback('onclick', function(widget)
		lobbyRightClickClose()
	end)
	
	container:SetCallback('onmouseover', function(widget)
		lobbyRightClickClose()
	end)
end

lobbyRightClickRegister(object)
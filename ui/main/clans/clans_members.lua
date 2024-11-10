local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind, len, lower, gsub = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind, _G.string.len, _G.string.lower, _G.string.gsub

local interfaceName = object:GetName()
local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}

local playerTemplateWidth = '208s' -- '98s' '298s' '208s'
local playerTemplateHeight = '40s' -- '98s' '298s' '208s'
local headerTemplateWidth = '100%' 
local headerTemplateHeight = '28s'
local headerTemplateHeightDouble = '48s'
local updateClanMemberlistThread

local function GetContextMenuTrigger()
	if (interfaceName == 'friends') then
		ContextMenuMultiWindowTrigger.activeMultiWindowWindow = 'friends'
		return LuaTrigger.GetTrigger('ContextMenuMultiWindowTrigger'), 'ContextMenuMultiWindowTrigger'
	elseif (interfaceName == 'main') then
		return LuaTrigger.GetTrigger('ContextMenuTrigger'), 'ContextMenuTrigger'
	end
end

local function mouseInArea(x, y, width, height)
	if (interfaceName == 'friends') then
		local cursorPosX, cursorPosY = Windows.Friends:GetCursorPos()
		return (
			cursorPosX >= x and cursorPosX < (x + width) and
			cursorPosY >= y and cursorPosY < (y + height)
		)
	elseif (interfaceName == 'main') then
		local cursorPosX = Input.GetCursorPosX()
		local cursorPosY = Input.GetCursorPosY()

		return (
			cursorPosX >= x and cursorPosX < (x + width) and
			cursorPosY >= y and cursorPosY < (y + height)
		)		
	end
end

local function mouseInWidgetArea(areaWidget)	-- Allows for custom button functionality, various other interactive widgets (often for mouse L/R up, which needs to occur off the widget)
	return mouseInArea(
		areaWidget:GetAbsoluteX(),
		areaWidget:GetAbsoluteY(),
		areaWidget:GetWidth(),
		areaWidget:GetHeight()
	)
end

local function RegisterClansMembers(object)
	
	-- println('RegisterClansMembers 1/2')

	local clans_friendlist_scrollbar 			= interface:GetWidget('clans_friendlist_scrollbar')
	local clans_friendlist_friendlist_parent 	= interface:GetWidget('clans_friendlist_friendlist_parent')
	local clans_friendlist 						= interface:GetWidget('clans_friendlist')

	function mainUI.Clans.IAmInClan()
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		return (myChatClientInfo) and (myChatClientInfo.clanID) and (myChatClientInfo.clanID ~= '')
	end
	
	function mainUI.Clans.IsInMyClan(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)
		return (myChatClientInfo) and (myChatClientInfo.clanID) and (theirChatClientInfo) and (theirChatClientInfo.clanID) and (myChatClientInfo.clanID == theirChatClientInfo.clanID) and (myChatClientInfo.clanID ~= '')
	end
	
	function mainUI.Clans.CanSetOwner(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)		
		if (mainUI.Clans.IsInMyClan(identID)) then
			return (myChatClientInfo) and (myChatClientInfo.clanRank) and (theirChatClientInfo.clanRank) and (myChatClientInfo.clanRank > theirChatClientInfo.clanRank) and (theirChatClientInfo.clanRank == mainUI.Clans.rankEnum.COOWNER) and (myChatClientInfo.clanRank >= mainUI.Clans.rankEnum.OWNER)
		else
			return false
		end
	end
	
	function mainUI.Clans.CanPromote(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)		
		if (mainUI.Clans.IsInMyClan(identID)) then
			return (myChatClientInfo) and (myChatClientInfo.clanRank) and (theirChatClientInfo.clanRank) and (myChatClientInfo.clanRank > (theirChatClientInfo.clanRank + 1)) and (theirChatClientInfo.clanRank < mainUI.Clans.rankEnum.COOWNER)
		else
			return false
		end
	end
	
	function mainUI.Clans.CanDemote(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)		
		if (mainUI.Clans.IsInMyClan(identID)) then
			return (myChatClientInfo) and (myChatClientInfo.clanRank) and (theirChatClientInfo.clanRank) and (myChatClientInfo.clanRank > theirChatClientInfo.clanRank) and (theirChatClientInfo.clanRank > 0)
		else
			return false
		end
	end
	
	function mainUI.Clans.CanKick(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)		
		if (mainUI.Clans.IsInMyClan(identID)) then
			return (myChatClientInfo) and (myChatClientInfo.clanRank) and (theirChatClientInfo.clanRank) and (myChatClientInfo.clanRank > theirChatClientInfo.clanRank)
		else
			return false
		end
	end
	
	function mainUI.Clans.CanInvite(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)	
		if (mainUI.Clans.IsInMyClan(identID)) then
			return false
		else
			return (myChatClientInfo) and (theirChatClientInfo) and (theirChatClientInfo.clanJoinStatus) and (theirChatClientInfo.clanJoinStatus ~= 1) and (theirChatClientInfo.clanID == nil or theirChatClientInfo.clanID == '' or theirChatClientInfo.clanID == '0.000') and (myChatClientInfo.clanRank) and (myChatClientInfo.clanRank >= mainUI.Clans.rankEnum.OFFICER)
		end
	end
	
	function mainUI.Clans.IsPendingInvite(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)		
		return (myChatClientInfo) and (theirChatClientInfo.clanJoinStatus) and (theirChatClientInfo.clanJoinStatus == 1) -- clanJoinStatus 1 for pending, 0 for member
	end
	
	function mainUI.Clans.CanApprovePendingInvites()
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		return (myChatClientInfo) and (myChatClientInfo.clanRank) and (myChatClientInfo.clanRank >= mainUI.Clans.rankEnum.OFFICER)
	end
	
	function mainUI.Clans.CanEditTopic()
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		return (myChatClientInfo) and (myChatClientInfo.clanRank) and ((myChatClientInfo.clanRank >= mainUI.Clans.rankEnum.OFFICER) or myChatClientInfo.clanRank == -1) -- RMM
	end
	
	function mainUI.Clans.CanManageClan()
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		return (myChatClientInfo) and (myChatClientInfo.clanRank) and ((myChatClientInfo.clanRank >= mainUI.Clans.rankEnum.COOWNER) or myChatClientInfo.clanRank == -1) -- RMM
	end
	
	function mainUI.Clans.CanRejectPendingInvites()
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		return (myChatClientInfo) and (myChatClientInfo.clanRank) and (myChatClientInfo.clanRank >= mainUI.Clans.rankEnum.OFFICER)
	end
	
	function mainUI.Clans.PromptSetOwner(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)
		if (theirChatClientInfo and theirChatClientInfo.clanRank) then
			GenericDialogAutoSize(
				'clans_prompt_promoteowner_title', '', Translate('clans_prompt_promoteowner_desc', 'value', theirChatClientInfo.name, 'value2', Translate('clans_prompt_rank_label_' .. (theirChatClientInfo.clanRank + 1))), 'clans_prompt_promoteowner_confirm', 'general_cancel',
					function() mainUI.Clans.SetClanOwner(identID) end,
					function() end
			)			
		end
	end
	
	function mainUI.Clans.PromptPromote(identID)
		println('mainUI.Clans.PromptPromote ' .. tostring(identID))
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)
		if (theirChatClientInfo and theirChatClientInfo.clanRank) then
			GenericDialogAutoSize(
				'clans_prompt_promote_title', '', Translate('clans_prompt_promote_desc', 'value', theirChatClientInfo.name, 'value2', Translate('clans_prompt_rank_label_' .. (theirChatClientInfo.clanRank + 1))), 'clans_prompt_promote_confirm', 'general_cancel',
					function() mainUI.Clans.Promote(identID) end,
					function() end
			)	
		else
			println('no')
		end
	end
	
	function mainUI.Clans.PromptDemote(identID)
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		local theirChatClientInfo = GetClientInfoTrigger(identID)
		if (theirChatClientInfo and theirChatClientInfo.clanRank) then
			GenericDialogAutoSize(
				'clans_prompt_demote_title', '', Translate('clans_prompt_demote_desc', 'value', theirChatClientInfo.name, 'value2', Translate('clans_prompt_rank_label_' .. (theirChatClientInfo.clanRank - 1))), 'clans_prompt_demote_confirm', 'general_cancel',
					function() mainUI.Clans.Demote(identID) end,
					function() end
			)
		end
	end
	
	function mainUI.Clans.PromptKick(identID)
		local theirChatClientInfo = GetClientInfoTrigger(identID)
		GenericDialogAutoSize(
			'clans_prompt_kick_title', '', Translate('clans_prompt_kick_desc', 'value', theirChatClientInfo.name), 'clans_prompt_kick_confirm', 'general_cancel',
				function() mainUI.Clans.Kick(identID) end,
				function() end
		)		
		return false
	end
	
	function mainUI.Clans.SetClanOwner(identID)
		return ChatClient.SetClanOwner(identID)
	end
	
	function mainUI.Clans.Promote(identID)
		return ChatClient.PromoteClanMember(identID)
	end
	
	function mainUI.Clans.Demote(identID)
		return ChatClient.DemoteClanMember(identID)
	end
	
	function mainUI.Clans.Kick(identID, reason)
		return ChatClient.KickFromClan(identID, reason or '')
	end
	
	function mainUI.Clans.ClanInvite(identID)
		return ChatClient.InviteToClan(identID)
	end
	
	function mainUI.Clans.ApprovePendingInvite(identID)
		return ChatClient.AcceptClanJoinRequest(identID)
	end
	
	function mainUI.Clans.RejectPendingInvite(identID, reason)
		return ChatClient.RejectClanJoinRequest(identID, reason or '')
	end
	
	function mainUI.Clans.RejectClanInvite(clanID)
		return ChatClient.RejectClanInvite(clanID)
	end
	
	function mainUI.Clans.AcceptClanInvite(clanID)
		return ChatClient.RequestJoinClan(clanID)
	end	
	
	local function ToggleGroupExpanded(displayGroup, postUpdateCallback)
		mainUI.savedRemotely.clanGroupExpanded = mainUI.savedRemotely.clanGroupExpanded or {}
		mainUI.savedRemotely.clanGroupExpanded[displayGroup] = not mainUI.savedRemotely.clanGroupExpanded[displayGroup]
		mainUI.Clans.UpdateClanMemberlist(nil, postUpdateCallback)
	end	
	
	local function HeaderClicked(self, index, displayGroup)
		local function postUpdateCallback()
			if (index) then
				local arrow = GetWidget('socialclient_im_header_row_template' .. index .. '_arrow')
				if (arrow) and (arrow:IsValid()) then
					if (mainUI.savedRemotely) and (mainUI.savedRemotely.clanGroupExpanded) and (mainUI.savedRemotely.clanGroupExpanded[displayGroup]) then
						arrow:SetRotation(-180, 150)
						arrow:Rotate(0, 150)
					else
						arrow:SetRotation(0, 150)
						arrow:Rotate(-180, 150)
					end	
				end
			end
		end		
		ToggleGroupExpanded(displayGroup, postUpdateCallback)	
	end

	local function HeaderOnMouseOver(index, displayGroup)
		-- println('HeaderOnMouseOver displayGroup ' .. tostring(displayGroup))
	end	
	
	local function HeaderOnMouseOut(index, displayGroup)
		-- println('HeaderOnMouseOut displayGroup ' .. tostring(displayGroup))
	end		
	
	local function RegisterHeader(self, index, displayGroup)
		libThread.threadFunc(function()
			wait(1)		
			if (self) and (self:IsValid()) then
				local parent 			= interface:GetWidget('clans_friendslist_header_row_template' .. index)
				local arrow 			= interface:GetWidget('clans_friendslist_header_row_template' .. index .. '_arrow')
				local label 			= interface:GetWidget('clans_friendslist_header_row_template' .. index .. '_label')
				local countLabel 		= interface:GetWidget('clans_friendslist_header_row_template' .. index .. '_count_label')

				self:SetCallback('onclick', function(widget, trigger)
					HeaderClicked(widget, index, displayGroup)
				end)	
				self:SetCallback('ondoubleclick', function(widget, trigger)

				end)
				self:SetCallback('onrightclick', function(widget, trigger)
					HeaderClicked(widget, index, displayGroup)
				end)		
				self:SetCallback('onmouseover', function(widget, trigger)
					HeaderOnMouseOver(widget, index, displayGroup)
					UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, spendGems = false })
				end)	
				self:SetCallback('onmouseout', function(widget, trigger)
					HeaderOnMouseOut(widget, index, displayGroup)
					UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, spendGems = false })
				end)	
			end
		end)
	end	
	
	local function RegisterFriend(targetFriend, identID, rowIndex)
		
		local parentWidget					= GetWidget('clans_friend_longmode_template' .. rowIndex)
		
		local function WatchAndUpdateFriendItem(identID)

			local friendsClientInfoTrigger = GetClientInfoTrigger(identID)
			
			local function UpdateFriendItem(trigger)
				if (friendsClientInfoTrigger == nil) or (friendsClientInfoTrigger.name == '') then
					println("^r Clan RegisterFriend Error: invalid or no friendsClientInfoTrigger for " .. tostring(identID))
					
					if (not interface) or (not interface:IsValid()) then
						-- println('^r Clan RegisterFriend Error: interface is invalid ' .. tostring(targetFriend) .. ' ' .. tostring(identID) .. ' ' .. tostring(rowIndex))
					else

						local bgWidget						= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_bg')
						local hoverWidget					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_hover')
						local hoverOutlineWidget			= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_hoverOutline')
						local nameWidget 					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_profile_name')
						local voipWidget 					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_voip')
						local accountIconHoverWidget		= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_profile_id_hover')
						local medalsLabel					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_medals')
						-- local clanSealsLabel				= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_clanseals')
						local btn_invite					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_invite')
						local btn_accept					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_accept')
						local btn_spectate					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_spectate')
						local btn_sent						= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_sent')
						local iconParent					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_parent')
						local btn_approve					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_approve')
						local btn_reject					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_reject')
						
						if (bgWidget) and (bgWidget:IsValid()) and (btn_approve) and (btn_reject) and (hoverWidget) and (hoverOutlineWidget) and (nameWidget) and (voipWidget) and (accountIconHoverWidget) and (medalsLabel) and (btn_invite) and (btn_accept) and (btn_spectate) and (btn_sent) then 					
							btn_spectate:SetVisible(0)
							btn_accept:SetVisible(0)
							btn_invite:SetVisible(0)
							btn_sent:SetVisible(0)	
							btn_approve:SetVisible(0)
							btn_reject:SetVisible(0)
							nameWidget:SetText(tostring(identID))
							medalsLabel:SetText('')
						end
						
					end
					
				else
					
					if (not interface) or (not interface:IsValid()) then
						-- println('^r Clan RegisterFriend Error: interface is invalid ' .. tostring(targetFriend) .. ' ' .. tostring(identID) .. ' ' .. tostring(rowIndex))
						return
					end
					
					local bgWidget						= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_bg')
					local hoverWidget					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_hover')
					local hoverOutlineWidget			= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_hoverOutline')
					local nameWidget 					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_profile_name')
					local voipWidget 					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_voip')
					local accountIconHoverWidget		= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_profile_id_hover')
					local medalsLabel					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_medals')
					-- local clanSealsLabel				= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_clanseals')
					local btn_invite					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_invite')
					local btn_accept					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_accept')
					local btn_spectate					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_spectate')
					local btn_sent						= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_sent')
					local iconParent					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_parent')
					local btn_approve					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_approve')
					local btn_reject					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex .. '_btn_reject')
					
					if (bgWidget) and (bgWidget:IsValid()) and (btn_approve) and (btn_reject) and (hoverWidget) and (hoverOutlineWidget) and (nameWidget) and (voipWidget) and (accountIconHoverWidget) and (medalsLabel) and (btn_invite) and (btn_accept) and (btn_spectate) and (btn_sent) then 
					
						local statusColor = '.3 .2 .2 .7'
						local statusText = Translate('friend_online_status_offline')
						local statusIcon = '$checker'
						local userIcon = '/ui/shared/textures/account_icons/default.tga'
						local userIconFrame = '/ui/shared/textures/account_icon_frames/default.tga'
						local userName = '???'
						local userNameColor = 'white'
						local secondaryLabel = '???'
						
						local isOnline = true

						voipWidget:SetVisible(friendsClientInfoTrigger.isTalking)
						iconParent:SetVisible(not friendsClientInfoTrigger.isTalking)
						
						local canApprovePendingInvites = mainUI.Clans.CanApprovePendingInvites()
						
						mainUI.Clans.pendingChallenges = mainUI.Clans.pendingChallenges or {}
						mainUI.Clans.sentChallenges = mainUI.Clans.sentChallenges or {}		
						mainUI.Clans.pendingPartyInvites = mainUI.Clans.pendingPartyInvites or {}		
						
						local friendInfo
						if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
							friendInfo = Friends['main'].GetFriendDataFromIdentID(identID)
						end						
						
						local receivedPersonalChallenge 	= false
						local sentPersonalChallenge 		= false
						local sentClanChallenge 			= false
						local receivedClanChallenge 		= false
						local isMe							= IsMe(identID)
						local canChallenge					= false
						local canAccept						= ((not isMe) and (mainUI.Clans.pendingPartyInvites[identID] ~= nil))
						local showSent						= ((not isMe) and ((friendInfo and friendInfo.isInMyParty) or (GetPartyPlayerDataFromIdentID(identID) ~= nil))) or false
						local isPendingApplicant			= (friendsClientInfoTrigger.clanJoinStatus and friendsClientInfoTrigger.clanJoinStatus == 1)
						local canInviteToParty     	        = ((not LuaTrigger.GetTrigger('PartyStatus').inParty) or (LuaTrigger.GetTrigger('PartyStatus').isPartyLeader)) and (not isMe) and (LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby == false) and (friendsClientInfoTrigger.canPlayCurrentQueue) and (friendsClientInfoTrigger.isOnline) and (not friendsClientInfoTrigger.inParty) and (not friendsClientInfoTrigger.inLobby) and (not friendsClientInfoTrigger.isInGame) and (not friendsClientInfoTrigger.isInLocalGame) and (not friendsClientInfoTrigger.isInQueue)

						if (friendsClientInfoTrigger.isInGame) then
							statusColor = '#e82000' -- red
							statusText = Translate('friend_online_status_ingame')	
							btn_spectate:SetVisible(not friendsClientInfoTrigger.isSpectating)
							btn_accept:SetVisible(0)
							btn_invite:SetVisible(0)
							btn_sent:SetVisible(0)
						elseif (friendsClientInfoTrigger.isOnline) then
							statusColor = '#b7ff00' -- green
							statusText = Translate('friend_online_status_online')		
							btn_spectate:SetVisible(0)
							btn_accept:SetVisible(((not isPendingApplicant) and canAccept) or false)
							btn_invite:SetVisible(((not isPendingApplicant) and canInviteToParty and (not showSent)) or false)		
							btn_sent:SetVisible(((not isPendingApplicant) and showSent) or false)
						else
							statusColor = '0.7 0.7 0.7 0.3' -- faded gray
							statusText = Translate('friend_online_status_offline')		
							isOnline = false
							btn_spectate:SetVisible(0)
							btn_accept:SetVisible(0)
							btn_invite:SetVisible(0)							
							btn_sent:SetVisible(0)							
						end		
						
						btn_approve:SetVisible((isPendingApplicant and canApprovePendingInvites) or false)
						btn_reject:SetVisible((isPendingApplicant and canApprovePendingInvites) or false)
						
						btn_approve:SetCallback('onclick', function(widget)
							mainUI.Clans.ApprovePendingInvite(identID)
						end) 
						btn_approve:SetCallback('onmouseover', function(widget)
							simpleTipGrowYUpdate(true, '/ui/main/notification/textures/challenge0000.tga', Translate('social_action_bar_claninvite_accept'), Translate('social_action_bar_claninvite_accept'), self:GetHeightFromString('340s'))
						end)
						btn_approve:SetCallback('onmouseout', function(widget)
							simpleTipGrowYUpdate(false)
						end)
						
						btn_reject:SetCallback('onclick', function(widget)
							mainUI.Clans.RejectPendingInvite(identID)
						end) 
						btn_reject:SetCallback('onmouseover', function(widget)
							simpleTipGrowYUpdate(true, '/ui/main/notification/textures/challenge0000.tga', Translate('social_action_bar_claninvite_reject'), Translate('social_action_bar_claninvite_reject'), self:GetHeightFromString('340s'))
						end)
						btn_reject:SetCallback('onmouseout', function(widget)
							simpleTipGrowYUpdate(false)
						end)
						
						userName = friendsClientInfoTrigger.name or '?NONAME1?'
						
						-- println('identID ' .. identID .. ' sentClanChallenge ' .. tostring(sentClanChallenge))
						
						-- if (sentClanChallenge) and (sentClanChallenge ~= lastSentClanChallenge) then
							-- if (isMe) then
								-- ChatClient.DispatchMessageToLocalClientWindow(6, 6, '^*You challenged the club!', Translate('chat_club_name'))
							-- else
								-- ChatClient.DispatchMessageToLocalClientWindow(6, 6, '^*' .. userName .. ' challenged the club!') -- ' .. Links.SpawnClanChallengeLink('matchID', identID, userName), Translate('chat_club_name') )
							-- end
						-- end
						
						-- lastSentClanChallenge = sentClanChallenge						
						
						btn_invite:SetCallback('onclick', function(widget)
							ChatClient.PartyInvite(identID)			
							btn_invite:SetVisible(0)
							btn_sent:SetVisible(1)
						end) 
						btn_invite:SetCallback('onmouseover', function(widget)
							simpleTipGrowYUpdate(true, '/ui/main/notification/textures/party.tga', Translate('main_social_groupname_addplayer_party', 'value', userName), Translate('party_finder_no_invites'), self:GetHeightFromString('340s'))
						end)
						btn_invite:SetCallback('onmouseout', function(widget)
							simpleTipGrowYUpdate(false)
						end)
						
						btn_spectate:SetCallback('onclick', function(widget)
							mainUI.SpectateGame(identID)						
						end) 
						btn_spectate:SetCallback('onmouseover', function(widget)
							simpleTipGrowYUpdate(true, '/ui/main/notification/textures/default.tga', Translate('clans_memberlist_request_spectate_desc', 'value', userName), Translate('clans_memberlist_request_spectate_desc'), self:GetHeightFromString('340s'))
						end)
						btn_spectate:SetCallback('onmouseout', function(widget)
							simpleTipGrowYUpdate(false)
						end)

						btn_accept:SetCallback('onclick', function(widget)
							if (mainUI.Clans.pendingPartyInvites[identID]) then
								ChatClient.NotificationAction(mainUI.Clans.pendingPartyInvites[identID].id, mainUI.Clans.pendingPartyInvites[identID].actions[1])
							end
						end) 
						btn_accept:SetCallback('onmouseover', function(widget)
							simpleTipGrowYUpdate(true, '/ui/main/notification/textures/party.tga', Translate('social_action_bar_accept_claninvite'), Translate('party_invite_join_party'), self:GetHeightFromString('340s'))
						end)
						btn_accept:SetCallback('onmouseout', function(widget)
							simpleTipGrowYUpdate(false)
						end)

						if (friendsClientInfoTrigger) and (friendsClientInfoTrigger.isStaff) and (friendsClientInfoTrigger.accountIconPath) and ((friendsClientInfoTrigger.accountIconPath == '/ui/shared/textures/account_icons/default.tga') or (friendsClientInfoTrigger.accountIconPath == 'default')) then
							userIcon = '/ui/shared/textures/account_icons/s2staff.tga'
						elseif (friendsClientInfoTrigger.accountIconPath == 'default') then
							userIcon = '/ui/shared/textures/account_icons/default.tga'
						else
							if friendsClientInfoTrigger.accountIconPath and find(userIcon, '.tga') then
								userIcon = friendsClientInfoTrigger.accountIconPath or '$invis'
							elseif friendsClientInfoTrigger.accountIconPath and (not Empty(friendsClientInfoTrigger.accountIconPath)) then
								userIcon = '/ui/shared/textures/account_icons/' .. friendsClientInfoTrigger.accountIconPath.. '.tga'
							else
								userIcon = '/ui/shared/textures/account_icons/default.tga'
							end
						end
						
						-- if (friendsClientInfoTrigger and friendsClientInfoTrigger.accountIconFramePath) and (not Empty(friendsClientInfoTrigger.accountIconFramePath)) and (friendsClientInfoTrigger.accountIconFramePath ~= 'default') then
							-- userIconFrame = friendsClientInfoTrigger.accountIconFramePath
						-- end

						if (friendsClientInfoTrigger) and (friendsClientInfoTrigger.clanRank >= mainUI.Clans.rankEnum.COOWNER) then
							userNameColor = '#e82000'
						elseif (friendsClientInfoTrigger) and (friendsClientInfoTrigger.clanRank >= mainUI.Clans.rankEnum.OFFICER) then
							userNameColor = '#b7ff00'
						else
							userNameColor = '1 1 1 1'
						end						

						-- if (friendsClientInfoTrigger and friendsClientInfoTrigger.steamID and friendsClientInfoTrigger.steamID ~= '') and (friendsClientInfoTrigger and friendsClientInfoTrigger.identID and friendsClientInfoTrigger.identID == '') then
							-- secondaryLabel = '^666Steam'		
						-- else
							secondaryLabel = friendsClientInfoTrigger.uniqueID or ''							
						-- end
						
						local function setColors ()
							if (isOnline) then
								bgWidget:SetColor('#15375c')
								bgWidget:SetBorderColor('#15375c')
								libAccountIcons.SetColor('1 1 1 1', 'clans_friend_longmode_template'..rowIndex, interface)
								nameWidget:SetColor(userNameColor)
								-- clanSealsLabel:SetColor('white')
								medalsLabel:SetColor('white')
							else
								bgWidget:SetColor('#15375c3b')
								bgWidget:SetBorderColor('#15375c3b')
								nameWidget:SetColor(1, 1, 1, 0.3)
								libAccountIcons.SetColor('1 1 1 0.3', 'clans_friend_longmode_template'..rowIndex, interface)	
								-- clanSealsLabel:SetColor(1, 1, 1, 0.3)
								medalsLabel:SetColor(1, 1, 1, 0.3)
							end	
						end

						nameWidget:SetText(userName)

						medalsLabel:SetText((math.ceil(friendsClientInfoTrigger.rating or 0) + 1500) or '0')
						
						-- clanSealsLabel:SetText('0') -- math.floor(friendsClientInfoTrigger.clanSeals or 0) or 

						accountIconHoverWidget:SetTexture(userIcon)
						
						libAccountIcons.UpdateAccountIcon(userIcon, userIconFrame, 'clans_friend_longmode_template'..rowIndex, interface)
						
						setColors()
						
						local contextTrigger, contextTriggerNameString = GetContextMenuTrigger()
						
						local function mouseOverUpdate()
							if (hoverWidget) and (hoverWidget:IsValid()) then
								hoverWidget:FadeIn(200)
								hoverOutlineWidget:FadeIn(200)
								bgWidget:SetColor('#15375c')
								bgWidget:SetBorderColor('#15375c')
								libAccountIcons.SetColor('1 1 1 1.0', 'clans_friend_longmode_template'..rowIndex, interface)
								nameWidget:SetColor(userNameColor)
								-- clanSealsLabel:SetColor('white')
								medalsLabel:SetColor('white')								
							end					
						end
						
						parentWidget:SetCallback('onmouseover', function(widget)
							if (contextTrigger.contextMenuArea <= 0) then
								mouseOverUpdate()
								UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, spendGems = false, canDrag = false })
							end
							Profile.OpenProfilePreview(identID, true, Translate('clans_prompt_rank_label_' .. (friendsClientInfoTrigger.clanRank or 0)))
						end)	

						local function mouseOutUpdate()
							if (hoverWidget) and (hoverWidget:IsValid()) then
								hoverWidget:FadeOut(100)
								hoverOutlineWidget:FadeOut(100)
								if (not mouseInWidgetArea(parentWidget)) then
									setColors()
								end
							end
						end
						
						parentWidget:SetCallback('onmouseout', function(widget)
							if (contextTrigger.contextMenuArea <= 0) then
								mouseOutUpdate()
							end
							UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, spendGems = false, canDrag = false })
							Profile.CloseProfilePreview()
						end)	
						
						if (contextTrigger) then
							parentWidget:UnregisterWatchLua(contextTriggerNameString)
							parentWidget:RegisterWatchLua(contextTriggerNameString, function(widget, trigger)
								if (((trigger.selectedUserIdentID) and (not Empty(trigger.selectedUserIdentID)))) and (trigger.contextMenuArea > 0) then
									if ((identID == trigger.selectedUserIdentID)) and ((trigger.contextMenuArea == 1) or (trigger.contextMenuArea == 2)) then
										libThread.threadFunc(function()
											wait(1)	
											mouseOverUpdate()
										end)
									else
										mouseOutUpdate()
									end
								else
									mouseOutUpdate()
								end
							end)
						end						
						
						local function AccountIconMouseOut()
							accountIconHoverWidget:ClearCallback('onframe')	
							libAccountIcons.ScaleInPlace('100', 'clans_friend_longmode_template'..rowIndex, interface, true)
							if (not mouseInWidgetArea(parentWidget)) then
								setColors()
							end	
							accountIconHoverWidget:SetNoClick(0)
							if mouseInWidgetArea(parentWidget) then
							
							else
								hoverWidget:FadeOut(100)
								hoverOutlineWidget:FadeOut(100)								
							end
						end
						
						accountIconHoverWidget:SetCallback('onmouseover', function(widget)
							-- println('accountIconHoverWidget onmouseover')
							if (contextTrigger.contextMenuArea <= 0) then
								libAccountIcons.ScaleInPlace('165', 'clans_friend_longmode_template'..rowIndex, interface)
								hoverWidget:FadeIn(200)
								hoverOutlineWidget:FadeIn(200)
								bgWidget:SetColor('#15375c')
								bgWidget:SetBorderColor('#15375c')
								libAccountIcons.SetColor('1 1 1 1.0', 'clans_friend_longmode_template'..rowIndex, interface)
								nameWidget:SetColor(userNameColor)
								accountIconHoverWidget:SetNoClick(1)
								accountIconHoverWidget:ClearCallback('onframe')
								accountIconHoverWidget:SetCallback('onframe', function(widget)
									if mouseInWidgetArea(accountIconHoverWidget) then
									else
										AccountIconMouseOut()
									end
								end)
								UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, spendGems = false, canDrag = false })
							end
						end)	
						
						accountIconHoverWidget:SetCallback('onhide', function(widget)
							AccountIconMouseOut()
						end)

						parentWidget:SetCallback('onclick', function(widget)
							println('onclick ' .. tostring(identID))
							Friends[interfaceName].RightClicked(widget, identID)
						end)
						
						parentWidget:SetCallback('onrightclick', function(widget)
							println('B onrightclick ' .. tostring(identID))
							Friends[interfaceName].RightClicked(widget, identID)
						end)						
					
						return tostring(friendsClientInfoTrigger.isOnline)..tostring(friendsClientInfoTrigger.isInGame)..tostring(friendsClientInfoTrigger.inParty)..tostring(friendsClientInfoTrigger.inLobby)..tostring(friendsClientInfoTrigger.isInLocalGame)..tostring(friendsClientInfoTrigger.isInQueue)..tostring(friendsClientInfoTrigger.clanJoinStatus)..tostring(friendsClientInfoTrigger.clanVoiceChannel)..tostring(friendsClientInfoTrigger.clanRank)
					else
						println('^r Clan memberlist widgets missing for ' .. tostring(identID) .. ' ' .. tostring(rowIndex))
						println('bgWidget ' .. tostring(bgWidget))
						println('hoverWidget ' .. tostring(hoverWidget))
						println('hoverOutlineWidget ' .. tostring(hoverOutlineWidget))
						println('nameWidget ' .. tostring(nameWidget))
						println('voipWidget ' .. tostring(voipWidget))
						println('accountIconHoverWidget ' .. tostring(accountIconHoverWidget))
						println('medalsLabel ' .. tostring(medalsLabel))
						println('btn_invite ' .. tostring(btn_invite))
						println('btn_accept ' .. tostring(btn_accept))
						println('btn_spectate ' .. tostring(btn_spectate))
						println('btn_sent ' .. tostring(btn_sent))
					end
				end
			end
			
			if (friendsClientInfoTrigger) then
				local lastHeaderKey = ''
				libThread.threadFunc(function()
					wait(1)
					UnwatchLuaTriggerByKey(GetClientInfoTriggerName(identID), 'ClanChatClientInfo'..gsub(identID, '%.', ''))
					WatchLuaTrigger(GetClientInfoTriggerName(identID), function(trigger)
						local headerKey = UpdateFriendItem(trigger)
						if (headerKey) and (lastHeaderKey) and (headerKey ~= lastHeaderKey) then
							mainUI.Clans.UpdateClanMemberlist()
						end
						lastHeaderKey = headerKey
					end, 'ClanChatClientInfo'..gsub(identID, '%.', ''), "isTalking", "identID", "isFriend", "isIgnored", "isMuted", "isPending", "name", "status", "uiStatus", "userStatus", "uniqueID", "buddyGroup", "isInGame", "inLobby", "inParty", "isInLocalGame", "isInQueue", "acceptStatus", "isOnline", "clanVoiceChannel", "clanRank", "clanJoinStatus", "isSpectating")

				end)
				lastHeaderKey = UpdateFriendItem(friendsClientInfoTrigger)			
			else
				-- println("^rRegisterFriend 1 Error: no trigger for " .. tostring(identID))
			end						
		end

		WatchAndUpdateFriendItem(identID) 
	end	
	
	local function FriendsScrollRegister(object)
		
		clans_friendlist_scrollbar:SetVisible(1)
		
		mainUI.Clans.UpdateScrollPosition = function(dontAnimate)
			dontAnimate = true
			local SCROLL_Y_AMOUNT_ROW = clans_friendlist:GetHeightFromString(playerTemplateHeight)
			local SCROLL_Y_AMOUNT_HEADER = clans_friendlist:GetHeightFromString(headerTemplateHeightDouble)
			local SCROLL_Y_AMOUNT_PADDING = clans_friendlist:GetHeightFromString('4s')
			local SCROLL_Y_AMOUNT_HIDDEN = clans_friendlist:GetHeightFromString('4s')
			local scrollValue = tonumber(clans_friendlist_scrollbar:GetValue()) or 0
			local maxScrollValue = tonumber(clans_friendlist_scrollbar:GetMaxValue()) or 1

			local friendsListHeight 			= clans_friendlist:GetHeight()
			local friendsListVisibleHeight 		= clans_friendlist_friendlist_parent:GetHeight()
			local maxScrollAmount = math.max(0, (friendsListHeight - friendsListVisibleHeight))

			-- println('friendsListHeight ' .. tostring(friendsListHeight))
			-- println('friendsListVisibleHeight ' .. tostring(friendsListVisibleHeight))
			-- println('maxScrollAmount ' .. tostring(maxScrollAmount))
			
			local scrollAmount = (scrollValue / maxScrollValue) * maxScrollAmount
			if (maxScrollAmount > 0) and (scrollAmount >= -20) then
				clans_friendlist_scrollbar:FadeIn(125)
				clans_friendlist_friendlist_parent:SetWidth('-30s')
				if (dontAnimate) then
					clans_friendlist:SetY((scrollAmount * -1) - clans_friendlist:GetHeightFromString('6s'))
				else
					clans_friendlist:SlideY(((scrollAmount * -1) - clans_friendlist:GetHeightFromString('6s')), 125)
				end
			else
				clans_friendlist_scrollbar:FadeOut(125)
				clans_friendlist_friendlist_parent:SetWidth('100%')
			end
		end
		
		local isUsingHandle = false
		interface:GetWidget('clans_friendlist_scrollbar_slider_handle'):SetCallback('onmouseover', function(widget)
			isUsingHandle = true
		end)	
		clans_friendlist_scrollbar:SetCallback('onmouselup', function(widget)
			isUsingHandle = false
		end)		
		
		clans_friendlist_scrollbar:SetCallback('onslide', function(widget)
			mainUI.Clans.UpdateScrollPosition(isUsingHandle)
		end)
		mainUI.Clans.WheelUp = function()
			isUsingHandle = false
			local scrollValue = tonumber(clans_friendlist_scrollbar:GetValue()) or 0
			clans_friendlist_scrollbar:SetValue( math.max(0, scrollValue - 1) )
			-- Friends.FlagAsInteractionLocked()
		end
		mainUI.Clans.WheelDown = function ()
			isUsingHandle = false
			local scrollValue = tonumber(clans_friendlist_scrollbar:GetValue()) or 0
			local maxScrollValue = tonumber(clans_friendlist_scrollbar:GetMaxValue()) or 1
			clans_friendlist_scrollbar:SetValue( math.min(maxScrollValue, scrollValue + 1) )
			-- Friends.FlagAsInteractionLocked()
		end	

		local clans_friends_scroll_catchers = object:GetGroup('clans_friends_scroll_catchers')
		for _, social_client_scroll_catcher in pairs(clans_friends_scroll_catchers) do
			social_client_scroll_catcher:SetCallback('onmousewheelup', function(widget)
				 isUsingHandle = false
				 mainUI.Clans.WheelUp()
			end)
			social_client_scroll_catcher:SetCallback('onmousewheeldown', function(widget)
				isUsingHandle = false
				mainUI.Clans.WheelDown()
			end)	
		end

	end		
	
	local function UpdateClanMemberlist(inMemberlist, postUpdateCallback)
		
		if (not GetCvarBool('host_islauncher')) then
			-- println('^r Clan UpdateClanMemberlist denied because host_islauncher is : ' .. tostring(host_islauncher))
			return
		end			
	
		if (LuaTrigger.GetTrigger('GamePhase').gamePhase > 0 and LuaTrigger.GetTrigger('GamePhase').gamePhase < 4) then
			-- println('^r Clan UpdateClanMemberlist denied because GamePhase is : ' .. tostring(LuaTrigger.GetTrigger('GamePhase').gamePhase))
			return
		end			
		
		if (not interface) or (not interface:IsValid()) then
			println('UpdateClanMemberlist aborted as interface is nil')
			return
		end		
		
		local clans_friendlist = interface:GetWidget('clans_friendlist')
		
		if (not clans_friendlist) or (not clans_friendlist:IsValid()) then
			println('UpdateClanMemberlist aborted as clans_friendlist is nil')
			return
		end
		
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo()) 
		
		if (not myChatClientInfo) then
			println('UpdateClanMemberlist aborted as myChatClientInfo is nil')
			return
		end		
		
		local canApprovePendingInvites = mainUI.Clans.CanApprovePendingInvites()
		
		local showVoice = myChatClientInfo.clanVoiceChannel >= 0
		
		local sortableTable = {}
		local allMembers = {}
		local allMemberIdentIDs = inMemberlist or mainUI.Clans.clanList or {}
		
		-- println('UpdateClanMemberlist')
		-- printr(allMemberIdentIDs)
		
		for i,v in pairs(allMemberIdentIDs) do
			local memberTrigger = GetClientInfoTrigger(v)
			if (memberTrigger) then
				
				local userIcon = memberTrigger.accountIconPath
				if (memberTrigger.isStaff) and (memberTrigger.accountIconPath) and ((memberTrigger.accountIconPath == '/ui/shared/textures/account_icons/default.tga') or (memberTrigger.accountIconPath == 'default')) then
					userIcon = '/ui/shared/textures/account_icons/s2staff.tga'
				elseif (memberTrigger.accountIconPath == 'default') then
					userIcon = '/ui/shared/textures/account_icons/default.tga'
				else
					if memberTrigger.accountIconPath and find(userIcon, '.tga') then
						userIcon = memberTrigger.accountIconPath or '$invis'
					elseif memberTrigger.accountIconPath and (not Empty(memberTrigger.accountIconPath)) then
						userIcon = '/ui/shared/textures/account_icons/' .. memberTrigger.accountIconPath .. '.tga'
					else
						userIcon = '/ui/shared/textures/account_icons/default.tga'
					end
				end

				local userIconFrame = '/ui/shared/textures/account_icon_frames/default.tga' -- memberTrigger.accountIconFramePath
				-- if (memberTrigger.accountIconFramePath == 'default') then
					-- userIconFrame = '/ui/shared/textures/account_icon_frames/default.tga'
				-- else
					-- if memberTrigger.accountIconFramePath and find(userIconFrame, '.tga') then
						-- userIconFrame = memberTrigger.accountIconFramePath or '$invis'
					-- elseif memberTrigger.accountIconFramePath and (not Empty(memberTrigger.accountIconFramePath)) then
						-- userIconFrame = '/ui/shared/textures/account_icon_frames/' .. memberTrigger.accountIconFramePath .. '.tga'
					-- else
						-- userIconFrame = '/ui/shared/textures/account_icon_frames/default.tga'
					-- end
				-- end				
				
				local newClanMember = {}
				newClanMember.trueName			= memberTrigger.name
				newClanMember.name				= memberTrigger.name
				newClanMember.icon				= userIcon
				newClanMember.iconFrame			= userIconFrame
				newClanMember.accountTitle		= memberTrigger.accountTitle
				newClanMember.uniqueID			= memberTrigger.uniqueID 
				newClanMember.status			= memberTrigger.status
				newClanMember.identID			= memberTrigger.identID
				newClanMember.acceptStatus		= memberTrigger.acceptStatus
				newClanMember.isDND				= memberTrigger.isDND			
				newClanMember.isFriend			= memberTrigger.isFriend			
				newClanMember.isStaff			= memberTrigger.isStaff			
				newClanMember.ready				= memberTrigger.ready
				newClanMember.accountColor		= memberTrigger.accountColor			
				newClanMember.accountIconPath	= memberTrigger.accountIconPath			
				newClanMember.accountTitle		= memberTrigger.accountTitle					
				newClanMember.uiStatus			= memberTrigger.uiStatus			
				newClanMember.userStatus		= memberTrigger.userStatus			
				newClanMember.userStatusMessage	= memberTrigger.userStatusMessage			
				newClanMember.ignored			= memberTrigger.isIgnored		
				newClanMember.spectatableGame	= memberTrigger.inSpectatableGame	
				newClanMember.buddyLabel		= memberTrigger.buddyGroup	
				newClanMember.isOnline			= memberTrigger.isOnline
				newClanMember.isInGame			= memberTrigger.isInGame
				-- newClanMember.steamID			= memberTrigger.steamID		
				-- newClanMember.steamName			= memberTrigger.steamName		
				-- newClanMember.steamStatus		= memberTrigger.steamStatus			
				newClanMember.clanVoiceChannel	= memberTrigger.clanVoiceChannel			
				newClanMember.clanJoinStatus	= memberTrigger.clanJoinStatus or ''	
				newClanMember.clanTag			= memberTrigger.clanTag			
				newClanMember.clanRank			= memberTrigger.clanRank			
				newClanMember.clanID			= memberTrigger.clanID			
				newClanMember.clanName			= memberTrigger.clanName			
				newClanMember.isTalking			= memberTrigger.isTalking			
				newClanMember.medalRating		= (memberTrigger.rating	or 0) + 1500
				-- newClanMember.clanSeals			= memberTrigger.clanSeals or 0	
				-- newClanMember.challengeStatus	= memberTrigger.challengeStatus or 0	
				
				table.insert(allMembers, newClanMember)

			end
		end

		if (mainUI.Clans) and (mainUI.Clans.UpdateLadder) then
			mainUI.Clans.UpdateLadder(allMembers)
		end
		
		local clanVoiceCount = 0
		
		for i,friendInfo in pairs(allMembers) do
			local displayGroup = 'online'
			if (canApprovePendingInvites) and (friendInfo.clanJoinStatus and friendInfo.clanJoinStatus == 1) then
				displayGroup = 'pending'
			-- elseif (friendInfo.challengeStatus == 1) and (friendInfo.isOnline) and (not friendInfo.isInGame) then
				-- displayGroup = 'challenge'
			elseif (showVoice) and (friendInfo.clanVoiceChannel >= 0) and (friendInfo.isOnline) then
				displayGroup = 'voice'
			elseif (friendInfo.isInGame and friendInfo.isOnline) then
				displayGroup = 'ingame'
			elseif (not friendInfo.isOnline) then
				displayGroup = 'offline'
			end
			if (friendInfo.clanVoiceChannel >= 0) then
				clanVoiceCount = clanVoiceCount + 1
			end
			sortableTable[displayGroup] = sortableTable[displayGroup] or {}
			tinsert(sortableTable[displayGroup], friendInfo)
		end		

		if (clanVoiceCount > 0) then
			interface:GetWidget('clans_window_voip_join_button_label'):SetText(Translate('clan_enable_voice_x', 'value', clanVoiceCount))
		else
			interface:GetWidget('clans_window_voip_join_button_label'):SetText(Translate('clan_enable_voice'))
		end
		
		local totalPlayerCount = 0
		for _, groupTable in pairs(sortableTable) do
			tsort(groupTable, function(a,b) 
				if (a.clanRank) and (b.clanRank) and (a.clanRank ~= b.clanRank) then
					return (a.clanRank) > (b.clanRank) 
				elseif (a.name) and (b.name) then
					return lower(a.name) < lower(b.name) 
				elseif (a.name) then
					return true
				else
					return false
				end
			end)
			if (#groupTable > 0) then
				totalPlayerCount = totalPlayerCount + #groupTable
			end
		end	
		
		mainUI.Clans.detailedClanList = libGeneral.tableCopy(sortableTable)
		if (mainUI.Clans) and (mainUI.Clans.Window) and (mainUI.Clans.Window.UpdateMemberlist) then
			mainUI.Clans.Window.UpdateMemberlist(sortableTable)
		end		
		
		local childrenCount = clans_friendlist:GetChildren()
		
		for i = 0, #childrenCount, 1 do -- rowIndex
			if (interface:GetWidget('clans_friend_longmode_template' .. i)) then
				interface:GetWidget('clans_friend_longmode_template' .. i):GetParent():SetVisible(0)
			end
			if (interface:GetWidget('clans_friendslist_header_row_template' .. i)) then
				interface:GetWidget('clans_friendslist_header_row_template' .. i):SetVisible(0)
			end
		end			
		
		local playerVisibleCount = 0
		local rowIndex = 0
		local headerIndex = 0
		local hiddenGroupsCount = 0
		local spawnedHeaders = {}
		local spawnedRows = {}
		
		local countOnline = 0	

		local function SpawnFriendsUsingGroupTable(groupTable, displayGroup, onlineGroup, sizeCap)

			sizeCap = sizeCap or 500
			local groupSize = 0
			
			for i,friendInfo in pairs(groupTable) do	
				
				if (groupSize > sizeCap) then
					break
				end
				
				if (friendInfo) and (type(friendInfo) == 'table') then
				
					local clientID 
					if (friendInfo.identID and friendInfo.identID ~= '') then
						clientID = friendInfo.identID
					elseif (friendInfo.steamID and friendInfo.steamID ~= '') then
						clientID = friendInfo.steamID
					end							
				
					mainUI.savedRemotely.clanGroupExpanded = mainUI.savedRemotely.clanGroupExpanded or {}
					if (mainUI.savedRemotely.clanGroupExpanded[displayGroup] == nil) then
						mainUI.savedRemotely.clanGroupExpanded[displayGroup] = true
					end
					
					local targetHeader
					local targetFriend
					
					-- Header
					if (spawnedHeaders[displayGroup] == nil) then
						targetHeader = interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex)
						if (not targetHeader) or (not targetHeader:IsValid()) then
							clans_friendlist:Instantiate('clans_friend_both_template', 'index', rowIndex)
						end							
						targetHeader 					= interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex)
						local targetHeader_arrow 		= interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex .. '_arrow')
						local targetHeader_label 		= interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex .. '_label')
						local targetHeader_count_label 	= interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex .. '_count_label')
						local targetHeader_line 		= interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex .. '_line')
						targetFriend 					= interface:GetWidget('clans_friend_longmode_template' .. rowIndex)	

						targetHeader:SetVisible(1)
						targetFriend:GetParent():SetVisible(0)
						
						spawnedHeaders[displayGroup] = {}
						local headerName = TranslateOrNil('main_clan_groupname_' .. displayGroup) or displayGroup or '?No Header'
						local countLabel = ''
						local rotation = 0
						
						if (#groupTable > 0) then
							countLabel = #groupTable .. '/' .. totalPlayerCount
						end
						
						if (mainUI.savedRemotely) and (mainUI.savedRemotely.clanGroupExpanded) and (mainUI.savedRemotely.clanGroupExpanded[displayGroup]) then
							rotation = 0
						else
							rotation = -180
						end				
						
						targetHeader_arrow:SetRotation(rotation)
						targetHeader_label:SetText(headerName)
						targetHeader_count_label:SetText(countLabel)
						
						local contentWidth = (targetHeader_arrow:GetWidth() + targetHeader_label:GetWidth() + targetHeader_count_label:GetWidth())
						local lineWidth = (targetFriend:GetWidth()) - contentWidth
						
						targetHeader_count_label:SetX(contentWidth)
						targetHeader_line:SetX(contentWidth + targetHeader_line:GetWidthFromString('22s'))
						targetHeader_line:SetWidth(lineWidth)
						
						tinsert(spawnedHeaders[displayGroup], rowIndex)
						
						RegisterHeader(targetHeader, rowIndex, displayGroup)
						
						targetHeader_label:Refresh()
						targetHeader_count_label:Refresh()
						targetHeader:Refresh()
						
						headerIndex = headerIndex + 1
						rowIndex = rowIndex + 1
					end
					
					-- Player
					targetFriend = interface:GetWidget('clans_friend_longmode_template' .. rowIndex)
					if (not targetFriend) or (not targetFriend:IsValid()) then
						clans_friendlist:Instantiate('clans_friend_both_template', 'index', rowIndex)
					end						
					targetFriend = interface:GetWidget('clans_friend_longmode_template' .. rowIndex)	
					targetHeader = interface:GetWidget('clans_friendslist_header_row_template' .. rowIndex)
					targetHeader:SetVisible(0)
					targetFriend:GetParent():SetVisible(1)
					
					spawnedRows[displayGroup] = spawnedRows[displayGroup] or {}
					tinsert(spawnedRows[displayGroup], {index = rowIndex, count = 1, clientID = clientID})						

					if (onlineGroup) and (friendInfo) and (friendInfo.identID) and (not IsMe(friendInfo.identID)) then
						countOnline = countOnline + 1
					end
					 
					local clientID
					if (friendInfo) and (friendInfo.identID) and (friendInfo.identID ~= '') then
						clientID = friendInfo.identID
					elseif (friendInfo) and (friendInfo.steamID) and (friendInfo.steamID ~= '') then
						clientID = friendInfo.steamID
					end
					 
					if (not clientID) or (not friendInfo.icon) or (not friendInfo.name) or --[[(not friendInfo.buddyGroup) or]] (not friendInfo.identID) or (not friendInfo.uniqueID) then
						println('^r InstantiatePlayerEntry missing data')
						printr(friendInfo)
					else
						local statusText = friendInfo.buddyLabel or friendInfo.buddyGroup or ''

						if (RegisterFriend) then
							if (clientID) then
								RegisterFriend(targetFriend, clientID, rowIndex)
							else
								println("^r Clan RegisterFriend 2 Error: no clientID " .. tostring(clientID))
							end
						end
						
					end
					
					playerVisibleCount = playerVisibleCount + 1
					groupSize = groupSize + 1
					rowIndex = rowIndex + 1

				else
					println('^r FriendsUpdateRegister is missing friendInfo')						
				end
				
			end
		end	
		
		if (sortableTable) then

			if (sortableTable['pending']) then
				SpawnFriendsUsingGroupTable(sortableTable['pending'], 'pending', true, 300)
				sortableTable['pending'] = nil
			end

			-- if (sortableTable['challenge']) then
				-- SpawnFriendsUsingGroupTable(sortableTable['challenge'], 'challenge', true, 300)
				-- sortableTable['challenge'] = nil
			-- end	

			if (sortableTable['voice']) then
				SpawnFriendsUsingGroupTable(sortableTable['voice'], 'voice', true, 300)
				sortableTable['voice'] = nil
			end	

			if (sortableTable['online']) then
				SpawnFriendsUsingGroupTable(sortableTable['online'], 'online', true, 300)
				sortableTable['online'] = nil
			end		

			if (sortableTable['ingame']) then
				SpawnFriendsUsingGroupTable(sortableTable['ingame'], 'ingame', true, 300)
				sortableTable['ingame'] = nil
			end				
			
			if (sortableTable['offline']) then
				SpawnFriendsUsingGroupTable(sortableTable['offline'], 'offline', nil, 200)
				sortableTable['offline'] = nil
			end	
					
		end	
		
		for displayGroup, displayGroupTable in pairs(spawnedRows) do
			if (mainUI.savedRemotely) and (mainUI.savedRemotely.clanGroupExpanded) and (mainUI.savedRemotely.clanGroupExpanded[displayGroup] == false) then
				hiddenGroupsCount = hiddenGroupsCount + 1
				for i,v in pairs(displayGroupTable) do
					local widget = GetWidget('clans_friend_longmode_template' .. v.index)
					if (v.index) and widget and widget:GetParent() then								
						if widget:GetParent():IsVisible() then
							playerVisibleCount = playerVisibleCount - 1
						end
						widget:GetParent():SetVisible(0)
					end
				end
			end
		end		

		for displayGroup, displayGroupTable in pairs(spawnedHeaders) do
			if (mainUI.savedRemotely) and (mainUI.savedRemotely.clanGroupExpanded) and (mainUI.savedRemotely.clanGroupExpanded[displayGroup] == false) then
				for i,v in pairs(displayGroupTable) do
					local widget = GetWidget('clans_friendslist_header_row_template' .. v .. '_subheader')
					if (v) and widget then								
						widget:SetVisible(0)
					end
					local widget2 = GetWidget('clans_friendslist_header_row_template' .. v)
					if (v) and widget2 then								
						widget2:SetHeight(headerTemplateHeight)
					end
				end
			else
				for i,v in pairs(displayGroupTable) do
					local widget = GetWidget('clans_friendslist_header_row_template' .. v .. '_subheader')
					if (v) and widget then								
						widget:SetVisible(1)
					end
					local widget2 = GetWidget('clans_friendslist_header_row_template' .. v)
					if (v) and widget2 then								
						widget2:SetHeight(headerTemplateHeightDouble)
					end					
				end			
			end
		end		
		
		local lastValue = clans_friendlist_scrollbar:GetValue()
		local maxValue = headerIndex + rowIndex
		maxValue = math.max(maxValue, 1)
		clans_friendlist_scrollbar:SetValue(0)
		clans_friendlist_scrollbar:SetMinValue(0)
		clans_friendlist_scrollbar:SetMaxValue(maxValue)
		clans_friendlist_scrollbar:SetValue(lastValue)
		
		if (postUpdateCallback) then
			postUpdateCallback()
		end
		
		mainUI.Clans.UpdateScrollPosition(true)	
		
	end

	function mainUI.Clans.UpdateClanMemberlist(inMemberlist, postUpdateCallback)
		if (updateClanMemberlistThread) and (updateClanMemberlistThread:IsValid()) then
			updateClanMemberlistThread:kill()
			updateClanMemberlistThread = nil
		end		
		updateClanMemberlistThread = libThread.threadFunc(function()
			wait(1)			
			UpdateClanMemberlist(inMemberlist, postUpdateCallback)
		end)
	end	
	
	FriendsScrollRegister(object)

	-- clans_friendlist_friendlist_parent:RegisterWatchLua('ChatClanInfo'
	
	local function AddMemberUnique(targetIdentID)
		local foundMatch = false
		for i,v in pairs(mainUI.Clans.clanList) do
			if (v == targetIdentID) then
				foundMatch = true
				break
			end
		end
		if (not foundMatch) then
			tinsert(mainUI.Clans.clanList, targetIdentID)
		end
	end
	
	clans_friendlist_friendlist_parent:RegisterWatchLua('ChatClanClientInfo', function(widget, trigger)
		println('ChatClanClientInfo ' .. tostring(trigger.identID) .. ' ' .. tostring(trigger.added))
		if (not mainUI.Clans.clanList) then
			mainUI.Clans.clanList = ChatClient.GetClanList()
			local applicantTable = ChatClient.GetClanApplicantList()
			for i,v in pairs(applicantTable) do
				AddMemberUnique(v)
			end			
		elseif (mainUI.Clans.clanList) then
			if (trigger.added) then
				AddMemberUnique(trigger.identID)
			else
				for i,v in pairs(mainUI.Clans.clanList) do
					if (v == trigger.identID) then
						-- println('^r ' .. v .. ' ' ..  trigger.identID)
						mainUI.Clans.clanList[i] = nil
						break
					else
						-- println('^g ' .. v .. ' ' ..  trigger.identID)
					end
				end
				-- printr(mainUI.Clans.clanList)
				UnwatchLuaTriggerByKey(GetClientInfoTriggerName(trigger.identID), 'ClanChatClientInfo'..gsub(trigger.identID, '%.', ''))
			end
		end
		if (updateClanMemberlistThread) and (updateClanMemberlistThread:IsValid()) then
			updateClanMemberlistThread:kill()
			updateClanMemberlistThread = nil
		end		
		updateClanMemberlistThread = libThread.threadFunc(function()
			wait(500)			
			UpdateClanMemberlist()
		end)
	end)
	
	clans_friendlist_friendlist_parent:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		if (trigger.id ~='' and trigger.id ~='0.000') then
			if (not mainUI.Clans.clanList) then
				mainUI.Clans.clanList = ChatClient.GetClanList()
				local applicantTable = ChatClient.GetClanApplicantList()
				for i,v in pairs(applicantTable) do
					AddMemberUnique(v)
				end
			end
			if (updateClanMemberlistThread) and (updateClanMemberlistThread:IsValid()) then
				updateClanMemberlistThread:kill()
				updateClanMemberlistThread = nil
			end		
			updateClanMemberlistThread = libThread.threadFunc(function()
				wait(1)			
				UpdateClanMemberlist()
			end)
		else
			mainUI.Clans.clanList = nil
		end
	end) -- id, name, tag, description, language, region, tags, autoAcceptMembers, minRating, title	

	function mainUI.Clans.UpdateChallenges()

		mainUI.Clans.pendingChallenges = {}
		mainUI.Clans.sentChallenges = {}
		
		if (Notifications) and (Notifications.notificationsTable) then
			for notificationType, typeTable in pairs(Notifications.notificationsTable) do
				for i, notificationTable in pairs(typeTable) do	
					if (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'friendly_challenge_received')) then	
						if (notificationTable.tokens) and (notificationTable.tokens.senderIdentID) then
							mainUI.Clans.pendingChallenges[notificationTable.tokens.senderIdentID] = notificationTable
							local memberTrigger = GetClientInfoTrigger(notificationTable.tokens.senderIdentID)
							if (memberTrigger) then
								memberTrigger:Trigger(true)
							end
						end
					elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'friendly_challenge_sent')) then
						if (notificationTable.tokens) and (notificationTable.tokens.identID) then
							mainUI.Clans.sentChallenges[notificationTable.tokens.identID] = notificationTable
							local memberTrigger = GetClientInfoTrigger(notificationTable.tokens.identID)
							if (memberTrigger) then
								memberTrigger:Trigger(true)
							end						
						end
					elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'friendly_challenge_declined')) then
						if (notificationTable.tokens) and (notificationTable.tokens.senderIdentID) then
							local memberTrigger = GetClientInfoTrigger(notificationTable.tokens.senderIdentID)
							if (memberTrigger) then
								memberTrigger:Trigger(true)
							end						
						end
					end
				end
			end	
		end
		
	end	
	
	function mainUI.Clans.UpdatePartyInvites()

		local updateIds = {}
	
		if (mainUI.Clans) and (mainUI.Clans.pendingPartyInvites) then
			for i, notificationTable in pairs(mainUI.Clans.pendingPartyInvites) do		
				if (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'party_invite')) then	
					if (notificationTable.tokens) and (notificationTable.tokens.senderIdentID) then
						table.insert(updateIds, notificationTable.tokens.senderIdentID)
					end
				end		
			end
		end
		
		mainUI.Clans.pendingPartyInvites = {}	
			
		if (Notifications) and (Notifications.notificationsTable) then
			for notificationType, typeTable in pairs(Notifications.notificationsTable) do
				for i, notificationTable in pairs(typeTable) do	
					if (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'party_invite')) then	
						if (notificationTable.tokens) and (notificationTable.tokens.senderIdentID) then
							mainUI.Clans.pendingPartyInvites[notificationTable.tokens.senderIdentID] = notificationTable
							table.insert(updateIds, notificationTable.tokens.senderIdentID)
						end
					end
				end
			end	
		end

		if (updateIds) then
			for _, id in pairs(updateIds) do		
				local memberTrigger = GetClientInfoTrigger(id)
				if (memberTrigger) then
					memberTrigger:Trigger(true)
				end
			end
		end
		
	end	
	
	-- mainUI.Clans.UpdateChallenges()
	
	-- println('RegisterClansMembers 2/2')
	
end

RegisterClansMembers(object)
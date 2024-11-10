local interface = object

local function RegisterFriendBeingDragged(self, identID)

	if (self) and (self:IsValid()) then		 

		local function WatchAndUpdateFriendItem(self, identID)

			local friendsClientInfoTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. string.gsub(identID, '%.', ''))

			local function UpdateFriendItem(trigger)

				local friendInfo = Friends['main'].GetFriendDataFromIdentID(identID)
				
				if (friendInfo == nil) then
					println("^rError: no friendInfo for " .. tostring(identID))
				else

					local parentWidget					= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy')
					local bgWidget						= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_bg')
					local hoverWidget					= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_hover')
					local hoverOutlineWidget			= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_hoverOutline')
					local nameWidget 					= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_name')
					local statusIconWidget 				= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_status_icon')
					local statusGlowWidget 				= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_status_icon_glow')
					local statusTextWidget 				= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_status')
					local accountIconWidget 			= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_id')
					local accountIconHoverWidget		= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_id_hover')
					local groupNameWidget	 			= interface:GetWidget('socialclient_friend_longmode_template' .. 'dragbuddy' .. '_profile_groupname')

					local statusColor = '.3 .2 .2 .7'
					local statusText = Translate('friend_online_status_offline')
					local statusIcon = '$checker'
					local userIcon = '/ui/shared/textures/account_icons/default.tga'
					local userName = '???'
					local userNameColor = 'white'
					local secondaryLabel = '???'
					
					local isOnline = true

					if (trigger) and (trigger.userStatus == 7) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then 
						statusColor = '0.7 0.7 0.7 0.3' -- faded gray
						statusText = Translate('friend_online_status_offline')		
						isOnline = false
					elseif (trigger) and (trigger.userStatus == 3) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then 
						statusColor = '#e82000' -- red
						statusText = Translate('friend_online_status_streaming')										
					elseif (trigger) and (trigger.userStatus == 5) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then 
						statusColor = '#e82000' -- red
						statusText = Translate('friend_online_status_dnd')			
					elseif (trigger) and ((trigger.userStatus == 1)) and (trigger.status == 1) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then
						statusColor = '#138dff' -- blue
						statusText = Translate('friend_online_status_lfg')
					elseif (trigger) and ((trigger.userStatus == 2)) and (trigger.status == 1) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then
						statusColor = '#138dff' -- blue
						statusText = Translate('friend_online_status_lfm')
					elseif (trigger) and ((trigger.userStatus == 4)) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then
						statusColor = '#FFFF00' -- yellow
						statusText = Translate('friend_online_status_afk')	
					elseif (trigger) and ((trigger.status == 2)) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then
						statusColor = '#FFFF00' -- yellow
						statusText = Translate('friend_online_status_idle')										
					elseif (trigger) and (trigger.status == 6) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then 
						statusColor = '#e82000' -- red
						statusText = Translate('friend_online_status_spectating')		 
					elseif (trigger) and (trigger.status == 5) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then 
						statusColor = '#e82000' -- red
						statusText = Translate('friend_online_status_practice')
					elseif (trigger) and (trigger.status == 4) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then 
						statusColor = '#e82000' -- red
						statusText = Translate('friend_online_status_ingame')			
					elseif (trigger) and ((trigger.status == 3) or (friendInfo.isInParty)) and ((friendInfo.acceptStatus == nil) or ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved'))) then
						statusColor = '#FF9100' -- orange	
						statusText = Translate('friend_online_status_inparty')
					elseif (friendInfo.isInLobby) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then
						statusColor = '#FF9100' -- orange		
						statusText = Translate('friend_online_status_inlobby')						
					elseif (trigger) and (trigger.status == 1) and ((friendInfo.acceptStatus == nil) or (friendInfo.acceptStatus == 'approved')) then
						statusColor = '#b7ff00' -- green
						statusText = Translate('friend_online_status_online')
					elseif (trigger) and (trigger.status == 0) then
						statusColor = '.7 .7 .7 1' -- faded gray red
						statusText = Translate('friend_online_status_offline')
						isOnline = false
					else
						statusColor = '.7 .7 .7 1'
						statusText = Translate('friend_online_status_unknown')
						isOnline = false
					end								

					if (trigger) and (trigger.isStaff) and (friendInfo.icon) and ((friendInfo.icon == '/ui/shared/textures/account_icons/default.tga') or (friendInfo.icon == 'default')) then
						userIcon = '/ui/shared/textures/account_icons/s2staff.tga'
					elseif (friendInfo.icon == 'default') then
						userIcon = '/ui/shared/textures/account_icons/default.tga'
					else
						if friendInfo.icon and string.find(userIcon, '.tga') then
							userIcon = friendInfo.icon or '$invis'
						elseif friendInfo.icon and (not Empty(friendInfo.icon)) then
							userIcon = '/ui/shared/textures/account_icons/' .. friendInfo.icon.. '.tga'
						else
							userIcon = '/ui/shared/textures/account_icons/default.tga'
						end
					end
					
					if (not friendInfo.isDuplicate) and (friendInfo.acceptStatus ~= 'pending') then
						userName = friendInfo.name
					else
						userName = friendInfo.name .. '.' .. friendInfo.uniqueID
					end
					
					if (trigger) and (trigger.isStaff) then
						userNameColor = '#e82000'
					else
						userNameColor = '1 1 1 1'
					end						
					
					secondaryLabel = friendInfo.friendNote or friendInfo.uniqueID or ''							
												
					local function setColors ()
						if (isOnline) then
							statusIconWidget:SetTexture('/ui/main/shared/textures/user_status_light.tga')
							statusIconWidget:SetVisible(1)
							statusGlowWidget:SetVisible(1)
							bgWidget:SetColor(0.02, 0.07, 0.09, 0.98)
							bgWidget:SetBorderColor(0.02, 0.07, 0.09, 0.98)
							accountIconWidget:SetColor(1, 1, 1, 1)
							groupNameWidget:SetColor(1, 1, 1, 1)
							nameWidget:SetColor(userNameColor)
							statusIconWidget:SetColor(statusColor)
							statusGlowWidget:SetColor(statusColor)
							statusTextWidget:SetColor(statusColor)
						else
							statusIconWidget:SetTexture('/ui/main/shared/textures/user_status_offline.tga')
							statusIconWidget:SetVisible(1)
							statusGlowWidget:SetVisible(0)
							bgWidget:SetColor(0.02, 0.07, 0.09, 0.3)
							bgWidget:SetBorderColor(0.02, 0.07, 0.09, 0.3)
							nameWidget:SetColor(1, 1, 1, 0.3)
							accountIconWidget:SetColor(1, 1, 1, 0.3)
							groupNameWidget:SetColor(1, 1, 1, 0.3)
							statusIconWidget:SetColor(0.4, 0.4, 0.4, 1)
							statusGlowWidget:SetColor(0.4, 0.4, 0.4, 1)
							statusTextWidget:SetColor(0.4, 0.4, 0.4, 1)									
						end	
					end
					
					-- Update Widgets
					statusTextWidget:SetText(statusText)
					nameWidget:SetText(userName)
					groupNameWidget:SetText(secondaryLabel)
					accountIconWidget:SetTexture(userIcon)
					accountIconHoverWidget:SetTexture(userIcon)
					
					setColors()

					parentWidget:SetCallback('onmouseover', function(widget)
						hoverWidget:FadeIn(200)
						hoverOutlineWidget:FadeIn(200)
						bgWidget:SetColor(0.02, 0.07, 0.09, 0.98)
						bgWidget:SetBorderColor(0.02, 0.07, 0.09, 0.98)
						accountIconWidget:SetColor(1, 1, 1, 1)
						groupNameWidget:SetColor(1, 1, 1, 1)
						nameWidget:SetColor(userNameColor)
						if (not isOnline) then
							statusIconWidget:SetColor(0.7, 0.7, 0.7, 1)
							statusGlowWidget:SetColor(0.7, 0.7, 0.7, 1)
							statusTextWidget:SetColor(0.7, 0.7, 0.7, 1)	
						end
						UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, spendGems = false, canDrag = true })
					end)	
					
					parentWidget:SetCallback('onmouseout', function(widget)
						hoverWidget:FadeOut(100)
						hoverOutlineWidget:FadeOut(100)
						setColors()
						UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, spendGems = false, canDrag = true })
					end)	
					
					local function AccountIconMouseOut()
						accountIconHoverWidget:ClearCallback('onframe')	
						ScaleInPlace(accountIconWidget,'100@', '100%', 150)
						setColors()		
						accountIconHoverWidget:SetNoClick(0)
						if mouseInWidgetArea(parentWidget) then
						
						else
							hoverWidget:FadeOut(100)
							hoverOutlineWidget:FadeOut(100)								
						end
					end
					
					accountIconHoverWidget:SetCallback('onmouseover', function(widget)
						println('accountIconHoverWidget onmouseover')
						ScaleInPlace(accountIconWidget, '160@', '160%', 150)
						hoverWidget:FadeIn(200)
						hoverOutlineWidget:FadeIn(200)
						bgWidget:SetColor(0.02, 0.07, 0.09, 0.98)
						bgWidget:SetBorderColor(0.02, 0.07, 0.09, 0.98)
						accountIconWidget:SetColor(1, 1, 1, 1)
						groupNameWidget:SetColor(1, 1, 1, 1)
						nameWidget:SetColor(userNameColor)
						accountIconHoverWidget:SetNoClick(1)
						accountIconHoverWidget:ClearCallback('onframe')
						accountIconHoverWidget:SetCallback('onframe', function(widget)
							if mouseInWidgetArea(accountIconHoverWidget) then
							else
								AccountIconMouseOut()
							end
						end)
					end)	
					
					accountIconHoverWidget:SetCallback('onhide', function(widget)
						AccountIconMouseOut()
					end)
					
					parentWidget:SetCallback('onclick', function(widget, x, y)
						println('onclick ' .. tostring(identID))
						Friends[interfaceName].Clicked(widget, identID, x, y)
					end)	
					parentWidget:SetCallback('ondoubleclick', function(widget)
						println('ondoubleclick ' .. tostring(identID))
						Friends[interfaceName].DoubleClicked(widget, identID)
					end)
					parentWidget:SetCallback('onrightclick', function(widget)
						println('onrightclick ' .. tostring(identID))
						Friends[interfaceName].RightClicked(widget, identID)
					end)		
					-- parentWidget:SetCallback('onstartdrag', function(widget)
						-- println('onstartdrag ' .. tostring(identID))
						-- Friends[interfaceName].OnStartDrag(widget, identID)
					-- end)	
					-- parentWidget:SetCallback('onenddrag', function(widget)
						-- println('onenddrag ' .. tostring(identID))
						-- Friends[interfaceName].OnEndDrag(widget, identID)
					-- end)		
					
					globalDraggerReadTarget(parentWidget, function()
						println('globalDraggerReadTarget ' .. tostring(identID))
					end)
					globalDraggerRegisterSource(parentWidget, 11)							
					
				end
			end
			if (friendsClientInfoTrigger) then
				self:UnregisterWatchLua('ChatClientInfo' .. string.gsub(identID, '%.', ''))
				self:RegisterWatchLua('ChatClientInfo' .. string.gsub(identID, '%.', ''), function(widget, trigger)
					 UpdateFriendItem(trigger)
				end)
			end
			UpdateFriendItem(friendsClientInfoTrigger)						
		end

		WatchAndUpdateFriendItem(self, identID) 

	end
end

RegisterFriendBeingDragged(object, Windows.data.friendBeingDraggedIdentID)



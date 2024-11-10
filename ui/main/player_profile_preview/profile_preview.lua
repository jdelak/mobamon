
ProfilePreview = {}
ProfilePreview.lastIdentID = nil
ProfilePreview.hoveringIdentID = nil
ProfilePreview.lastResponse = nil

LuaTrigger.CreateCustomTrigger('playerProfilePreviewInfo',
	{
		{ name	= 'identID',			type	= 'string'},
	}
)

local function ProfilePreviewRegister(object)

	local parent		=	GetWidget('profile_preview_parent')
	local username		=	GetWidget('profile_preview_display_name')
	local uniqueid		=	GetWidget('profile_preview_unique_id')
	local info			=	GetWidget('profile_preview_info')
	local icon			=	GetWidget('profile_preview_icon')
		
	local function UpdateProfilePreview(responseData)	
		uniqueid:SetVisible(1)
		uniqueid:SetText(responseData.uniqid)
		
		for i,v in ipairs(responseData.clientAccountIcons) do
			if (v.active) and (v.active ~= '0') then
				icon:SetTexture(v.webPath)
			end
		end			
		
	end

	local function GetProfileData(identID)
		
		local identID = identID or GetIdentID()
		
		if (not ProfilePreview.lastIdentID) or (ProfilePreview.lastIdentID ~= identID) then

			local successFunction =  function (request)	-- response handler
				local responseData = request:GetBody()
				if responseData == nil then
					SevereError('GetProfilePreview - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
					GetWidget('profile_preview_throb'):FadeOut(250)
					GetWidget('profile_preview_icon'):FadeIn(250)
					return nil
				else
					ProfilePreview.lastIdentID = identID
					ProfilePreview.lastResponse = responseData
					UpdateProfilePreview(responseData)
					GetWidget('profile_preview_throb'):FadeOut(250)
					GetWidget('profile_preview_icon'):FadeIn(250)
					return true
				end
			end
			
			local failFunction =  function (request)	-- error handler
				SevereError('GetProfilePreview Request Error: ' .. Translate(request:GetError()), 'main_reconnect_thatsucks', '', nil, nil, false)
				GetWidget('profile_preview_throb'):FadeOut(250)
				GetWidget('profile_preview_icon'):FadeIn(250)
				return nil
			end	
			
			if IsValidIdent(identID) then	
				Strife_Web_Requests:GetProfile(successFunction, failFunction, identID)
			else
				SevereError('GetProfilePreview Invalid IdentID', 'main_reconnect_thatsucks', '', nil, nil, false)
				return nil
			end
		else
			UpdateProfilePreview(ProfilePreview.lastResponse)
			GetWidget('profile_preview_throb'):FadeOut(250)
			GetWidget('profile_preview_icon'):FadeIn(250)
		end
		
	end	
	
	parent:RegisterWatchLua('ChatOutputRightClick', function(widget, trigger)
		if (trigger.elementType == 2) and (trigger.identID) and (not Empty(trigger.identID)) and (trigger.identID ~= '4294967.295')  then
			ContextMenuMultiWindowTrigger.selectedUserIdentID = trigger.identID
			ContextMenuMultiWindowTrigger.selectedUserUsername = trigger.user
			ContextMenuMultiWindowTrigger.contextMenuArea = 1
			ContextMenuMultiWindowTrigger:Trigger(true)
		end
	end)
	
	local profilePreviewLine = nil
	local lastClickTime = nil
	local lastClickLine = nil
	local showPreviewThread = nil
	local doubleClickTime = 250
	parent:RegisterWatchLua('ChatOutputClick', function(widget, trigger)
		if (trigger.elementType == 2) and (trigger.identID) and (not Empty(trigger.identID)) and (trigger.identID ~= '4294967.295') then
			if (lastClickTime and lastClickTime>GetTime()-doubleClickTime) and not IsMe(trigger.identID) then --double click
				lastClickTime = nil
				mainUI.chatManager.InitPrivateMessage(trigger.identID, 1, trigger.user or '')
			else
				lastClickTime = GetTime()
				lastClickLine = trigger.line

				profilePreviewLine = trigger.line
				ProfilePreview.hoveringIdentID = trigger.identID
				if (showPreviewThread) then
					showPreviewThread:kill()
					showPreviewThread = nil
				end
				showPreviewThread = libThread.threadFunc(function()
					wait(doubleClickTime)
					if (lastClickTime) then --wasn't a double click.
						lastClickTime = nil
						parent:SetVisible(1)
						uniqueid:SetVisible(0)
						info:SetVisible(trigger.user and (not Empty(trigger.user)))
						username:SetVisible(trigger.user and (not Empty(trigger.user)))
						username:SetText(tostring(trigger.user))
						GetWidget('profile_preview_throb'):FadeIn(250)
						GetWidget('profile_preview_icon'):FadeOut(250)
						if (ProfilePreview.hoveringIdentID) then
							GetProfileData(ProfilePreview.hoveringIdentID)
						else
							GetWidget('profile_preview_throb'):FadeOut(250)
						end
					end
					showPreviewThread = nil
				end)
			end
		end
	end)	
	
	parent:RegisterWatchLua('ChatOutputMouseOver', function(widget, trigger)
		if (profilePreviewLine and profilePreviewLine ~= trigger.line) then -- we have moved off the original line. Hide the preview.
			parent:SetVisible(0)
			ProfilePreview.hoveringIdentID = nil
			profilePreviewLine = nil
		elseif (not profilePreviewLine and parent:IsVisible()) then -- this fixes a bug where you could click and move before the box popped up, causing odd ui artifacts.
			parent:SetVisible(0)
		end
		-- parent:SetVisible(1)
		-- uniqueid:SetVisible(0)
		-- info:SetVisible(trigger.user and (not Empty(trigger.user)))
		-- username:SetVisible(trigger.user and (not Empty(trigger.user)))
		
		-- username:SetText(tostring(trigger.user))

		-- ProfilePreview.hoveringIdentID = trigger.identID
		-- libThread.threadFunc(function()		
			-- GetWidget('profile_preview_throb'):FadeIn(250)
			-- if (ProfilePreview.hoveringIdentID) then
				-- GetProfileData(ProfilePreview.hoveringIdentID)
			-- else
				-- GetWidget('profile_preview_throb'):FadeOut(250)
			-- end
		-- end)
		-- UpdateCursor(widget, true, { canLeftClick = false, canRightClick = true, canDrag = false } )
	end)
	
	parent:RegisterWatchLua('ChatOutputMouseOut', function(widget, trigger)
		parent:SetVisible(0)
		ProfilePreview.hoveringIdentID = nil
		-- UpdateCursor(widget, false, { canLeftClick = false, canRightClick = true, canDrag = false } )
	end)	
	
end

ProfilePreviewRegister(object)
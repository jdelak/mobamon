local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()
local GetTrigger = LuaTrigger.GetTrigger
BG = BG or {}

local function BackgroundRegister()
	
	local function InitializeLogo(object)

		local logoButton				= object:GetWidget('mainLogoButton')
		local mainLogoContainer			= object:GetWidget('mainLogoContainer')
		local mainLogoBody				= object:GetWidget('mainLogoBody')
		local logo						= object:GetWidget('mainLogo')
		
		local backButton				= object:GetWidget('mainBackButton')
		local backButtonTab				= object:GetWidget('mainBackButtonTab')

		mainLogoContainer:RegisterWatchLua('mainBackground', function(widget, trigger)
			if not trigger.logoVisible then
				widget:FadeOut(250)
				return
			end
			if trigger.logoSlide then
				widget:SlideX(trigger.logoX, styles_mainSwapAnimationDuration, true)
				widget:SlideY(trigger.logoY, styles_mainSwapAnimationDuration, true)
				widget:Scale(trigger.logoWidth, trigger.logoHeight, styles_mainSwapAnimationDuration)
			else
				widget:SetWidth(trigger.logoWidth)
				widget:SetHeight(trigger.logoHeight)
				widget:SetX(trigger.logoX)
				widget:SetY(trigger.logoY)
			end	
			widget:FadeIn(250)					
		end, false, nil, 'logoVisible', 'logoX', 'logoY', 'logoWidth', 'logoHeight')
		
		logoButton:SetCallback('onclick', function(widget)
			PlaySound('/ui/sounds/sfx_ui_back.wav')
		end)
	end
	
	local function InitialiseBackgroundWheel(object)
		local background				= object:GetWidget('mainBG')
		local bgWheel					= object:GetWidget('mainBGWheel')
		local mainBGWheel_ranked		= object:GetWidget('mainBGWheel_ranked')
		local mainBG_behind_ranked_glow	= object:GetWidget('mainBG_behind_ranked_glow')
		local mainBGWheel_parent		= object:GetWidget('mainBGWheel_parent')
		local mainBGWheel_shadow		= object:GetWidget('mainBGWheel_shadow')
		local mainBGWheel_shadow_2		= object:GetWidget('mainBGWheel_shadow_2')
		local mainBackgroundTopContainer= object:GetWidget('mainBackgroundTopContainer')
		local mainBackgroundBlackTop	= object:GetWidget('mainBackgroundBlackTop')
		local currentXPosition 			= 0
		local currentYPosition 			= 0
		local currentZPosition 			= 0
		local isRotating = false
		local hasEffect = true
		
		local function AnimateBackgroundWheel(widget, bgWheel, targetX, targetXAngle, targetYAngle, targetZAngle)
			local targetXAngle = targetXAngle or 0
			local targetYAngle = targetYAngle or 0
			local targetZAngle = targetZAngle or 0
			
			local correctedTargetXAngle = targetXAngle - currentXPosition
			local correctedTargetYAngle = targetYAngle - currentYPosition
			local correctedTargetZAngle = targetZAngle - currentZPosition

			local animationDuration = (styles_mainSwapAnimationDuration * 2)		
			local circ = 2 * math.pi * (bgWheel:GetWidth()/2)
			local moveX = widget:GetXFromString(targetX) - widget:GetX()
			local requiredRotation = ((moveX / circ) * 360 * 4)
			
			requiredRotation = requiredRotation * -1
			correctedTargetYAngle = correctedTargetYAngle + requiredRotation
			
			if (not isRotating) then
			
				isRotating = true
			
				libThread.threadFunc(function()	

					if (moveX ~= 0) then
						widget:SlideX(targetX, animationDuration)
					end				
				
					if (correctedTargetXAngle ~= 0) or (requiredRotation ~= 0) or (correctedTargetZAngle ~= 0) then
						
						-- bgWheel:CameraRotateAdd(0, 0, 1, 1500) 
						bgWheel:ModelRotateAdd(correctedTargetXAngle, correctedTargetYAngle, correctedTargetZAngle, animationDuration) 
						
						currentXPosition = targetXAngle
						currentYPosition = targetYAngle
						currentZPosition = targetZAngle
						
						wait(animationDuration)
						
						isRotating = false

					else
						isRotating = false
					end	
					
				end)
			
			else
				if (moveX ~= 0) then
					widget:SlideX(targetX, animationDuration)
				end	
			end
			
		end

		
		mainBGWheel_parent:RegisterWatchLua('mainBackground', function(widget, trigger)
			local x = widget:GetX()
			widget:SetWidth(trigger.wheelWidth)
			widget:SetHeight(trigger.wheelHeight)
			widget:SetX(x)
			
			AnimateBackgroundWheel(widget, bgWheel, trigger.wheelX, trigger.wheelAngleX, trigger.wheelAngleY, trigger.wheelAngleZ)
			
			fadeWidget(mainBGWheel_shadow, trigger.shadowVisible)
			fadeWidget(mainBGWheel_shadow_2, trigger.shadowVisible)
			fadeWidget(mainBackgroundTopContainer, trigger.navBackingVisible)
			fadeWidget(mainBackgroundBlackTop, trigger.blackTop)
		end, false, 'wheelX', 'wheelAngleX', 'wheelAngleY', 'wheelAngleZ', 'shadowVisible')
		
		background:RegisterWatchLua('mainBackground', function(widget, trigger)
			 widget:SetVisible(trigger.visible)
		end, false, nil, 'visible')		
		
		bgWheel:SetX(0)
		bgWheel:FadeIn(500)	
		BG.lastbgAnimateTime = 0
		
		InitialiseBackgroundWheel = nil
	end
	
	InitialiseBackgroundWheel(object)
	InitializeLogo(object)
	
	local mainBG = GetWidget('mainBG')
	local mainBGMouseEvent = LuaTrigger.GetTrigger('MainBGMouseEvent') or LuaTrigger.CreateCustomTrigger('MainBGMouseEvent',
		{
			{ name	= 'onmouseover',	type	= 'boolean' },
			{ name	= 'onmouseout',		type	= 'boolean' },
		}
	)
	
	if (mainBG) then
		mainBG:SetCallback('onmouseover', function(widget)
			mainBGMouseEvent.onmouseover = true
			mainBGMouseEvent.onmouseout = false
			mainBGMouseEvent:Trigger(false)
		end)
		mainBG:SetCallback('onmouseout', function(widget)
			mainBGMouseEvent.onmouseover = false
			mainBGMouseEvent.onmouseout = true
			mainBGMouseEvent:Trigger(false)
		end)		
		mainBG:RefreshCallbacks()	
	end
	
	function BG.SetBGColor2(colorR, colorG, colorB)
		local mainBG_behind_glow_modelpanel = GetWidget('mainBG_behind_glow_modelpanel')
		local mainBGWheel 					= GetWidget('mainBGWheel')
	
		mainBGWheel:SetModel('/ui/main/background/model/model.mdf')
		libThread.threadFunc(function()	
			wait(1)			
			mainBG_behind_glow_modelpanel:SetEffect('/ui/main/background/main_bg.effect', colorR, colorG, colorB)
			mainBGWheel:SetEffect('/ui/main/background/front.effect', colorR, colorG, colorB)
		end)		
	end	
	
end

BackgroundRegister()
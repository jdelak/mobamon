-- new_game_animations.lua (12/2014)

-- General Animation Function
local generalAnimationThread = {}

local function LoadUp (widget, hasDelay, slidesX, slidesY, setXValue, setYValue, endXAt, endYAt, stayHidden)	
	local endX = endXAt or widget:GetX()
	local endY = endYAt or widget:GetY()
	
	if (generalAnimationThread[widget]) then
		generalAnimationThread[widget]:kill()
		generalAnimationThread[widget] = nil
	end
	
	generalAnimationThread[widget] = libThread.threadFunc(function()
		wait(500) -- start delay
			widget:SetVisible(0)
		
		if slidesX then
			widget:SetX(setXValue)
		end
		
		if slidesY then
			widget:SetY(setYValue)
		end
		
		if (not stayHidden) then
		
			wait(500) -- delay for fade in
			
			if hasDelay ~= nil then
				wait(hasDelay)
			end
			
			widget:FadeIn(200)
			
			if slidesX then
				widget:SlideX(endX, 300)
			end
			
			if slidesY then
				widget:SlideY(endY, 300)
			end
		end
		
		generalAnimationThread[widget] = nil
	end)
end

-- Core Animation LoadUp
local UILoaded					= object:GetWidget('gameUILoaded')
local ScoreboardVisible			= object:GetWidget('gameScoreboardContainers')

local leftCornerAnimation		= object:GetWidget('gameLeftCornerAnimation')
local inventoryAnimation		= object:GetWidget('gameInventoryAnimation')
local centerAnimation			= object:GetWidget('gameCenterAnimation')
local gameCenterContent			= object:GetWidget('gameCenterContent')
local minimapAnimation			= object:GetWidget('gameMinimapAnimation')
local minimapHeaderAnimation	= object:GetWidget('gameMinimapHeader')
local timersAnimation			= object:GetWidget('gameTimersAnimation')

local wasTutorial = false
local heroCenterUp = false
UILoaded:SetCallback('onshow', function(widget) 

	local function doLoadUp(isTutorial)	
		
		LoadUp(inventoryAnimation, 500, true, false, '-30h', nil)
		LoadUp(centerAnimation, nil, false, true, nil, '30h')
		
		if GetCvarBool('ui_swapMinimap') then
			LoadUp(leftCornerAnimation, nil, true, false, '-20h', nil, '0.9h')
			LoadUp(minimapAnimation, nil, true, false, '30h', nil, '-1.7h')
		else
			LoadUp(leftCornerAnimation, nil, true, false, '-20h', nil, '-0.9h')
			LoadUp(minimapAnimation, nil, true, false, '30h', nil, '1.7h')
		end
		
		LoadUp(minimapHeaderAnimation, 500, false, true, nil, '10h')
		LoadUp(timersAnimation, nil, false, true, nil, '-10h', nil, nil, isTutorial)	
		
		heroCenterUp = true
		wasTutorial = isTutorial or false
	end
	
	UILoaded:RegisterWatchLua('HeroUnit', function(widget, trigger)
		local heroEntity = trigger.heroEntity
		local isTutorial = (heroEntity == 'Hero_CapriceTutorial') or (heroEntity == 'Hero_CapriceTutorial2')
		
		if (isTutorial) and (not wasTutorial) then
			doLoadUp(isTutorial)
		end
		
	end)	
	
	gameCenterContent:RegisterWatchLua('GamePhase', function(widget, trigger)
		if (trigger.gamePhase == 7) then
			heroCenterUp = false
			LoadUp(centerAnimation, nil, false, true, nil, '30h', nil, nil, true)
		elseif (not heroCenterUp) and (trigger.gamePhase >= 4) then
			LoadUp(centerAnimation, nil, false, true, nil, '30h', nil, nil, false)
			heroCenterUp = true
		end
	end)
	
	local heroEntity = LuaTrigger.GetTrigger('HeroUnit').heroEntity
	local isTutorial = (heroEntity == 'Hero_CapriceTutorial') or (heroEntity == 'Hero_CapriceTutorial2')	
	
	doLoadUp(isTutorial)

end)
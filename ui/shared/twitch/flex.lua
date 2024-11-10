Flex = Flex or {}
mainUI 								= mainUI 								or {}
mainUI.savedLocally 				= mainUI.savedLocally 					or {}
mainUI.savedLocally.flex			= mainUI.savedLocally.flex 				or {}
mainUI.savedLocally.flex.groups		= mainUI.savedLocally.flex.groups 		or {}
mainUI.savedLocally.flex.widgets	= mainUI.savedLocally.flex.widgets		or {}
local object = object

local targetGroups = {
	--  group					  			move  	resize 		disproportionately
		-- {'gameMinimapContainers', 			true, 	false, 		false},
		-- {'gameInventory97Containers', 		true, 	true, 		true},
	}
local targetWidgets = {
	--  group					  move  	resize 		disproportionately
		-- {'gameTestButton', 		  true, 	true, 		true},
		-- {'gamePausedIndicator',	  true, 	true, 		true},
	}

function Flex.Reset()
	mainUI.savedLocally.flex = {}
	mainUI.savedLocally.flex.groups		= {}
	mainUI.savedLocally.flex.widgets	= {}	
	SaveState()
	Cmd('ReloadInterfaces')
end

function Flex.Load(loadOriginal)	
	
	if (loadOriginal) then
		for index, targetGroupTable in pairs(targetGroups) do
			local groupName = targetGroupTable[1]
			local group = object:GetGroup(groupName) or {}
			if (group) and (group[1]) then
				local groupFirstWidget = group[1]
				targetGroupTable.originalHeight 	= groupFirstWidget:GetHeight()
				targetGroupTable.originalWidth 		= groupFirstWidget:GetWidth()
				targetGroupTable.originalX 			= groupFirstWidget:GetAbsoluteX()
				targetGroupTable.originalY 			= groupFirstWidget:GetAbsoluteY()		
				targetGroupTable.originalAlign 		= groupFirstWidget:GetAlign()		
				targetGroupTable.originalVAlign 	= groupFirstWidget:GetVAlign()	
			end
		end
		
		for index, targetGroupTable in pairs(targetWidgets) do
			local targetWidgetName = targetGroupTable[1]
			local targetWidget = object:GetWidget(targetWidgetName)
			targetGroupTable.originalHeight 	= targetWidget:GetHeight()
			targetGroupTable.originalWidth 		= targetWidget:GetWidth()
			targetGroupTable.originalX 			= targetWidget:GetAbsoluteX()
			targetGroupTable.originalY 			= targetWidget:GetAbsoluteY()		
			targetGroupTable.originalAlign 		= targetWidget:GetAlign()		
			targetGroupTable.originalVAlign 	= targetWidget:GetVAlign()		
		end
	end
	
	if (mainUI.savedLocally.flex.widgets) then
		for index, groupTable in pairs(mainUI.savedLocally.flex.widgets) do
			for defIndex, defGroupTable in pairs(targetWidgets) do
				if (defGroupTable[1]) and (index) and  (defGroupTable[1] == index) then
					defGroupTable.overrideHeight 		= groupTable.overrideHeight 
					defGroupTable.overrideWidth 		= groupTable.overrideWidth
					defGroupTable.overrideX 			= groupTable.overrideX
					defGroupTable.overrideY 			= groupTable.overrideY
					defGroupTable.overrideAlign 		= groupTable.overrideAlign	
					defGroupTable.overrideVAlign 		= groupTable.overrideVAlign
				end
			end
		end
	end
	if (mainUI.savedLocally.flex.groups) then
		for index, groupTable in pairs(mainUI.savedLocally.flex.groups) do
			for defIndex, defGroupTable in pairs(targetGroups) do
				if (defGroupTable[1]) and (index) and  (defGroupTable[1] == index) then
					defGroupTable.overrideHeight 		= groupTable.overrideHeight 
					defGroupTable.overrideWidth 		= groupTable.overrideWidth
					defGroupTable.overrideX 			= groupTable.overrideX
					defGroupTable.overrideY 			= groupTable.overrideY
					defGroupTable.overrideAlign 		= groupTable.overrideAlign	
					defGroupTable.overrideVAlign 		= groupTable.overrideVAlign
				end
			end		
		end
	end	
	for index, targetGroupTable in pairs(targetGroups) do
		local groupName = targetGroupTable[1]
		local group = object:GetGroup(groupName) or {}
		if (group) and (group[1]) then
			local groupWidgets = object:GetGroup(groupName) or {}
			for groupWidgetIndex, groupWidget in pairs(groupWidgets) do
				if (targetGroupTable.overrideHeight) and (targetGroupTable.overrideWidth) and (targetGroupTable.overrideX) and (targetGroupTable.overrideY) then
					groupWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
					groupWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
					groupWidget:SetAbsoluteX(targetGroupTable.overrideX or targetGroupTable.originalX)
					groupWidget:SetAbsoluteY(targetGroupTable.overrideY or targetGroupTable.originalY)
				end
			end
		end
	end
	for index, targetGroupTable in pairs(targetWidgets) do
		local targetWidgetName = targetGroupTable[1]
		local targetWidget = object:GetWidget(targetWidgetName)
		if (targetGroupTable.overrideHeight) and (targetGroupTable.overrideWidth) and (targetGroupTable.overrideX) and (targetGroupTable.overrideY) then
			targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
			targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
			targetWidget:SetAbsoluteX(targetGroupTable.overrideX or targetGroupTable.originalX)
			targetWidget:SetAbsoluteY(targetGroupTable.overrideY or targetGroupTable.originalY)	
		end
	end		
end

function Flex.Save()	
	for index, targetGroupTable in pairs(targetGroups) do
		local groupName = targetGroupTable[1]
		local group = object:GetGroup(groupName) or {}
		if (group) and (group[1]) then
			local groupFirstWidget = group[1]
			mainUI.savedLocally.flex.groups[groupName] = {}
			mainUI.savedLocally.flex.groups[groupName].overrideHeight 		= groupFirstWidget:GetHeight()
			mainUI.savedLocally.flex.groups[groupName].overrideWidth 		= groupFirstWidget:GetWidth()
			mainUI.savedLocally.flex.groups[groupName].overrideX 			= groupFirstWidget:GetAbsoluteX()
			mainUI.savedLocally.flex.groups[groupName].overrideY 			= groupFirstWidget:GetAbsoluteY()		
			mainUI.savedLocally.flex.groups[groupName].overrideAlign 		= groupFirstWidget:GetAlign()		
			mainUI.savedLocally.flex.groups[groupName].overrideVAlign 		= groupFirstWidget:GetVAlign()				
		end
	end

	for index, targetGroupTable in pairs(targetWidgets) do
		local targetWidgetName = targetGroupTable[1]
		local targetWidget = object:GetWidget(targetWidgetName)
		mainUI.savedLocally.flex.widgets[targetWidgetName] = {}
		mainUI.savedLocally.flex.widgets[targetWidgetName].overrideHeight 		= targetWidget:GetHeight()
		mainUI.savedLocally.flex.widgets[targetWidgetName].overrideWidth 		= targetWidget:GetWidth()
		mainUI.savedLocally.flex.widgets[targetWidgetName].overrideX 			= targetWidget:GetAbsoluteX()
		mainUI.savedLocally.flex.widgets[targetWidgetName].overrideY 			= targetWidget:GetAbsoluteY()		
		mainUI.savedLocally.flex.widgets[targetWidgetName].overrideAlign 		= targetWidget:GetAlign()		
		mainUI.savedLocally.flex.widgets[targetWidgetName].overrideVAlign 		= targetWidget:GetVAlign()		
	end	
	SaveState()
	Flex.Load(false)
end

function Flex.Revert()	
	for index, targetGroupTable in pairs(targetGroups) do
		local groupName = targetGroupTable[1]
		local group = object:GetGroup(groupName) or {}
		if (group) and (group[1]) then
			local groupWidgets = object:GetGroup(groupName) or {}
			for groupWidgetIndex, groupWidget in pairs(groupWidgets) do
				groupWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
				groupWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
				groupWidget:SetAbsoluteX(targetGroupTable.overrideX or targetGroupTable.originalX)
				groupWidget:SetAbsoluteY(targetGroupTable.overrideY or targetGroupTable.originalY)
			end
		end
	end
	for index, targetGroupTable in pairs(targetWidgets) do
		local targetWidgetName = targetGroupTable[1]
		local targetWidget = object:GetWidget(targetWidgetName)

		targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
		targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
		targetWidget:SetAbsoluteX(targetGroupTable.overrideX or targetGroupTable.originalX)
		targetWidget:SetAbsoluteY(targetGroupTable.overrideY or targetGroupTable.originalY)	
	end		
end

function Flex.Disable()	
	local groupWidgets = object:GetGroup('flex_helpers') or {}
	for groupWidgetIndex, groupWidget in pairs(groupWidgets) do	
		groupWidget:Destroy()
	end
	
	object:GetWidget('flex_helper_layer'):SetVisible(0)
	object:GetWidget('flex_command_layer'):SetVisible(0)	
end	

function Flex.Enable()
	
	object:GetWidget('flex_helper_layer'):SetVisible(1)
	object:GetWidget('flex_command_layer'):SetVisible(1)
	
	local command_cancelButton 					= object:GetWidget('flex_command_layer_btn_cancel')
	local command_keepButton 					= object:GetWidget('flex_command_layer_btn_keep')	
	
	command_keepButton:SetCallback('onclick', function(widget)
		Flex.Save()
		Flex.Disable()
	end)
	
	command_cancelButton:SetCallback('onclick', function(widget)
		Flex.Revert()	
		Flex.Disable()
	end)	
	
	for index, targetGroupTable in pairs(targetGroups) do
		local groupName = targetGroupTable[1]
		local group = object:GetGroup(groupName) or {}
		if (group) and (group[1]) then

			local groupFirstWidget = group[1]
			local flex_index = 'group_' .. index
			local flex_helper_group
			if (targetGroupTable[3]) or (targetGroupTable[4]) then
				flex_helper_group 			= object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template', 'index', flex_index, 'canMove', tostring(targetGroupTable[2] or false), 'canResizeConstrained', tostring(targetGroupTable[3] or false), 'canResize', tostring(targetGroupTable[4] or false))
			else	
				flex_helper_group 			= object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template_nosize', 'index', flex_index, 'canMove', tostring(targetGroupTable[2] or false), 'canResizeConstrained', tostring(targetGroupTable[3] or false), 'canResize', tostring(targetGroupTable[4] or false))
			end
			local flex_helper 					= flex_helper_group[1]
			local cancelButton 					= object:GetWidget('flex_helper_' .. flex_index .. '_btn_cancel')
			local keepButton 					= object:GetWidget('flex_helper_' .. flex_index .. '_btn_keep')		
		
			local groupWidgets = object:GetGroup(groupName) or {}
			for groupWidgetIndex, groupWidget in pairs(groupWidgets) do
				groupWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
				groupWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
				groupWidget:SetAbsoluteX(targetGroupTable.overrideX or targetGroupTable.originalX)
				groupWidget:SetAbsoluteY(targetGroupTable.overrideY or targetGroupTable.originalY)
			end	
		
			flex_helper:SetHeight(groupFirstWidget:GetHeight())
			flex_helper:SetWidth(groupFirstWidget:GetWidth())

			flex_helper:SetAbsoluteX(groupFirstWidget:GetAbsoluteX())
			flex_helper:SetAbsoluteY(groupFirstWidget:GetAbsoluteY())
			
			flex_helper:SetCallback('onstartdrag', function(widget)
				flex_helper:SetAbsoluteX(flex_helper:GetAbsoluteX())
				flex_helper:SetAbsoluteY(flex_helper:GetAbsoluteY())
				flex_helper:SetCallback('onframe', function(widget)
					local groupWidgets = widget:GetGroup(groupName) or {}
					for groupWidgetIndex, groupWidget in pairs(groupWidgets) do
						groupWidget:SetHeight(flex_helper:GetHeight())
						groupWidget:SetWidth(flex_helper:GetWidth())

						groupWidget:SetAbsoluteX(flex_helper:GetAbsoluteX())
						groupWidget:SetAbsoluteY(flex_helper:GetAbsoluteY())
					end
				end)
			end)
			
			flex_helper:SetCallback('onenddrag', function(widget)
				cancelButton:SetVisible(1)
				flex_helper:ClearCallback('onframe')
				
				local y = flex_helper:GetAbsoluteY()
				y = math.max(y, 0)
				y = math.min(y, GetScreenHeight() - flex_helper:GetHeight())				
				
				local x = flex_helper:GetAbsoluteX()
				x = math.max(x, 0)
				x = math.min(x, GetScreenWidth() - flex_helper:GetWidth())
				
				flex_helper:SetAbsoluteX(x)
				flex_helper:SetAbsoluteY(y)				
				local groupWidgets = widget:GetGroup(groupName) or {}
				for groupWidgetIndex, groupWidget in pairs(groupWidgets) do
					groupWidget:SetHeight(flex_helper:GetHeight())
					groupWidget:SetWidth(flex_helper:GetWidth())

					groupWidget:SetAbsoluteX(flex_helper:GetAbsoluteX())
					groupWidget:SetAbsoluteY(flex_helper:GetAbsoluteY())
				end				
			end)
			
			cancelButton:SetCallback('onclick', function(widget)
				cancelButton:SetVisible(1)
				flex_helper:ClearCallback('onframe')
				flex_helper:SetHeight(targetGroupTable.originalHeight)
				flex_helper:SetWidth(targetGroupTable.originalWidth)
				flex_helper:SetAbsoluteX(targetGroupTable.originalX)
				flex_helper:SetAbsoluteY(targetGroupTable.originalY)
			
				local groupWidgets = widget:GetGroup(groupName) or {}
				for groupWidgetIndex, groupWidget in pairs(groupWidgets) do
					groupWidget:SetHeight(flex_helper:GetHeight())
					groupWidget:SetWidth(flex_helper:GetWidth())
					groupWidget:SetAbsoluteX(flex_helper:GetAbsoluteX())
					groupWidget:SetAbsoluteY(flex_helper:GetAbsoluteY())
				end			
			end)

		end
	end
	
	for index, targetGroupTable in pairs(targetWidgets) do

		local targetWidgetName = targetGroupTable[1]
		local targetWidget = object:GetWidget(targetWidgetName)
		
		local flex_index = 'single_' .. index
		local flex_helper_group
		if (targetGroupTable[3]) or (targetGroupTable[4]) then
			flex_helper_group 			= object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template', 'index', flex_index, 'canMove', tostring(targetGroupTable[2] or false), 'canResizeConstrained', tostring(targetGroupTable[3] or false), 'canResize', tostring(targetGroupTable[4] or false))
		else	
			flex_helper_group 			= object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template_nosize', 'index', flex_index, 'canMove', tostring(targetGroupTable[2] or false), 'canResizeConstrained', tostring(targetGroupTable[3] or false), 'canResize', tostring(targetGroupTable[4] or false))
		end		
		local flex_helper 					= flex_helper_group[1]
		local cancelButton 					= object:GetWidget('flex_helper_' .. flex_index .. '_btn_cancel')
		local keepButton 					= object:GetWidget('flex_helper_' .. flex_index .. '_btn_keep')

		targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
		targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
		targetWidget:SetAbsoluteX(targetGroupTable.overrideX or targetGroupTable.originalX)
		targetWidget:SetAbsoluteY(targetGroupTable.overrideY or targetGroupTable.originalY)	
	
		flex_helper:SetHeight(targetWidget:GetHeight())
		flex_helper:SetWidth(targetWidget:GetWidth())

		flex_helper:SetAbsoluteX(targetWidget:GetAbsoluteX())
		flex_helper:SetAbsoluteY(targetWidget:GetAbsoluteY())
		
		flex_helper:SetCallback('onstartdrag', function(widget)
			flex_helper:SetAbsoluteX(flex_helper:GetAbsoluteX())
			flex_helper:SetAbsoluteY(flex_helper:GetAbsoluteY())
			flex_helper:SetCallback('onframe', function(widget)
				targetWidget:SetHeight(flex_helper:GetHeight())
				targetWidget:SetWidth(flex_helper:GetWidth())

				targetWidget:SetAbsoluteX(flex_helper:GetAbsoluteX())
				targetWidget:SetAbsoluteY(flex_helper:GetAbsoluteY())
			end)
		end)
		
		flex_helper:SetCallback('onenddrag', function(widget)
			cancelButton:SetVisible(1)
			flex_helper:ClearCallback('onframe')
			flex_helper:SetAbsoluteX(flex_helper:GetAbsoluteX())
			flex_helper:SetAbsoluteY(flex_helper:GetAbsoluteY())				
			
			targetWidget:SetHeight(flex_helper:GetHeight())
			targetWidget:SetWidth(flex_helper:GetWidth())

			targetWidget:SetAbsoluteX(flex_helper:GetAbsoluteX())
			targetWidget:SetAbsoluteY(flex_helper:GetAbsoluteY())
			
		end)
		
		cancelButton:SetCallback('onclick', function(widget)
			cancelButton:SetVisible(1)
			flex_helper:ClearCallback('onframe')
			flex_helper:SetHeight(targetGroupTable.originalHeight)
			flex_helper:SetWidth(targetGroupTable.originalWidth)
			flex_helper:SetAbsoluteX(targetGroupTable.originalX)
			flex_helper:SetAbsoluteY(targetGroupTable.originalY)
		
			targetWidget:SetHeight(flex_helper:GetHeight())
			targetWidget:SetWidth(flex_helper:GetWidth())

			targetWidget:SetAbsoluteX(flex_helper:GetAbsoluteX())
			targetWidget:SetAbsoluteY(flex_helper:GetAbsoluteY())
		
		end)

	end	
	
end
	
function Flex.Toggle()
	if object:GetWidget('flex_command_layer') then
		if object:GetWidget('flex_command_layer'):IsVisible() then
			Flex.Disable()
		else
			Flex.Enable()
		end
	end
end

local isLoaded = false
function Flex.Init(force)
	if (force) or (not isLoaded) then
		isLoaded = true
		Flex.Load(true)
	end
end

if GetCvarBool('ui_dev_flex') then
	object:GetWidget('flex_command_layer'):RegisterWatchLua('GamePhase', function() Flex.Init(false) end)
	object:GetWidget('flex_command_layer'):RegisterWatchLua('GameReinitialize', function() Flex.Init(true) end)
	object:GetWidget('game_menu_flex'):SetVisible(1)
end


FlexOverlay = FlexOverlay or {}
mainUI 										= mainUI 										or {}
mainUI.savedLocally 						= mainUI.savedLocally 							or {}
mainUI.savedLocally.FlexOverlay			= mainUI.savedLocally.FlexOverlay 			or {}
mainUI.savedLocally.FlexOverlay.widgets = mainUI.savedLocally.FlexOverlay.widgets 		or {}
local object = object

FlexOverlay.stateTrigger = LuaTrigger.GetTrigger('FlexStateTrigger') or LuaTrigger.CreateCustomTrigger('FlexStateTrigger', {
	{ name	=   'panelOpen',			type	= 'boolean'},
	{ name	=   'overlayVisible',		type	= 'boolean'},
	{ name	=   'unsavedChanges',		type	= 'boolean'},
	{ name	=   'panelState',			type	= 'string'},
})

local interface = object
GAME_STATE = GAME_STATE or {}

local function flex()

	-- Cmd('Clear')
	println('^y^: FLEXING SO HARD')

	local flex_instantiate_overlay_layer 	= object:GetWidget('flex_instantiate_overlay_layer')
	
	interface:RegisterWatch('GAME_STATE_TRIGGER', function(widget, ...)
	
		local function GetParamByIndex(index)
			if index and arg and arg[index] then
				return arg[index]
			else
				return nil
			end
		end
		
		local actionType = GetParamByIndex(1)
		
		if (actionType) then
			if (actionType == 'SetActiveGame') then
			
			elseif (actionType == 'LoadGameInterface') then
			
			elseif (actionType == 'EnableInterfaceElement') then			
			
			elseif (actionType == 'DisableInterfaceElement') then
			
			end			
		end
		
	end)

	function FlexOverlay.InstantiateAndRegisterOverlayWidgets(flex_instantiate_overlay_layer)
		local widgets = mainUI.savedLocally.FlexOverlay.widgets
		
		local previousGroupTable = object:GetGroup('flex_instantiated_overlay_widgets')

		if (previousGroupTable) and (#previousGroupTable > 0) then
			for i, v in pairs(previousGroupTable) do	
				if (v) and (v:IsValid()) then
					v:SetVisible(0)
					v:Destroy()
				end
			end
		end
		
		libThread.threadFunc(function()
			wait(100)

			for i, v in pairs(widgets) do	

				local width = (v.overrideWidth or v.originalWidth or v[3])
				local height = (v.overrideHeight or v.originalHeight or v[4])		
				local x = (v.overrideX or v.originalX or v[5])		
				local y = (v.overrideY or v.originalY or v[6])
				
				if (v[1] == 'image') then				
					 flex_instantiate_overlay_layer:Instantiate('flex_instantiate_template_image',
						'group',	'flex_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'texture', 	v[2],
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end					
				elseif (v[1] == 'label') then
					flex_instantiate_overlay_layer:Instantiate('flex_instantiate_template_label',
						'group',	'flex_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'label', 	v[2],
						'font', 	GetFontThatFits(width, v[2], nil),
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end					
				elseif (v[1] == 'webcam') then
					flex_instantiate_overlay_layer:Instantiate('flex_instantiate_template_webcam',
						'group',	'flex_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end				
				elseif (v[1] == 'panel') then
					widgets[i].pointer = flex_instantiate_overlay_layer:InstantiateAndReturn('flex_instantiate_template_panel',
						'group',	'flex_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'color', 	v[2],
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end					
				else
					widgets[i] = nil
				end
			end
		end)	
	end
	
	function FlexOverlay.ChangeMode(newMode)
		local newMode = newMode or 'live'
		
		local flex_instantiate_overlay_layer 			= object:GetWidget('flex_instantiate_overlay_layer')
		
		flex_instantiate_overlay_layer:SetVisible(newMode == 'live')

	end
	
	function FlexOverlay.SpawnOverlay()
		if (mainUI.savedLocally) and (mainUI.savedLocally.FlexEdit) and (mainUI.savedLocally.FlexEdit.widgets) then
			mainUI.savedLocally.FlexOverlay = mainUI.savedLocally.FlexOverlay or {}
			mainUI.savedLocally.FlexOverlay.widgets = {}
			for i, v in pairs(mainUI.savedLocally.FlexEdit.widgets) do
				table.insert(mainUI.savedLocally.FlexOverlay.widgets, {
					[1] = v[1], 
					[2] = v[2], 
					['widgetName'] = v.widgetName,
					['overrideWidth'] = v.overrideWidth,
					['originalWidth'] = v.originalWidth,
					['overrideHeight'] = v.overrideHeight,
					['originalHeight'] = v.originalHeight,
					['originalY'] = v.originalY,
					['originalX'] = v.originalX,
					['overrideY'] = v.overrideY,
					['overrideX'] = v.overrideX,
					['scriptFunction'] = v.scriptFunction,
				})
			end
		end
		FlexOverlay.InstantiateAndRegisterOverlayWidgets(flex_instantiate_overlay_layer)	
		GetWidget('flex_instantiate_overlay_layer', 'game'):FadeIn(250)
	end
	
	local isLoaded = false
	function FlexOverlay.InitOverlay(force)
		local loginStatusTrigger = LuaTrigger.GetTrigger('LoginStatus')
		local mainPanelStatusTrigger = LuaTrigger.GetTrigger('mainPanelStatus')
		local GamePhaseTrigger = LuaTrigger.GetTrigger('GamePhase')
		
		if (loginStatusTrigger.isLoggedIn) and (loginStatusTrigger.hasIdent) and (loginStatusTrigger.isIdentPopulated) and (GamePhaseTrigger.gamePhase >= 4) then
			if (force) or (not isLoaded) then
				isLoaded = true
				FlexOverlay.SpawnOverlay()
				FlexOverlay.ChangeMode('live')
			end
		end
	end

	object:GetWidget('flex_instantiate_overlay_layer'):RegisterWatchLua('GamePhase', function() FlexOverlay.InitOverlay(false) end)
	object:GetWidget('flex_instantiate_overlay_layer'):RegisterWatchLua('GameReinitialize', function() FlexOverlay.InitOverlay(false) end)
	object:GetWidget('flex_instantiate_overlay_layer'):RegisterWatchLua('LoginStatus', function() FlexOverlay.InitOverlay(false) end, false, nil, 'isIdentPopulated', 'hasIdent', 'isLoggedIn')
	object:GetWidget('flex_instantiate_overlay_layer'):RegisterWatchLua('mainPanelStatus', function() FlexOverlay.InitOverlay(false) end, false, nil, 'main')

end

flex(object)






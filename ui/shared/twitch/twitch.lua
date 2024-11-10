TwitchOverlay = TwitchOverlay or {}
mainUI 										= mainUI 										or {}
mainUI.savedLocally 						= mainUI.savedLocally 							or {}
mainUI.savedLocally.TwitchOverlay			= mainUI.savedLocally.TwitchOverlay 			or {}
mainUI.savedLocally.TwitchOverlay.widgets = mainUI.savedLocally.TwitchOverlay.widgets 		or {}
local object = object

TwitchOverlay.stateTrigger = LuaTrigger.GetTrigger('TwitchStateTrigger') or LuaTrigger.CreateCustomTrigger('TwitchStateTrigger', {
	{ name	=   'panelOpen',			type	= 'boolean'},
	{ name	=   'overlayVisible',		type	= 'boolean'},
	{ name	=   'unsavedChanges',		type	= 'boolean'},
	{ name	=   'panelState',			type	= 'string'},
})
TwitchOverlay.statusTrigger 			= LuaTrigger.GetTrigger('TwitchStatus')
TwitchOverlay.webCamDevicesTrigger 		= LuaTrigger.GetTrigger('TwitchWebCamDevices')
TwitchOverlay.ingestServersTrigger 		= LuaTrigger.GetTrigger('TwitchIngestServers')

local function Register(object)
	
	local object = object

	local twitch_instantiate_layer 	= object:GetWidget('twitch_instantiate_overlay_layer')
	
	function TwitchOverlay.InstantiateAndRegisterOverlayWidgets(twitch_instantiate_layer)
		local widgets = mainUI.savedLocally.TwitchOverlay.widgets
		
		local previousGroupTable = object:GetGroup('twitch_instantiated_overlay_widgets')

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
					 twitch_instantiate_layer:Instantiate('twitch_instantiate_template_image',
						'group',	'twitch_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'texture', 	v[2],
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)
				elseif (v[1] == 'label') then
					twitch_instantiate_layer:Instantiate('twitch_instantiate_template_label',
						'group',	'twitch_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'label', 	v[2],
						'font', 	GetFontThatFits(width, v[2], nil),
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)
				elseif (v[1] == 'webcam') then
					twitch_instantiate_layer:Instantiate('twitch_instantiate_template_webcam',
						'group',	'twitch_instantiated_overlay_widgets',
						'index',	v.widgetName .. '_overlay',
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)
				end
			end
		end)	
	end
	
	function TwitchOverlay.ChangeMode(newMode)
		local newMode = newMode or 'live'
		
		local twitch_instantiate_overlay_layer 			= object:GetWidget('twitch_instantiate_overlay_layer')
		local twitch_brb_overlay_layer 					= object:GetWidget('twitch_brb_overlay_layer')
		local twitch_ad_overlay_layer 					= object:GetWidget('twitch_ad_overlay_layer')
		local twitch_countin_overlay_layer 				= object:GetWidget('twitch_countin_overlay_layer')
		
		twitch_instantiate_overlay_layer:SetVisible(newMode == 'live')
		twitch_brb_overlay_layer:SetVisible(newMode == 'brb')
		twitch_ad_overlay_layer:SetVisible(newMode == 'ad')
		twitch_countin_overlay_layer:SetVisible(newMode == 'countin')

	end
	
	function TwitchOverlay.SpawnOverlay()
		if (mainUI.savedLocally) and (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.widgets) then
			mainUI.savedLocally.TwitchOverlay = mainUI.savedLocally.TwitchOverlay or {}
			mainUI.savedLocally.TwitchOverlay.widgets = {}
			for i, v in pairs(mainUI.savedLocally.TwitchEdit.widgets) do
				table.insert(mainUI.savedLocally.TwitchOverlay.widgets, {
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
				})
			end
		end
		TwitchOverlay.InstantiateAndRegisterOverlayWidgets(twitch_instantiate_layer)	
	end
	
	local isLoaded = false
	function TwitchOverlay.InitOverlay(force)
		local loginStatusTrigger = LuaTrigger.GetTrigger('LoginStatus')
		local mainPanelStatusTrigger = LuaTrigger.GetTrigger('mainPanelStatus')
		local TwitchStatus = LuaTrigger.GetTrigger('TwitchStatus')
		
		if (TwitchStatus.initialized) and (loginStatusTrigger.isLoggedIn) and (loginStatusTrigger.hasIdent) and (loginStatusTrigger.isIdentPopulated) and (mainPanelStatusTrigger.main == 101) then
			if (force) or (not isLoaded) then
				isLoaded = true
				TwitchOverlay.SpawnOverlay()
				TwitchOverlay.ChangeMode('live')
			end
		end
	end

	object:GetWidget('twitch_instantiate_overlay_layer'):RegisterWatchLua('GamePhase', function() TwitchOverlay.InitOverlay(false) end)
	object:GetWidget('twitch_instantiate_overlay_layer'):RegisterWatchLua('GameReinitialize', function() TwitchOverlay.InitOverlay(false) end)
	object:GetWidget('twitch_instantiate_overlay_layer'):RegisterWatchLua('LoginStatus', function() TwitchOverlay.InitOverlay(false) end, false, nil, 'isIdentPopulated', 'hasIdent', 'isLoggedIn')
	object:GetWidget('twitch_instantiate_overlay_layer'):RegisterWatchLua('mainPanelStatus', function() TwitchOverlay.InitOverlay(false) end, false, nil, 'main')
	object:GetWidget('twitch_instantiate_overlay_layer'):RegisterWatchLua('TwitchStatus', function() TwitchOverlay.InitOverlay(false) end, false, nil, 'initialized')

end

if ((GetCvarString('host_videoDriver') == 'vid_d9')) and (Twitch) then
	Register(object)
end
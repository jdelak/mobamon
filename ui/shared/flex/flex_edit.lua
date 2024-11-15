FlexEdit = FlexEdit or {}
mainUI 										= mainUI 									or {}
mainUI.savedLocally 						= mainUI.savedLocally 						or {}
mainUI.savedLocally.FlexEdit				= mainUI.savedLocally.FlexEdit 			or {}
mainUI.savedLocally.FlexEdit.settings		= mainUI.savedLocally.FlexEdit.settings 	or {}
mainUI.savedLocally.FlexEdit.widgets		= mainUI.savedLocally.FlexEdit.widgets 	or {}

local object = object

FlexEdit.stateTrigger = LuaTrigger.GetTrigger('FlexStateTrigger') or LuaTrigger.CreateCustomTrigger('FlexStateTrigger', {
	{ name	=   'panelOpen',			type	= 'boolean'},
	{ name	=   'overlayVisible',		type	= 'boolean'},
	{ name	=   'unsavedChanges',		type	= 'boolean'},
	{ name	=   'panelState',			type	= 'string'},
})

local function Register(object)

	local flexPanel 							= object:GetWidget('Flex_Panel')	

	local flex_edit_center_screen_announce		= object:GetWidget('flex_edit_center_screen_announce')
	local Flex_Logged_Status 					= object:GetWidget('Flex_Logged_Status')	
	local Flex_Logged_StatusType 				= object:GetWidget('Flex_Logged_StatusType')	
	local Flex_Overlays_Auto 					= object:GetWidget('Flex_Overlays_Auto')	
	local Flex_Overlays_Close 					= object:GetWidget('Flex_Overlays_Close')	
	
	function FlexEdit.CoerceHeightToPercent(targetWidget, incValue)
		local value = targetWidget:GetHeightFromString(incValue)
		value = ((value / GetScreenHeight()) * 100) .. '%'
		return value
	end
	
	function FlexEdit.CoerceWidthToPercent(targetWidget, incValue)
		local value = targetWidget:GetWidthFromString(incValue)
		value = ((value / GetScreenWidth()) * 100) .. '%'
		return value
	end	
	
	function FlexEdit.ConvertHeightPercentToPixels(incValue)
		local value = object:GetHeightFromString(incValue)
		return value
	end
	
	function FlexEdit.ConvertWidthPercentToPixels(incValue)
		local value = object:GetWidthFromString(incValue)
		return value
	end		

	local flex_instantiate_layer 	= object:GetWidget('flex_instantiate_layer')
	local flex_helper_layer 		= object:GetWidget('flex_helper_layer')
	
	function FlexEdit.ResizeFont(widget)
		widget:SetFont(GetFontThatFits(widget:GetWidth(), widget:GetText(), nil))
	end
	
	function FlexEdit.InstantiateAndRegisterWidgets(flex_instantiate_layer, callback)
		local widgets = mainUI.savedLocally.FlexEdit.widgets
		for i, v in pairs(widgets) do	
			local widget = object:GetWidget('flexinstantiate_template_' .. v.widgetName)
			if (not widget) or (not widget:IsValid()) then
				if (widget) then
					widget:Destroy()
				end
				local width = (v.overrideWidth or v.originalWidth or v[3])
				local height = (v.overrideHeight or v.originalHeight or v[4])		
				local x = (v.overrideX or v.originalX or v[5])		
				local y = (v.overrideY or v.originalY or v[6])		
				
				if (v[1] == 'image') then				
					widgets[i].pointer = flex_instantiate_layer:InstantiateAndReturn('flex_instantiate_template_image',
						'index',	v.widgetName,
						'texture', 	v[2],
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)				
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end					
				elseif (v[1] == 'label') then
					widgets[i].pointer = flex_instantiate_layer:InstantiateAndReturn('flex_instantiate_template_label',
						'index',	v.widgetName,
						'label', 	v[2],
						'font', 	GetFontThatFits(width, v[2], nil),
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]	
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)			
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end						
				elseif (v[1] == 'webcam') then
					widgets[i].pointer = flex_instantiate_layer:InstantiateAndReturn('flex_instantiate_template_webcam',
						'index',	v.widgetName,
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]				
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end						
				elseif (v[1] == 'panel') then
					widgets[i].pointer = flex_instantiate_layer:InstantiateAndReturn('flex_instantiate_template_panel',
						'index',	v.widgetName,
						'color', 	v[2],
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)
					if (v.scriptFunction) and (not Empty(v.scriptFunction)) then
						local scriptFunction = 'local index,self,i,v = ... ' .. v.scriptFunction
						loadstring(scriptFunction)(v.widgetName, widgets[i].pointer, i, v)
					end						
				else
					widgets[i] = nil					
				end
			end
		end
	end
	
	function FlexEdit.Reset()
	
		local groupWidgets = object:GetGroup('flex_helpers') or {}
		for groupWidgetIndex, groupWidget in pairs(groupWidgets) do	
			groupWidget:Destroy()
		end

		for index, targetGroupTable in pairs(mainUI.savedLocally.FlexEdit.widgets) do

			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)
			end			
		
			if (targetWidget) then
				targetWidget:SetVisible(0)
				targetWidget:Destroy()
			end
		end

		mainUI.savedLocally.Flex = mainUI.savedLocally.Flex or {}
		mainUI.savedLocally.FlexEdit = mainUI.savedLocally.FlexEdit or {}
		mainUI.savedLocally.FlexEdit.savedSettings = mainUI.savedLocally.FlexEdit.savedSettings or {}		
		mainUI.savedLocally.FlexEdit.widgetCount = 1
		mainUI.savedLocally.FlexEdit.widgets = {}	
		
		SaveState()
		
		FlexEdit.PopulateWidgetList() -- doesn't rely on them existing

		FlexEdit.InstantiateAndRegisterWidgets(flex_instantiate_layer, function()
			FlexEdit.Load(true, true)	-- Get the position and size info
			FlexEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
		end) -- Create the widget and pointer at [7]	
		
		FlexEdit.stateTrigger.unsavedChanges = false
		FlexEdit.stateTrigger:Trigger(false)		
		
	end

	function FlexEdit.Load(loadOriginal, dontReload)		
		local widgets = mainUI.savedLocally.FlexEdit.widgets
		
		if (loadOriginal) then
			for index, targetGroupTable in pairs(widgets) do
				local targetWidget
				if ((not targetGroupTable.hasBeenLoaded)) then
					if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
						targetWidget = targetGroupTable.pointer
					elseif ((object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
						targetWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)
					end
					if (targetWidget) then
						targetGroupTable.originalHeight 	= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
						targetGroupTable.originalWidth 		= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
						targetGroupTable.originalX 			= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
						targetGroupTable.originalY 			= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
						targetGroupTable.originalAlign 		= targetWidget:GetAlign()		
						targetGroupTable.originalVAlign 	= targetWidget:GetVAlign()
						targetGroupTable.hasBeenLoaded = true	 
					end
				end
			end
		end

		for index, targetGroupTable in pairs(widgets) do
			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)
			end		
		
			if (targetWidget) and ((not targetGroupTable.hasBeenLoaded) or (not dontReload)) then			
				if (targetGroupTable.overrideHeight) and (targetGroupTable.overrideWidth) and (targetGroupTable.overrideX) and (targetGroupTable.overrideY) then
					targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
					targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
					targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(targetGroupTable.overrideX or targetGroupTable.originalX))
					targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(targetGroupTable.overrideY or targetGroupTable.originalY))
				end
			end
		end		

	end

	function FlexEdit.Save()

		for index, targetGroupTable in pairs(mainUI.savedLocally.FlexEdit.widgets) do
			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)
			end			
		
			mainUI.savedLocally.FlexEdit.widgets[index] = mainUI.savedLocally.FlexEdit.widgets[index] or {}
			if (targetWidget) then
				mainUI.savedLocally.FlexEdit.widgets[index] = mainUI.savedLocally.FlexEdit.widgets[index] or {}
				mainUI.savedLocally.FlexEdit.widgets[index].overrideHeight 		= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
				mainUI.savedLocally.FlexEdit.widgets[index].overrideWidth 		= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
				mainUI.savedLocally.FlexEdit.widgets[index].overrideX 			= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
				mainUI.savedLocally.FlexEdit.widgets[index].overrideY 			= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
				mainUI.savedLocally.FlexEdit.widgets[index].overrideAlign 		= targetWidget:GetAlign()		
				mainUI.savedLocally.FlexEdit.widgets[index].overrideVAlign 		= targetWidget:GetVAlign()
				mainUI.savedLocally.FlexEdit.widgets[index].originalHeight 		= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
				mainUI.savedLocally.FlexEdit.widgets[index].originalWidth 		= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
				mainUI.savedLocally.FlexEdit.widgets[index].originalX 			= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
				mainUI.savedLocally.FlexEdit.widgets[index].originalY 			= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
				mainUI.savedLocally.FlexEdit.widgets[index].originalAlign 		= targetWidget:GetAlign()		
				mainUI.savedLocally.FlexEdit.widgets[index].originalVAlign 		= targetWidget:GetVAlign()				
				mainUI.savedLocally.FlexEdit.widgets[index].temp 					= false
			end
		end	
		SaveState()		
		
		FlexEdit.Load(false, false)
		FlexEdit.stateTrigger.unsavedChanges = false
		FlexEdit.stateTrigger:Trigger(false)		
		
		FlexEdit.PopulateWidgetList()
		libThread.threadFunc(function() -- This must occur after the list has been populated as it gives function to those buttons
			wait(10)		
			FlexEdit.UpdateEditorWidgets()
		end)
		
	end

	function FlexEdit.Revert()	
		for index, targetGroupTable in pairs(mainUI.savedLocally.FlexEdit.widgets) do
			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)
			end			
		
			local Flex_index 						=  targetGroupTable.widgetName	
			if (targetGroupTable[3]) or (targetGroupTable[4]) then
				flex_helper_group 			= object:GetWidget('flex_helper_'..Flex_index) or object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template', 'index', Flex_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
			else	
				flex_helper_group 			= object:GetWidget('flex_helper_'..Flex_index) or object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template_nosize', 'index', Flex_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
			end		
			local flex_helper 				= flex_helper_group[1] or flex_helper_group		
		
			if (targetWidget) then			
				if (targetGroupTable.temp) then
					targetWidget:SetVisible(0)
					targetWidget:Destroy()
					object:GetWidget('flex_helper_'..targetGroupTable.widgetName):SetVisible(0)

					-- FlexEdit.PopulateWidgetList()	-- This causes a crash for some reason, do this other derpy thing instead
					local Flex_Overlays_List_Listbox 				= object:GetWidget('Flex_Overlays_List_Listbox')		
					Flex_Overlays_List_Listbox:HideItemByValue(targetGroupTable.widgetName)					
					
					mainUI.savedLocally.FlexEdit.widgets[index] = nil		
					targetGroupTable = nil
				else
					targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
					targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
					targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(targetGroupTable.overrideX or targetGroupTable.originalX))
					targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(targetGroupTable.overrideY or targetGroupTable.originalY))	
					
					flex_helper:ClearCallback('onframe')
					flex_helper:SetHeight(targetGroupTable.originalHeight)
					flex_helper:SetWidth(targetGroupTable.originalWidth)
					flex_helper:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(targetGroupTable.originalX))
					flex_helper:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(targetGroupTable.originalY))				
				end
			end
		end		
		FlexEdit.stateTrigger.unsavedChanges = false
		FlexEdit.stateTrigger:Trigger(false)		
	end

	function FlexEdit.DisableEditor()	
		object:GetWidget('flex_helper_layer'):SetVisible(0)
		object:GetWidget('flex_command_layer'):SetVisible(0)		
		object:GetWidget('flex_instantiate_layer'):SetVisible(0)	
		
		FlexEdit.stateTrigger.unsavedChanges = false
		FlexEdit.stateTrigger:Trigger(false)	
			
		FlexOverlay.SpawnOverlay(true)
		
		if (flexPanelWasOpen) then
			flexPanelWasOpen = false
			FlexEdit.stateTrigger.panelOpen = true
			FlexEdit.stateTrigger:Trigger(false)	
		end
		
		SaveState()
		
	end	

	function FlexEdit.PopulateWidgetList()

		local Flex_Overlays_List_Listbox 				= object:GetWidget('Flex_Overlays_List_Listbox')	
		
		Flex_Overlays_List_Listbox:Clear()
		
		local count = 0
		
		for _, targetGroupTable in pairs(mainUI.savedLocally.FlexEdit.widgets) do
			count = count + 1
			if (not targetGroupTable.temp) then
				Flex_Overlays_List_Listbox:AddTemplateListItem('flex_widget_listitem_template', targetGroupTable.widgetName, 'label', Translate('flex_widget_type_'..targetGroupTable[1], 'value', count), 'texture', Translate('flex_widget_type_'..targetGroupTable[1]..'_texture', 'value', count), 'index', targetGroupTable.widgetName)
			else
				Flex_Overlays_List_Listbox:AddTemplateListItem('flex_widget_listitem_template', targetGroupTable.widgetName, 'label', '^980'..Translate('flex_widget_type_'..targetGroupTable[1], 'value', count), 'texture', Translate('flex_widget_type_'..targetGroupTable[1]..'_texture', 'value', count), 'index', targetGroupTable.widgetName)
			end 
		end
		
	end			
	
	function FlexEdit.AddWebcam()
		mainUI.savedLocally.FlexEdit.widgetCount = mainUI.savedLocally.FlexEdit.widgetCount + 1
		
		local newWebcamTable 		= {'webcam', '', 						    '20h', '20h', '0h', '80h'}
		newWebcamTable.temp 		= true
		newWebcamTable.widgetName 	= mainUI.savedLocally.FlexEdit.widgetCount
		
		table.insert(mainUI.savedLocally.FlexEdit.widgets, newWebcamTable)
		
		FlexEdit.PopulateWidgetList() -- doesn't rely on them existing

		FlexEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, function()
			FlexEdit.Load(true, true)	-- Get the position and size info
			FlexEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
		end) -- Create the widget and pointer at [7]

		FlexEdit.stateTrigger.unsavedChanges = true
		FlexEdit.stateTrigger:Trigger(false)		
		
		SaveState()
	end	
	
	function FlexEdit.AddPanel()
		
		local Flex_Panel_Content 				= object:GetWidget('Flex_Panel_Content')
		local Flex_Panel_Content_input_btn 	= object:GetWidget('Flex_Panel_Content_input_btn')
		
		local function SpawnPanel(red, green, blue)
			local width 			= '20h'
			local height 			= '10h'
			local color 			= red ..', ' .. green .. ', ' .. blue
			
			mainUI.savedLocally.FlexEdit.widgetCount = mainUI.savedLocally.FlexEdit.widgetCount + 1

			local newImageTable 		= {'panel', color,  (width), (height), '10h', '50h'}
			newImageTable.temp 			= true
			newImageTable.widgetName 	= mainUI.savedLocally.FlexEdit.widgetCount
			
			table.insert(mainUI.savedLocally.FlexEdit.widgets, newImageTable)
			
			FlexEdit.PopulateWidgetList() -- doesn't rely on them existing

			FlexEdit.InstantiateAndRegisterWidgets(flex_instantiate_layer, function()
				FlexEdit.Load(true, true)	-- Get the position and size info
				FlexEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
			end) -- Create the widget and pointer at [7]

			FlexEdit.stateTrigger.unsavedChanges = true
			FlexEdit.stateTrigger:Trigger(false)		
			
			SaveState()				
			
			Flex_Panel_Content:FadeOut(125)		
		end
		
		GenericColorPicker(widget, Translate('options_choose_new_color'), Translate('general_ok'), Translate('general_cancel'), function(red, green, blue) SpawnPanel(red, green, blue)  end)		
		
		-- Flex_Panel_Content_input_btn:SetEnabled(1)

		-- Flex_Panel_Content:FadeIn(250)
		
		-- Flex_Panel_Content_input_btn:SetCallback('onclick', function(widget)
		-- end)	
		
	end	
	
	function FlexEdit.AddImage()
		
		local Flex_Image_Content 				= object:GetWidget('Flex_Image_Content')
		local Flex_Image_Content_Listbox 		= object:GetWidget('Flex_Image_Content_Listbox')
		local Flex_Image_Content_input_btn 	= object:GetWidget('Flex_Image_Content_input_btn')
		
		Flex_Image_Content_input_btn:SetEnabled(0)
		
		local imageTable = Twitch.GetOverlayImages()
		
		Flex_Image_Content_Listbox:Clear()
		if (imageTable) and (#imageTable > 0) then
			for index, value in pairs(imageTable) do
				local widthScale = value.width / value.height
				Flex_Image_Content_Listbox:AddTemplateListItem('flex_image_dropdown_item_template', index , 'label', string.gsub(value.name, '~/flex/', ''), 'texture', value.name, 'width', (92 * widthScale))
			end
		end

		Flex_Image_Content_Listbox:SetCallback('onselect', function(widget)
			Flex_Image_Content_input_btn:SetEnabled(string.len(Flex_Image_Content_Listbox:GetValue())>0)
		end)
		
		Flex_Image_Content:FadeIn(250)
		
		Flex_Image_Content_input_btn:SetCallback('onclick', function(widget)
			local index = Flex_Image_Content_Listbox:GetValue()
			local image_path 		= imageTable[tonumber(index)].name
			local width 			= imageTable[tonumber(index)].width
			local height 			= imageTable[tonumber(index)].height
			
			mainUI.savedLocally.FlexEdit.widgetCount = mainUI.savedLocally.FlexEdit.widgetCount + 1
			
			local newImageTable 		= {'image', image_path,  (width), (height), '10h', '50h'}
			newImageTable.temp 			= true
			newImageTable.widgetName 	= mainUI.savedLocally.FlexEdit.widgetCount
			
			table.insert(mainUI.savedLocally.FlexEdit.widgets, newImageTable)
			
			FlexEdit.PopulateWidgetList() -- doesn't rely on them existing

			FlexEdit.InstantiateAndRegisterWidgets(flex_instantiate_layer, function()
				FlexEdit.Load(true, true)	-- Get the position and size info
				FlexEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
			end) -- Create the widget and pointer at [7]

			FlexEdit.stateTrigger.unsavedChanges = true
			FlexEdit.stateTrigger:Trigger(false)		
			
			SaveState()				
			
			Flex_Image_Content:FadeOut(125)
			
		end)	
	end

	function FlexEdit.AddText()
		
		local Flex_Label_Content 				= object:GetWidget('Flex_Label_Content')
		local Flex_Label_Content_input 		= object:GetWidget('Flex_Label_Content_input')
		local Flex_Label_Content_input_btn 	= object:GetWidget('Flex_Label_Content_input_btn')
		
		Flex_Label_Content:FadeIn(250)

		Flex_Label_Content_input_btn:SetCallback('onclick', function(widget)
			local text = Flex_Label_Content_input:GetInputText()
			
			mainUI.savedLocally.FlexEdit.widgetCount = mainUI.savedLocally.FlexEdit.widgetCount + 1
			
			local newTextTable 		= {'label', tostring(text), 		'40h', '10h', '20h', '80h'}
			newTextTable.temp 		= true
			newTextTable.widgetName 	= mainUI.savedLocally.FlexEdit.widgetCount
			
			table.insert(mainUI.savedLocally.FlexEdit.widgets, newTextTable)
			
			FlexEdit.PopulateWidgetList() -- doesn't rely on them existing

			FlexEdit.InstantiateAndRegisterWidgets(flex_instantiate_layer, function()
				FlexEdit.Load(true, true)	-- Get the position and size info
				FlexEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
			end) -- Create the widget and pointer at [7]

			FlexEdit.stateTrigger.unsavedChanges = true
			FlexEdit.stateTrigger:Trigger(false)		
			
			SaveState()				
			
			Flex_Label_Content:FadeOut(125)
			
		end)
		
	end	
	
	function FlexEdit.OpenDataFinder(index, callback)

		local Flex_Data_Finder 							= object:GetWidget('Flex_Data_Finder')
		local Flex_Data_Finder_CloseX 					= object:GetWidget('Flex_Data_Finder_CloseX')
		local Flex_Data_Finder_Input_Trigger 			= object:GetWidget('Flex_Data_Finder_Input_Trigger')
		local Flex_Data_Finder_Input_Trigger_Cover 		= object:GetWidget('Flex_Data_Finder_Input_Trigger_Cover')
		local Flex_Data_Finder_Input_Field 				= object:GetWidget('Flex_Data_Finder_Input_Field')
		local Flex_Data_Finder_Input_Field_Cover 		= object:GetWidget('Flex_Data_Finder_Input_Field_Cover')
		local Flex_Data_Finder_Output 					= object:GetWidget('Flex_Data_Finder_Output')
		local Flex_Data_Finder_Confirm_Btn 				= object:GetWidget('Flex_Data_Finder_Confirm_Btn')
		local widgetTable 								= mainUI.savedLocally.FlexEdit.widgets[index]
		local lastSearchField, lastSearchTrigger
		local luatriggersTable 							= LuaTrigger.GetTriggers()
		local GetTrigger								= LuaTrigger.GetTrigger
		local MAX_RESULTS								= 10
		local results									= 0
		local searchTermTrigger							= ''
		local searchTermField							= ''
		local sfind										= string.find
		local lower										= string.lower

		local function SearchData(incSearchTermTrigger, incSearchTermField)
			Flex_Data_Finder_Output:Clear()
			local resultString = ''
			searchTermTrigger = incSearchTermTrigger or searchTermTrigger or ''
			searchTermField = incSearchTermField or searchTermField or ''
			for _,triggerName in pairs(luatriggersTable) do
				if (searchTermTrigger == '') or sfind(lower(triggerName), lower(searchTermTrigger)) then
					local trigger = GetTrigger(triggerName)
					if (trigger) then -- and (searchTermField ~= '')
						for i,v in trigger:Pairs() do
							if (searchTermField == '') or sfind(lower(i), lower(searchTermField)) then
								results = results + 1
								local resultString = '^999 ' .. tostring(triggerName) .. '^w.^o' .. tostring(i) .. '^w = ' .. tostring(v)
								Flex_Data_Finder_Output:AddTemplateListItem('simpleDropdownItem', tostring(triggerName)..'###'..tostring(i), 'label', resultString)
								if (results >= MAX_RESULTS) then
									break
								end
							end
						end
					else
						results = results + 1
						local resultString = '^y ' .. tostring(triggerName)
						Flex_Data_Finder_Output:AddTemplateListItem('simpleDropdownItem', results, 'label', resultString)			
					end
				end
			end
		end
		
		Flex_Data_Finder_Input_Field:SetInputLine('')
		Flex_Data_Finder_Input_Field:SetCallback('onhide', function(widget)
			Flex_Data_Finder_Input_Field:ClearCallback('onframe')
		end)
		Flex_Data_Finder_Input_Field:SetCallback('onshow', function(widget)
			Flex_Data_Finder_Input_Field:ClearCallback('onframe')
			Flex_Data_Finder_Input_Field:SetCallback('onframe', function(widget)
				local text = Flex_Data_Finder_Input_Field:GetInputText()
				if (text) and ((not lastSearchField) or (lastSearchField ~= text)) then
					SearchData(nil, text)
					Flex_Data_Finder_Input_Field_Cover:SetVisible(Empty(text))					
				end	
				lastSearchField = text
			end)
		end)
		
		Flex_Data_Finder_Input_Trigger:SetInputLine('')
		Flex_Data_Finder_Input_Trigger:SetCallback('onhide', function(widget)
			Flex_Data_Finder_Input_Trigger:ClearCallback('onframe')
		end)
		Flex_Data_Finder_Input_Trigger:SetCallback('onshow', function(widget)
			Flex_Data_Finder_Input_Trigger:ClearCallback('onframe')
			Flex_Data_Finder_Input_Trigger:SetCallback('onframe', function(widget)
				local text = Flex_Data_Finder_Input_Trigger:GetInputText()
				if (text) and ((not lastSearchTrigger) or (lastSearchTrigger ~= text)) then
					SearchData(text, nil)
					Flex_Data_Finder_Input_Trigger_Cover:SetVisible(Empty(text))
				end	
				lastSearchTrigger = text
			end)
		end)	
		
		Flex_Data_Finder_Confirm_Btn:SetCallback('onclick', function(widget)
			Flex_Data_Finder:FadeOut(125)
			if callback then
				callback(Flex_Data_Finder_Output:GetValue())
			end
		end)		
	
		Flex_Data_Finder:FadeIn(250)
	
	end	

	function FlexEdit.OpenScriptEditor(index)

		local Flex_Script_Editor 				= object:GetWidget('Flex_Script_Editor')
		local Flex_Script_Editor_Input 			= object:GetWidget('Flex_Script_Editor_Input')
		local Flex_Script_Editor_confirm_btn 	= object:GetWidget('Flex_Script_Editor_confirm_btn')
		local Flex_Script_Editor_data_btn 		= object:GetWidget('Flex_Script_Editor_data_btn')
		local widgetTable 						= mainUI.savedLocally.FlexEdit.widgets[index]
	
		if (widgetTable) then
			
			if (widgetTable.scriptFunction) and (not Empty(widgetTable.scriptFunction)) then
				Flex_Script_Editor_Input:SetInputLine(widgetTable.scriptFunction)
			else
				Flex_Script_Editor_Input:SetInputLine('')
			end
			Flex_Script_Editor:FadeIn(250)

			Flex_Script_Editor_confirm_btn:SetCallback('onclick', function(widget)
				local text = Flex_Script_Editor_Input:GetInputText()
				
				widgetTable.scriptFunction = tostring(text)
				
				SaveState()				
				
				Flex_Script_Editor:FadeOut(125)
				
			end)

			Flex_Script_Editor_data_btn:SetCallback('onclick', function(widget)
				local text = Flex_Script_Editor_Input:GetInputText()
											
				local function callback(selectedData)
					if (selectedData) and (not Empty(selectedData)) then
						local splitDataTable = split(selectedData, '###')
						local name = splitDataTable[1]
						local key = splitDataTable[2]
						local fullName = string.gsub(selectedData, '###', '_')					
						if (name) and (key) then
							local newText = "local data_ " .. fullName .. " = LuaTrigger.GetTrigger("..name..")["..key.."] \n" .. text
							Flex_Script_Editor_Input:SetInputLine(newText)
						end
					end
				end
				
				FlexEdit.OpenDataFinder(index, callback)			
			
			end)		
		
		end

	end
	
	function FlexEdit.UpdateEditorWidgets()

		local widgetTable = mainUI.savedLocally.FlexEdit.widgets
		for index, targetGroupTable in pairs(widgetTable) do

			local flex_helper_group		

			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName)
			end					
			
			if (targetWidget) then			

				local Flex_index 						=  targetGroupTable.widgetName	
				local editorListButtonValue				=  targetGroupTable.widgetName					
				local parent							=  object:GetWidget('flex_widget_listitem_' .. Flex_index)
				local editorListButtonUndo				=  object:GetWidget('flex_widget_listitem_' .. Flex_index .. '_undo')
				local editorListButtonDelete			=  object:GetWidget('flex_widget_listitem_' .. Flex_index .. '_closex')				
				
				if (targetGroupTable[3]) or (targetGroupTable[4]) then
					flex_helper_group 			= object:GetWidget('flex_helper_'..Flex_index) or object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template', 'index', Flex_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
				else	
					flex_helper_group 			= object:GetWidget('flex_helper_'..Flex_index) or object:GetWidget('flex_helper_layer'):InstantiateAndReturn('flex_helper_template_nosize', 'index', Flex_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
				end		
				local flex_helper 				= flex_helper_group[1] or flex_helper_group

				local cancelButton 					= object:GetWidget('flex_helper_' .. Flex_index .. '_btn_cancel')
				local keepButton 					= object:GetWidget('flex_helper_' .. Flex_index .. '_btn_keep')
				
				flex_helper:SetVisible(1)
				targetWidget:SetVisible(1)
				
				targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
				targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
				targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(targetGroupTable.overrideX or targetGroupTable.originalX))
				targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(targetGroupTable.overrideY or targetGroupTable.originalY)	)
			
				flex_helper:SetHeight(targetWidget:GetHeight())
				flex_helper:SetWidth(targetWidget:GetWidth())

				flex_helper:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(targetWidget:GetAbsoluteX()))
				flex_helper:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(targetWidget:GetAbsoluteY()))
				
				flex_helper:SetCallback('onstartdrag', function(widget)
					flex_helper:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(flex_helper:GetAbsoluteX()))
					flex_helper:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(flex_helper:GetAbsoluteY()))
					flex_helper:SetCallback('onframe', function(widget)
						targetWidget:SetHeight(flex_helper:GetHeight())
						targetWidget:SetWidth(flex_helper:GetWidth())

						targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(flex_helper:GetAbsoluteX()))
						targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(flex_helper:GetAbsoluteY()))
					end)
					FlexEdit.stateTrigger.unsavedChanges = true
					FlexEdit.stateTrigger:Trigger(false)
				end)
				
				flex_helper:SetCallback('onenddrag', function(widget)
					flex_helper:ClearCallback('onframe')
					flex_helper:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(flex_helper:GetAbsoluteX()))
					flex_helper:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(flex_helper:GetAbsoluteY()))			
					
					targetWidget:SetHeight(flex_helper:GetHeight())
					targetWidget:SetWidth(flex_helper:GetWidth())

					targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(flex_helper:GetAbsoluteX()))
					targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(flex_helper:GetAbsoluteY()))
					
					if (targetGroupTable.temp) then
						mainUI.savedLocally.FlexEdit.widgets[index] = mainUI.savedLocally.FlexEdit.widgets[index] or {}
						mainUI.savedLocally.FlexEdit.widgets[index].overrideHeight 		= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
						mainUI.savedLocally.FlexEdit.widgets[index].overrideWidth 		= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
						mainUI.savedLocally.FlexEdit.widgets[index].overrideX 			= FlexEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
						mainUI.savedLocally.FlexEdit.widgets[index].overrideY 			= FlexEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
						mainUI.savedLocally.FlexEdit.widgets[index].overrideAlign 		= targetWidget:GetAlign()		
						mainUI.savedLocally.FlexEdit.widgets[index].overrideVAlign 		= targetWidget:GetVAlign()	
					end
					
					local labelWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName..'_label')
					
					if (labelWidget and labelWidget:IsValid()) then
						FlexEdit.ResizeFont(labelWidget)
					end
					
					local imageWidget = object:GetWidget('flexinstantiate_template_'..targetGroupTable.widgetName..'_image')
					
					if (imageWidget and imageWidget:IsValid()) then
						targetWidget:SetHeight(flex_helper:GetHeight())
						targetWidget:SetWidth(flex_helper:GetWidth())		
						targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(flex_helper:GetAbsoluteX()))
						targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(flex_helper:GetAbsoluteY())	)					
					end
				
				end)

				parent:SetCallback('ondoubleclick', function(widget)
					FlexEdit.OpenScriptEditor(index)
				end)				
				
				editorListButtonUndo:SetCallback('onclick', function(widget)
					flex_helper:ClearCallback('onframe')
					flex_helper:SetHeight(targetGroupTable.originalHeight)
					flex_helper:SetWidth(targetGroupTable.originalWidth)
					flex_helper:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(targetGroupTable.originalX))
					flex_helper:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(targetGroupTable.originalY))
				
					targetWidget:SetHeight(flex_helper:GetHeight())
					targetWidget:SetWidth(flex_helper:GetWidth())

					targetWidget:SetAbsoluteX(FlexEdit.ConvertWidthPercentToPixels(flex_helper:GetAbsoluteX()))
					targetWidget:SetAbsoluteY(FlexEdit.ConvertHeightPercentToPixels(flex_helper:GetAbsoluteY()))
				
				end)
				
				editorListButtonDelete:SetCallback('onclick', function(widget)
					flex_helper:ClearCallback('onframe')
					flex_helper:SetVisible(0)	
					targetWidget:SetVisible(0)
					targetWidget:Destroy()
					widgetTable[index] = nil
					for index2, targetGroupTable2 in pairs(mainUI.savedLocally.FlexEdit.widgets) do
						if (targetGroupTable2.widgetName == targetGroupTable.widgetName) then
							mainUI.savedLocally.FlexEdit.widgets[index2] = nil
						end
					end				
					-- FlexEdit.PopulateWidgetList()	-- This causes a crash for some reason, do this other derpy thing instead
					local Flex_Overlays_List_Listbox 				= object:GetWidget('Flex_Overlays_List_Listbox')		
					Flex_Overlays_List_Listbox:HideItemByValue(editorListButtonValue)
				end)				
				
				targetGroupTable.helpersExist = true
			end
		end		
	end
	
	function FlexEdit.EnableEditor()

		FlexEdit.stateTrigger.panelOpen = false
		FlexEdit.stateTrigger:Trigger(false)	
		flexPanelWasOpen = true	
	
		object:GetWidget('flex_helper_layer'):SetVisible(1)
		object:GetWidget('flex_command_layer'):SetVisible(1)
		object:GetWidget('flex_instantiate_layer'):SetVisible(1)
		GetWidget('flex_instantiate_overlay_layer', 'game'):SetVisible(0)

		local Flex_Overlay_Remove 					= object:GetWidget('Flex_Overlay_Remove')
		local Flex_Overlay_Revert 					= object:GetWidget('Flex_Overlay_Revert')
		local Flex_Overlay_Save 						= object:GetWidget('Flex_Overlay_Save')	
		local Flex_Overlays_Header 					= object:GetWidget('Flex_Overlays_Header')	
		local Flex_Overlays_Header_closex 			= object:GetWidget('Flex_Overlays_Header_closex')	
		local Flex_Overlays_List_Listbox 				= object:GetWidget('Flex_Overlays_List_Listbox')	
		local Flex_Overlay_Webcam 					= object:GetWidget('Flex_Overlay_Webcam')	
		local Flex_Overlay_Image 						= object:GetWidget('Flex_Overlay_Image')	
		local Flex_Overlay_Panel 						= object:GetWidget('Flex_Overlay_Panel')	
		local Flex_Overlay_Text 						= object:GetWidget('Flex_Overlay_Text')	
		local Flex_Overlay_Cancel 					= object:GetWidget('Flex_Overlay_Cancel')	
		
		Flex_Overlay_Remove:SetCallback('onclick', function(widget)
			if GenericDialog then
				GenericDialog(
					'flex_remove_all', '', 'flex_remove_all_confirm', 'general_ok', 'general_cancel', 
						function()  FlexEdit.Reset() end,
						function()  end
				)			
			else
				FlexEdit.Reset()
			end
		end)		
		
		Flex_Overlay_Webcam:SetCallback('onclick', function(widget)
			 FlexEdit.AddWebcam()
		end)
		
		Flex_Overlay_Image:SetCallback('onclick', function(widget)
			 FlexEdit.AddImage()
		end)	
		
		Flex_Overlay_Panel:SetCallback('onclick', function(widget)
			 FlexEdit.AddPanel()
		end)	

		Flex_Overlay_Text:SetCallback('onclick', function(widget)
			 FlexEdit.AddText()
		end)		
		
		Flex_Overlay_Save:SetCallback('onclick', function(widget)
			FlexEdit.Save()
			FlexEdit.DisableEditor()	
		end)
		
		Flex_Overlay_Revert:SetCallback('onclick', function(widget)
			if (FlexEdit.stateTrigger.unsavedChanges) then
				if GenericDialog then
					GenericDialog(
						'flex_undo_changes', '', 'flex_undo_changes_confirm', 'general_ok', 'general_cancel', 
							function()  
								FlexEdit.Revert()				
							end,
							function()  end
					)
				else
					FlexEdit.Revert()
				end
			else
				FlexEdit.Revert()
			end				
		end)	
		
		Flex_Overlay_Cancel:SetCallback('onclick', function(widget)
			if (FlexEdit.stateTrigger.unsavedChanges) then
				if GenericDialog then
					GenericDialog(
						'flex_undo_changes2', '', 'flex_undo_changes_confirm2', 'general_ok', 'general_cancel', 
							function()  
								FlexEdit.Revert()	
								FlexEdit.DisableEditor()					
							end,
							function()  end
					)
				else
					FlexEdit.Revert()	
					FlexEdit.DisableEditor()					
				end
			else
				FlexEdit.Revert()	
				FlexEdit.DisableEditor()
			end
		end)		
		
		Flex_Overlays_Header_closex:SetCallback('onclick', function(widget)
			if (FlexEdit.stateTrigger.unsavedChanges) then
				if GenericDialog then
					GenericDialog(
						'flex_undo_changes2', '', 'flex_undo_changes_confirm2', 'general_ok', 'general_cancel', 
							function()  
								FlexEdit.Revert()	
								FlexEdit.DisableEditor()					
							end,
							function()  end
					)
				else
					FlexEdit.Revert()	
					FlexEdit.DisableEditor()							
				end
			else
				FlexEdit.Revert()	
				FlexEdit.DisableEditor()
			end
		end)		
		
		FlexEdit.PopulateWidgetList()
		
		FlexEdit.UpdateEditorWidgets()
		
	end
		
	function FlexEdit.ToggleEditor()
		if object:GetWidget('flex_command_layer') then
			if object:GetWidget('flex_command_layer'):IsVisible() then
				FlexEdit.DisableEditor()
			else
				FlexEdit.EnableEditor()
			end
		end
	end

	local isLoaded = false
	function FlexEdit.Init(force)
		local loginStatusTrigger = LuaTrigger.GetTrigger('LoginStatus')
		local mainPanelStatusTrigger = LuaTrigger.GetTrigger('mainPanelStatus')
		local GamePhase = LuaTrigger.GetTrigger('GamePhase')
		
		if (loginStatusTrigger.isLoggedIn) and (loginStatusTrigger.hasIdent) and (loginStatusTrigger.isIdentPopulated) and ((mainPanelStatusTrigger.main == 101) or (GamePhase.gamePhase > 0)) then
			if (force) or (not isLoaded) then
				
				mainUI.savedLocally.FlexEdit = mainUI.savedLocally.FlexEdit or {}
				mainUI.savedLocally.FlexEdit.savedSettings = mainUI.savedLocally.FlexEdit.savedSettings or {}				
				mainUI.savedLocally.FlexEdit.widgetCount = mainUI.savedLocally.FlexEdit.widgetCount or 1
				mainUI.savedLocally.FlexEdit.widgets = mainUI.savedLocally.FlexEdit.widgets or {}				
				
				isLoaded = true
				FlexEdit.InstantiateAndRegisterWidgets(flex_instantiate_layer, nil)			
				FlexEdit.Load(true, false)

				FlexEdit.stateTrigger.panelOpen = false
				FlexEdit.stateTrigger.overlayVisible = false
				FlexEdit.stateTrigger.unsavedChanges = false
				FlexEdit.stateTrigger.panelState = 'main'
				FlexEdit.stateTrigger:Trigger(false)		

			end
		end
	end

	local flex_edit_toggle_editor_btn 						= object:GetWidget('flex_edit_toggle_editor_btn')	
	
	flex_edit_toggle_editor_btn:SetCallback('onclick', function(widget)
		FlexEdit.ToggleEditor()
	end)		
	
	object:GetWidget('flex_command_layer'):RegisterWatchLua('GamePhase', function() FlexEdit.Init(false) end)
	object:GetWidget('flex_command_layer'):RegisterWatchLua('GameReinitialize', function() FlexEdit.Init(false) end)
	object:GetWidget('flex_command_layer'):RegisterWatchLua('LoginStatus', function() FlexEdit.Init(false) end, false, nil, 'isIdentPopulated', 'hasIdent', 'isLoggedIn')
	object:GetWidget('flex_command_layer'):RegisterWatchLua('mainPanelStatus', function() FlexEdit.Init(false) end, false, nil, 'main')

end

Register(object)


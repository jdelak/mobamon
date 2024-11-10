mainUI = mainUI or {}
mainUI.news = mainUI.news or {}
mainUI.news.componentManager = mainUI.news.componentManager or {}
mainUI.news.data = mainUI.news.data or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
local interface = object


local listWidgets = {}

local listParent = object:GetWidget('main_news_component_list')
local addButton = object:GetWidget('main_news_component_add')
local addBackground = object:GetWidget('main_news_component_manager_new_component_dialog_background')
local addCombobox = object:GetWidget('main_news_component_manager_new_component_comboBox')
local creationDialog = object:GetWidget('main_news_component_manager_new_component_dialog')
local addComponentButton = object:GetWidget('main_news_component_addComponent')
local addComponentConfigParent = object:GetWidget('main_news_component_manager_instantiation_parent')
local overlayToggleButton = object:GetWidget('main_news_component_overlayToggle')
local overlayToggleCheck = object:GetWidget('main_news_component_overlayToggle_check')

function mainUI.news.componentManager.AddToList(componentInfo)
	listParent:AddTemplateListItem('main_news_component_manager_entry', componentInfo.ID, 'componentName', componentInfo.externalName, "ID", componentInfo.ID);
end
function mainUI.news.componentManager.ClearList()
	listParent:ClearItems()
end

function mainUI.news.componentManager.RemoveFromList(ID)
	listParent:EraseListItemByValue(ID)
	mainUI.news.removeComponent(ID)
end

listParent:SetCallback('onselect', function(widget)
	selectedComponent = widget:GetValue()
	mainUI.news.resizeComponent(selectedComponent)
end)

addBackground:SetCallback('onclick', function(widget)
	addBackground:FadeOut(75)
end)

local function scaleCreationDialog(key)
	addComponentConfigParent:ClearChildren()
	if not (mainUI.news.allComponents[key]) then
		SevereError('Component '.. key .. " doesn't exist..", 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end
	local addedWidget = mainUI.news.allComponents[key].createConfigWidget and mainUI.news.allComponents[key].createConfigWidget(addComponentConfigParent) or nil
	local height = creationDialog:GetHeightFromString("125s")
	if addedWidget then
		height = height + addedWidget:GetHeight()
	end
	creationDialog:ScaleHeight(height, 125)
end

addButton:SetCallback('onclick', function(widget)
	local selected
	addCombobox:ClearItems()
	for k, v in pairs(mainUI.news.allComponents) do
		if not (v.singleton and mainUI.news.componentExists(v.internalName)) then
			addCombobox:AddTemplateListItem('simpleDropdownItem', k, 'label', Translate(v.externalName))
			if not selected then
				addCombobox:SetSelectedItemByValue(k)
				selected = k
			end
		end
	end
	
	scaleCreationDialog(selected)
	
	addBackground:FadeIn(75)
end)

addCombobox:SetCallback('onselect', function(widget)
	if (widget:GetValue() == "") then return end
	scaleCreationDialog(widget:GetValue())
end)

addComponentButton:SetCallback('onclick', function(widget)
	local selected = addCombobox:GetValue()
	local extraData
	if (mainUI.news.allComponents[selected].interpretConfigWidget) then
		extraData = mainUI.news.allComponents[selected].interpretConfigWidget()
	end
	mainUI.news.loadComponent(addCombobox:GetValue(), nil, nil, nil, nil, extraData)
	addBackground:FadeOut(75)
end)

function updateOverlayCheckbox(toggle)
	local hidden = GetCvarBool('ui_hideNewHeroOverlay')
	if (toggle) then hidden = not hidden end
	SetSave('ui_hideNewHeroOverlay', tostring(hidden), 'bool')
	overlayToggleCheck:SetVisible(not hidden)
	local artworkWidget = GetWidget('main_artwork_container')
	if (artworkWidget) then
		artworkWidget:SetVisible(not hidden)
	end
end
updateOverlayCheckbox()
overlayToggleButton:SetCallback('onclick', function(widget)
	updateOverlayCheckbox(true)
end)

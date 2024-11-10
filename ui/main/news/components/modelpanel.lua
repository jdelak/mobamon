-- A component entry should have:
-- internalName			The name to be used to save/id the component
-- externalName			The name to show on dialogues etc
-- singleton			Whether multiple of this component are disallowed
-- resizableContainer	The widget that represents the size of the component
-- onLoad				A function to be called when the component loads
-- onRemove				A function to be called when the component is removed
-- init					A function to be called to create the component, takes (parent, x, y, w, h)

local interface = object

local function setUpModelPanel(index)
end

local function onLoad(index)
	setUpModelPanel(index)
end

local function init(parent, x, y, w, h, index, extraData)
	--printParams()
	return parent:InstantiateAndReturn('main_hero_model_container_template'
		,'x', x
		,'y', y
		,'w', w
		,'h', h
		,'index', index
		,'model', GetPreviewModel(extraData.entity)
		,'pos', GetPreviewPos(extraData.entity)
		,'angles', GetPreviewAngles(extraData.entity)
		,'scale', GetPreviewScale(extraData.entity)
	)[1]
end
local function onRemove()
	getResizableContainer():Destroy()
end

local function getResizableContainer(index)
	return interface:GetWidget("main_model_container"..index)
end

local heroTable={
	'Hero_Ace',
	'Hero_Bandito',
	'Hero_Bastion',
	'Hero_Bo',
	'Hero_Blazer',
	'Hero_Caprice',
	'Hero_Claudessa',
	'Hero_Carter',
	'Hero_Chester',
	'Hero_Fetterstone',
	'Hero_Gokong',
	'Hero_Hale',
	'Hero_Harrower',
	'Hero_Iah',
	'Hero_Jinshe',
	'Hero_LadyTinder',
	'Hero_Malady',
	'Hero_Midknight',
	'Hero_Minerva',
	'Hero_Flak',
	'Hero_Moxie',
	'Hero_Nikolai',
	'Hero_Ray',
	'Hero_Rook',
	'Hero_Shank',
	'Hero_Trace',
	'Hero_Trixie',
	'Hero_Vermillion',
	'Hero_Vex',
	'Hero_Zaku'
}

local function createConfigWidget(parent)
	local createdPanel = parent:InstantiateAndReturn('main_hero_model_container_config_template')[1]
	local comboBox = interface:GetWidget('main_hero_model_container_config_combobox')
	
	for _, v in ipairs(heroTable) do
		comboBox:AddTemplateListItem('simpleDropdownItem', v, 'label',string.sub(Translate('account_icon_master_'..string.lower(v) ), 8))
	end
	comboBox:SetSelectedItemByValue(heroTable[1])
	return createdPanel
end

local function interpretConfigWidget()
	return {entity=interface:GetWidget('main_hero_model_container_config_combobox'):GetValue()}
end

local modelPanelComponent = {
	internalName = "main_news_model_panel",
	externalName = "news_component_model_panel",
	singleton = false,
	defaultPosition = {"760s", "25s", "785s", "729s"},
	onLoad = onLoad,
	onRemove = onRemove,
	init = init,
	getResizableContainer = getResizableContainer,
	createConfigWidget = createConfigWidget,
	interpretConfigWidget = interpretConfigWidget,
}


mainUI.news.registerComponent(modelPanelComponent)
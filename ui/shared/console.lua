
local interface 				= object
local console_widget 			= interface:GetWidget('console_widget')
local console_menu 				= interface:GetWidget('console_menu')
local console_menu_toggle_on 	= interface:GetWidget('console_menu_toggle_on')
local console_menu_toggle_off 	= interface:GetWidget('console_menu_toggle_off')

console_menu_toggle_on:SetCallback('onclick', function(widget)
	console_widget:SetWidth('-20.6%')
	console_menu_toggle_on:SetVisible(0)
	console_menu_toggle_off:SetVisible(1)
	console_menu:SetVisible(1)
end)

console_menu_toggle_off:SetCallback('onclick', function(widget)
	console_widget:SetWidth('100%')
	console_menu_toggle_on:SetVisible(1)
	console_menu_toggle_off:SetVisible(0)
	console_menu:SetVisible(0)
end)
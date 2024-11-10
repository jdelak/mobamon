local interface = object

--[[
========================
Options Button
========================
]]--
interface:GetWidget('speMenuButton'):SetCallback('onclick', function()
	interface:GetWidget('spe_menu_parent'):SetVisible(not interface:GetWidget('spe_menu_parent'):IsVisible() )
end)

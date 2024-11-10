-- (C)2014 S2 Games
-- window.lua
--
-- Window management example script
--=============================================================================
local interface = object

local button0 = interface:GetWidget("button0")
if button0 ~= nil then
	button0:SetCallback("onclick",
		function(widget)
			interface:GetWindow():ToggleFullscreen()
		end)
	button0:SetCallback("onrightclick",
		function(widget)
			interface:GetWindow():Close()
		end)
end

local titleBar = interface:GetWidget("titleBar")
if titleBar ~= nil then
	titleBar:SetCallback("onclick",
		function(widget, x, y)
			interface:GetWindow():SetWindowTitle("StartDrag")
			interface:GetWindow():StartDrag(x, y)
		end)
	titleBar:SetCallback("ondoubleclick",
		function(widget, x, y)
			interface:GetWindow():Center(x, y)
		end)
end

local sizer = interface:GetWidget("sizer")
if sizer ~= nil then
	sizer:SetCallback("onclick",
		function(widget, x, y)
			interface:GetWindow():StartSizing("bottomright", x, y)
		end)
end

local drop = interface:GetWidget("drop")
if drop ~= nil then
	drop:SetCallback("ondragenter",
		function(widget, data, x, y)
			print("DragEnter: " .. data .. " " .. x .. " " .. y .. "\n")
		end)
	drop:SetCallback("ondragover",
		function(widget, data, x, y)
			print("DragOver: " .. data .. " " .. x .. " " .. y .. "\n")
		end)
	drop:SetCallback("ondragleave",
		function(widget, data)
			print("DragLeave: " .. data .. "\n")
		end)
	drop:SetCallback("ondrop",
		function(widget, data, x, y)
			print("Drop: " .. data .. " " .. x .. " " .. y .. "\n")
		end)
end

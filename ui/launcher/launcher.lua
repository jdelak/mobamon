
local interface, interfaceName = object, object:GetName()

function GetWidget(widget, fromInterface, hideErrors)
	-- println('GetWidget Global: ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface))
	if (widget) then
		local returnWidget		
		if (fromInterface) then
			if UIManager.GetInterface(fromInterface) then
				returnWidget = UIManager.GetInterface(fromInterface):GetWidget(widget)
			else
				println('^o GetWidget could not find interface ' .. tostring(fromInterface))
			end		
		else
			if (interface) and (interface:IsValid()) then
				returnWidget = interface:GetWidget(widget)
			else
				println('^o GetWidget base interface is missing or invalid! ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface))
			end
		end	
		if (returnWidget) then
			return returnWidget
		else
			if (not hideErrors) then println('GetWidget Global failed to find ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface)) end
			return nil		
		end	
	else
		println('GetWidget called without a target')
		return nil
	end
end


local function Init()

end

Init(object)





















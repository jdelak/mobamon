-- Init ui cvars

cvarInit = function(cvarName, cvarType, cvarValue, setSave, forceValue)
	forceValue = forceValue or false
	if setSave == nil then setSave = true end

	if cvarType and cvarValue then
		local thisCvar = Cvar.GetCvar(cvarName)
		if not thisCvar then
			thisCvar = Cvar.CreateCvar(cvarName, cvarType, cvarValue)
		elseif forceValue then
			thisCvar:Set(cvarValue)
		end
		if setSave then
			thisCvar:SetSave(true)
		end
		
		return thisCvar
	end
end

-- ======================
cvarInit('_shopView', 'int', '1')
cvarInit('_shopItemView', 'int', '0')
cvarInit('_abilityPanelView', 'int', '0', true, true)
cvarInit('_spec_statsVis', 'bool', 'true')
cvarInit('_spec_pushBarVis', 'bool', 'true')
cvarInit('_spec_unitFramesVis', 'bool', 'false')
cvarInit('_spec_selectedUnitVis', 'bool', 'true')
cvarInit('_spec_replayControlsVis', 'bool', 'true')

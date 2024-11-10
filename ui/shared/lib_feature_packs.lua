
local object = object

libFeaturePacks = {
	
	featurePacksThatExist = {
		'lang_fr',
		-- 'lang_en', -- Hey you! Never enable this, it is always included
	},
	
	getFeaturePackTable = function()
		local featurePackString = Client.GetFeatures()
		local featurePackTable = Explode(',', featurePackString)
		return featurePackTable
	end,

	getFeaturePackStringFromTable = function(featurePackTable)
		local featurePackString = implode2(featurePackTable, ',')
		return featurePackString
	end,	

	requestAddFeaturePack = function(newFeaturesTable)
		local featureString = Client.GetFeatures()
		for i,v in ipairs(newFeaturesTable) do
			featureString = featureString .. ',' .. v
		end
		Client.SetFeatures(featureString)
	end,	
	
	requestAddLanguagePack = function(newLanguage)
		libFeaturePacks.requestAddFeaturePack({'lang_'..newLanguage})
	end,	
	
	doesThisFeaturePackExist = function(featurePackName)
		local featurePacksThatExist = libFeaturePacks.featurePacksThatExist
		for i,v in pairs(featurePacksThatExist) do
			if (v == featurePackName) then
				return true
			end
		end
		return false
	end,		
	
	doIhaveThisLanguagePack = function(newLanguage)
		local featureTable = libFeaturePacks.getFeaturePackTable()
		table.insert(featureTable, 'lang_en') -- hack cus you always have english
		for i,v in pairs(featureTable) do
			if (v == 'lang_'..newLanguage) then
				return true
			end
		end
		if (libFeaturePacks.doesThisFeaturePackExist('lang_'..newLanguage)) then -- I didn't have it, but does it even exist?
			return false
		else
			return true
		end
	end,	
	
	promptToRestartBecauseINeedALanguagePack = function(newLanguage)
		GenericDialog(
			'confirm_langpack_header_new', 'confirm_langpack_restart_new', '', 'general_ok', 'general_cancel', 
			function()
				Set('host_language', tostring(newLanguage))
				object:GetWidget('windowframe_language_combobox'):SetVisible(0)
				libFeaturePacks.requestAddLanguagePack(newLanguage)
				-- Client.Update()
			end,
			function()
				object:UICmd('Call(\'windowframe_language_combobox\', \'SetSelectedItemByValue(host_language, false)\');')
				object:GetWidget('windowframe_language_combobox'):SetVisible(0)
				PlaySound('/ui/sounds/sfx_ui_back.wav')
			end
		)
	end,
	
}


local object = object

libLanguage = {

	promptToRestartBecauseIChangedLanguages = function(newLanguage)
		GenericDialog(
			'confirm_lang_header_new', 'confirm_lang_restart_new', '', 'general_ok', 'general_cancel', 
			function()
				Set('host_language', tostring(newLanguage))
				Client.RestartAndRestoreSession()
				object:GetWidget('windowframe_language_combobox'):SetVisible(0)
			end,
			function()
				object:UICmd('Call(\'windowframe_language_combobox\', \'SetSelectedItemByValue(host_language, false)\');')
				object:GetWidget('windowframe_language_combobox'):SetVisible(0)
				PlaySound('/ui/sounds/sfx_ui_back.wav')
			end
		)
	end,
	
	didIChangeLanguage = function(newLanguage)
		return ( (newLanguage) and (not Empty(newLanguage)) and (newLanguage ~= GetCvarString('host_language')) ) or false
	end,
	
}
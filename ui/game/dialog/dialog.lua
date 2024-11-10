local interface = object

function GenericDialogGame(header, label1, label2, btn1, btn2, onConfirm, onCancel, dontDimBG, showFlair, forceDisplay, dontAskAgain, delayOkButton)
		
	if (not interface:GetWidget('generic_dialog_box_bg')) then 
		println('^r^: GenericDialog Called Before Exists : ' .. tostring(header..' '..label1..' '..label2) )
		return 
	end
		
	if (dontAskAgain) and (mainUI) and (mainUI.savedLocally.skipTheseDialogs) and (mainUI.savedLocally.skipTheseDialogs[header..label1..label2]) and (onConfirm) then
		onConfirm()
		return
	end			
		
	if (dontDimBG) then
		interface:GetWidget('generic_dialog_box_bg'):SetColor('invisible')
	else
		interface:GetWidget('generic_dialog_box_bg'):SetColor('0 0 0 0.4')
	end
	
	interface:GetWidget('generic_dialog_header_1'):SetText(Translate(header) or '?')
	interface:GetWidget('generic_dialog_header_1'):SetFont('maindyn_22')
	if (label1) and (not Empty(label1)) then
		interface:GetWidget('generic_dialog_label_1'):SetText(Translate(label1) or '?')
		interface:GetWidget('generic_dialog_label_1'):SetVisible(1)
		interface:GetWidget('generic_dialog_label_1'):SetFont('maindyn_22')
	else
		interface:GetWidget('generic_dialog_label_1'):SetText('')
		interface:GetWidget('generic_dialog_label_1'):SetVisible(0)
	end
	if (label2) and (not Empty(label2)) then
		interface:GetWidget('generic_dialog_label_2'):SetText(Translate(label2) or '?')
		interface:GetWidget('generic_dialog_label_2'):SetVisible(1)
		interface:GetWidget('generic_dialog_label_2'):SetFont('maindyn_22')
	else
		interface:GetWidget('generic_dialog_label_2'):SetText('')
		interface:GetWidget('generic_dialog_label_2'):SetVisible(0)
	end	

	if (btn1) and (not Empty(btn1)) then
		groupfcall('generic_dialog_button_1_label_group', function(_, widget) widget:SetText(Translate(btn1) or '?') widget:SetFont('maindyn_30') end)
		interface:GetWidget('generic_dialog_button_1'):SetVisible(1)
		if (delayOkButton) then
			interface:GetWidget('generic_dialog_button_1'):SetEnabled(0)
			libThread.threadFunc(function()	
				wait(1500)		
				interface:GetWidget('generic_dialog_button_1'):SetEnabled(1)
			end)
		end		
	else
		groupfcall('generic_dialog_button_1_label_group', function(_, widget) widget:SetText('') end)
		interface:GetWidget('generic_dialog_button_1'):SetVisible(0)
	end		

	if (btn2) and (not Empty(btn2)) then
		groupfcall('generic_dialog_button_2_label_group', function(_, widget) widget:SetText(Translate(btn2) or '?') widget:SetFont('maindyn_24') end)
		interface:GetWidget('generic_dialog_button_2'):SetVisible(1)
	else
		groupfcall('generic_dialog_button_2_label_group', function(_, widget) widget:SetText('') end)
		interface:GetWidget('generic_dialog_button_2'):SetVisible(0)
	end		

	interface:GetWidget('generic_dialog_button_1'):SetCallback('onclick', function()
		-- dialogGenericConfirm
		-- PlaySound('/soundpath/file.wav')
		interface:GetWidget('generic_dialog_box'):SetVisible(false)
		interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(0)
		if (onConfirm) then
			onConfirm()
		end
	end)
	
	interface:GetWidget('generic_dialog_button_2'):SetCallback('onclick', function()
		-- dialogGenericCancel
		-- PlaySound('/soundpath/file.wav')
		interface:GetWidget('generic_dialog_box'):SetVisible(false)
		interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(0)
		if (onCancel) then
			onCancel()
		end		
	end)	

	interface:GetWidget('generic_dialog_box_closex'):SetCallback('onclick', function()
		-- dialogGenericCloseX
		-- PlaySound('/soundpath/file.wav')
		interface:GetWidget('generic_dialog_box'):SetVisible(false)
		interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(0)
		if (onCancel) then
			onCancel()
		end		
	end)
	
	if (dontAskAgain) then
		interface:GetWidget('generic_dialog_dontaskagain'):SetVisible(1)
		interface:GetWidget('generic_dialog_dontaskagain_checkbox'):SetCallback('onclick', function(widget) 
			mainUI = mainUI or {}
			mainUI.savedLocally.skipTheseDialogs = mainUI.savedLocally.skipTheseDialogs or {}
			if (widget:GetValue() == '1') then
				mainUI.savedLocally.skipTheseDialogs[header..label1..label2] = true
			else
				mainUI.savedLocally.skipTheseDialogs[header..label1..label2] = nil
			end
		end)		
	else
		interface:GetWidget('generic_dialog_dontaskagain'):SetVisible(0)
		interface:GetWidget('generic_dialog_dontaskagain_checkbox'):ClearCallback('onclick')
	end	
	
	interface:GetWidget('generic_dialog_box_wrapper'):SetHeight(0)
	interface:GetWidget('generic_dialog_box_wrapper'):SetWidth(0)
	interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(1)
	interface:GetWidget('generic_dialog_box_bg'):SetVisible(0)
	
	interface:GetWidget('generic_dialog_box_wrapper'):Scale(interface:GetWidget('generic_dialog_box_insert'):GetWidth(), interface:GetWidget('generic_dialog_box_insert'):GetHeight(), 125)
	
	interface:GetWidget('generic_dialog_box'):Sleep(125, function()	
		interface:GetWidget('generic_dialog_box'):FadeIn(125)
	end)	
	
	interface:GetWidget('generic_dialog_box_bg'):FadeIn(1500)
	
	FindChildrenClickCallbacks(interface:GetWidget('generic_dialog_box'))

end

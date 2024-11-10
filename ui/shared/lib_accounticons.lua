local interface = object
libAccountIcons = {}

function libAccountIcons.SetColor(newColor, templateKey, activeInterface)
	activeInterface = activeInterface or interface
	
	if (not templateKey) or (not activeInterface) then
		println('^r libAccountIcons.SetColor invalid parameters')
		println('^r templateKey' .. tostring(templateKey))
		println('^r activeInterface' .. tostring(activeInterface))
		return
	end	
	
	local parent 					= activeInterface:GetWidget(templateKey .. '_parent')
	local icon 						= activeInterface:GetWidget(templateKey .. '_icon')
	local icon_anim 				= activeInterface:GetWidget(templateKey .. '_icon_anim')
	local iconframe 				= activeInterface:GetWidget(templateKey .. '_iconframe')
	local iconframe_animated 		= activeInterface:GetWidget(templateKey .. '_iconframe_animated')
	local iconframe_effect_parent 	= activeInterface:GetWidget(templateKey .. '_iconframe_effect_parent')
	local iconframe_effect 			= activeInterface:GetWidget(templateKey .. '_iconframe_effect')

	if (not parent) then	
		return
	end
	
	icon:SetColor(newColor)
	icon_anim:SetColor(newColor)
	iconframe:SetColor(newColor)
end

function libAccountIcons.ScaleInPlace(newSize, templateKey, activeInterface, reset)
	activeInterface = activeInterface or interface
	
	if (not templateKey) or (not activeInterface) then
		println('^r libAccountIcons.ScaleInPlace invalid parameters')
		println('^r templateKey' .. tostring(templateKey))
		println('^r activeInterface' .. tostring(activeInterface))		
		return
	end	
	
	local parent 					= activeInterface:GetWidget(templateKey .. '_parent')
	local icon 						= activeInterface:GetWidget(templateKey .. '_icon')
	local icon_anim 				= activeInterface:GetWidget(templateKey .. '_icon_anim')
	local iconframe 				= activeInterface:GetWidget(templateKey .. '_iconframe')
	local iconframe_animated 		= activeInterface:GetWidget(templateKey .. '_iconframe_animated')
	local iconframe_effect_parent 	= activeInterface:GetWidget(templateKey .. '_iconframe_effect_parent')
	local iconframe_effect 			= activeInterface:GetWidget(templateKey .. '_iconframe_effect')

	if (not parent) then
		return
	end
	-- ScaleInPlace(widget, width, height, duration, recurse, reset)
	ScaleInPlace(parent, newSize..'@', newSize..'%', 150, nil, reset)
end

function libAccountIcons.UpdateAccountIcon(accountIconPath, accountIconFramePath, templateKey, activeInterface)
	activeInterface = activeInterface or interface
	
	-- println('templateKey ' .. tostring(templateKey))
	-- println('accountIconPath ' .. tostring(accountIconPath))
	-- println('accountIconFramePath ' .. tostring(accountIconFramePath))
	-- println('_____')
	
	if (not templateKey) or (not activeInterface) then
		println('^r libAccountIcons.UpdateAccountIcon invalid parameters')
		println('^r templateKey' .. tostring(templateKey))
		println('^r activeInterface' .. tostring(activeInterface))		
		return
	end	
	
	local parent 					= activeInterface:GetWidget(templateKey .. '_parent')
	local icon 						= activeInterface:GetWidget(templateKey .. '_icon')
	local icon_anim 				= activeInterface:GetWidget(templateKey .. '_icon_anim')
	local iconframe 				= activeInterface:GetWidget(templateKey .. '_iconframe')
	local iconframe_animated 		= activeInterface:GetWidget(templateKey .. '_iconframe_animated')
	local iconframe_effect_parent 	= activeInterface:GetWidget(templateKey .. '_iconframe_effect_parent')
	local iconframe_effect 			= activeInterface:GetWidget(templateKey .. '_iconframe_effect')

	if (not parent) or (not icon) or (not icon_anim) or (not iconframe) or (not iconframe_animated) or (not iconframe_effect_parent) or (not iconframe_effect) then	
		println('^r libAccountIcons.UpdateAccountIcon missing widgets: ' .. tostring(templateKey))
		return
	end
	
	if (accountIconPath) then
		if (accountIconPath == 'default') or (accountIconPath == 'default.tga') then
			accountIconPath = '/ui/shared/textures/account_icons/default.tga'
		elseif (accountIconPath) and string.find(accountIconPath, '.tga') then
			accountIconPath = accountIconPath
		elseif (not Empty(accountIconPath)) then
			accountIconPath = '/ui/shared/textures/account_icons/' .. accountIconPath.. '.tga'
		else
			accountIconPath = '/ui/shared/textures/account_icons/default.tga'
		end	
		icon:SetTexture(accountIconPath)
		icon:SetVisible(1)
		icon_anim:SetTexture(accountIconPath)
	end
	
	if (false) and (accountIconFramePath) then
		if (accountIconFramePath == 'default') or (accountIconFramePath == 'default.tga') then
			accountIconFramePath = '/ui/shared/textures/account_icon_frames/default.tga'
		elseif (accountIconFramePath) and string.find(accountIconFramePath, '.tga') then
			accountIconFramePath = accountIconFramePath
		elseif (not Empty(accountIconFramePath)) then
			accountIconFramePath = '/ui/shared/textures/account_icon_frames/' .. accountIconFramePath.. '.tga'
		else
			accountIconFramePath = '/ui/shared/textures/account_icon_frames/default.tga'
		end
		iconframe:SetVisible(1)
		iconframe:SetTexture(accountIconFramePath)	
		local path, frameName  = string.match(accountIconFramePath, '(.+)/(.+)%.tga')
		if (frameName) and (not Empty(frameName)) then
			local effect 	= Translate('account_iconframe_effect_' .. frameName)
			local animation = Translate('account_iconframe_anim_' .. frameName)
			local size 		= Translate('account_iconframe_size_' .. frameName)
			local offset 	= Translate('account_iconframe_offset_' .. frameName)
			
			if (effect) and (not Empty(effect)) and (effect ~= 'account_iconframe_effect_') and (effect ~= 'account_iconframe_effect_' .. frameName) and (effect ~= 'none') then
				iconframe_effect:SetVisible(1)
				iconframe_effect_parent:SetVisible(1)
				iconframe_effect:SetEffect(effect)
			else
				iconframe_effect:SetVisible(0)
				iconframe_effect_parent:SetVisible(0)
			end
			
			if (animation) and (not Empty(animation)) and (animation ~= 'account_iconframe_anim_') and (animation ~= 'account_iconframe_anim_' .. frameName) and (animation ~= 'none') then
				iconframe_animated:SetVisible(1)
				iconframe_animated:SetTexture(animation)
			else
				iconframe_animated:SetVisible(0)
			end
			
			if (size) and (not Empty(size)) and (size ~= 'account_iconframe_size_') and (size ~= 'account_iconframe_size_' .. frameName) and (size ~= 'none') then
				icon:SetHeight((tonumber(size) * 100) .. '%')
				icon:SetWidth((tonumber(size) * 100) .. '@')
				icon_anim:SetHeight((tonumber(size) * 100) .. '%')
				icon_anim:SetWidth((tonumber(size) * 100) .. '@')
			else
				icon:SetHeight('100%')
				icon:SetWidth('100@')
				icon_anim:SetHeight('100%')
				icon_anim:SetWidth('100@')
			end
			
			if (offset) and (not Empty(offset)) and (offset ~= 'account_iconframe_offset_') and (offset ~= 'account_iconframe_offset_' .. frameName) and (offset ~= 'none') then
				icon:SetY((tonumber(offset) * 100) .. '%')
				icon_anim:SetY((tonumber(offset) * 100) .. '%')
			else
				icon:SetY('0%')
				icon_anim:SetY('0%')
			end
			
		else
			iconframe_animated:SetVisible(0)
			iconframe_effect:SetVisible(0)
			iconframe_effect_parent:SetVisible(0)
		end
	end
end

function libAccountIcons.UpdateAccountLevel(accountLevelText, templateKey, activeInterface, prestigeLevel)

	activeInterface = activeInterface or interface
	prestigeLevel = prestigeLevel or 0
	
	if (not templateKey) or (not activeInterface) then
		println('^r libAccountIcons.UpdateAccountIcon invalid parameters')
		println('^r templateKey' .. tostring(templateKey))
		println('^r activeInterface' .. tostring(activeInterface))		
		return
	end	

	local parent 					= activeInterface:GetWidget(templateKey .. '_parent')
	local icon 						= activeInterface:GetWidget(templateKey .. '_icon')
	local icon_anim 				= activeInterface:GetWidget(templateKey .. '_icon_anim')
	local iconframe 				= activeInterface:GetWidget(templateKey .. '_iconframe')
	local iconframe_animated 		= activeInterface:GetWidget(templateKey .. '_iconframe_animated')
	local iconframe_effect_parent 	= activeInterface:GetWidget(templateKey .. '_iconframe_effect_parent')
	local iconframe_effect 			= activeInterface:GetWidget(templateKey .. '_iconframe_effect')
	local accountlevel 				= activeInterface:GetWidget(templateKey .. '_accountlevel')
	local accountlevelframe 		= activeInterface:GetWidget(templateKey .. '_accountlevelframe')

	if (not accountlevel) then	
		println('^r libAccountIcons.UpdateAccountIcon missing widgets: ' .. tostring(templateKey))
		return
	end

	if (prestigeLevel) and tonumber(prestigeLevel) and (tonumber(prestigeLevel) > 0) then
		accountlevelframe:SetTexture('/ui/shared/textures/lvl_fancy_frame.tga')
		accountlevel:SetText(tostring(prestigeLevel))
		accountlevel:SetVisible(1)		
	else
		accountlevelframe:SetTexture('/ui/shared/textures/lvl_frame.tga')
		accountlevel:SetText(tostring(accountLevelText))
		accountlevel:SetVisible(1)		
	end
end


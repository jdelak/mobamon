-- Simple Button registration/functions

libButton2 = {}	-- MUST be done here separately as it has to be able to refer to itself within itself when being built.
libButton2 = {
	initializeButton	= function(widget, buttonID, stateHandlerName, extraInfo, nameAfterButton)
		nameAfterButton = nameAfterButton or false
		-- Initializes button based on prefix
		if buttonID and type(buttonID) == 'string' and string.len(buttonID) > 0 then
			if libButton2.visualStateHandlers[stateHandlerName] then
				local stateHandler = libButton2.visualStateHandlers[stateHandlerName]
				
				if (not widget) or (not widget:IsValid()) then
					return false
				end
				
				local buttonWidgets
				if nameAfterButton then
					buttonWidgets = { button		= widget:GetWidget(buttonID..'Button') }
				else
					buttonWidgets = { button		= widget:GetWidget(buttonID) }
				end
				
				for k,v in ipairs(stateHandler.requiredWidgets) do
					buttonWidgets[v] = widget:GetWidget(buttonID..v)
				end

				local buttonInfo = {
					widgets=buttonWidgets
				}
				
				if extraInfo and type(extraInfo) == 'table' then
					for k,v in pairs(extraInfo) do
						buttonInfo[k] = v
					end
				elseif extraInfo and type(extraInfo) == 'string' then
					buttonInfo['rendermode'] = extraInfo
				end
				
				return libButton2.register(buttonInfo, stateHandlerName)
			end
		end
		return false
	end,
	validateRegistration = function(buttonInfo)
		local requiredWidgetList = {}
		local requiredWidgetMissing = false
		local registerError = ''
		local requiredWidgetString = ''
		if (
			buttonInfo.stateHandlerName and string.len(buttonInfo.stateHandlerName) > 0 and
			libButton2.visualStateHandlers[buttonInfo.stateHandlerName] and
			type(libButton2.visualStateHandlers[buttonInfo.stateHandlerName]) == 'table'
		) then
			local visualStateHandler = libButton2.visualStateHandlers[buttonInfo.stateHandlerName]
			table.insert(buttonInfo.widgets, 'button')
			for k,v in ipairs(visualStateHandler.requiredWidgets) do
				if not (buttonInfo.widgets[v] and type(buttonInfo.widgets[v]) == 'userdata' and buttonInfo.widgets[v]:IsValid()) then
					requiredWidgetMissing = true
					if string.len(requiredWidgetString) > 0 then requiredWidgetString = requiredWidgetString..'^w, ' end
					requiredWidgetString = requiredWidgetString..'^069'..v
				end
			end
			if not requiredWidgetMissing then
				if visualStateHandler.validate and type(visualStateHandler.validate) == 'function' then
					if visualStateHandler.validate(buttonInfo) then
						buttonInfo.stateHandler = visualStateHandler
						return true
					else
						registerError = 'State handler validate failed.'
					end
				else
					return true
				end
			else
				registerError = 'Required widget(s) missing - '..requiredWidgetString..'.'
			end
		else
			registerError = 'Invalid state handler.'
		end
		print('^960Warning:^w Unable to register button ^w - '..registerError..'\n')
		printr(buttonInfo)
		return false
	end,
	register = function(baseButtonInfo, stateHandlerName, extraStateHandlers)
		local stateList		= {}
		local visualStateHandler = nil
		local hasExtraStateHandlers = false
		if not (baseButtonInfo and type(baseButtonInfo) == 'table') then
			baseButtonInfo = {}
		end
		
		local buttonInfo = {
			currentState		= 1,
			stateHandlerName	= stateHandlerName
		}

		if extraStateHandlers and type(extraStateHandlers) == 'table' then
			hasExtraStateHandlers = true
		end

		if baseButtonInfo and type(baseButtonInfo) == 'table' then
			for k,v in pairs(baseButtonInfo) do
				buttonInfo[k] = v
			end
		end
		
		if libButton2.validateRegistration(buttonInfo) then
			visualStateHandler = libButton2.visualStateHandlers[stateHandlerName]
			
			buttonInfo.widgets.button:SetCallback('onbutton',
				function(sourceWidget, currentState, oldState)
					local funcAction = nil
					if currentState ~= oldState and (currentState ~= 'over' or (oldState ~= 'downright' or sourceWidget:GetCallback('onrightclick'))) then
						if visualStateHandler.stateFuncs[currentState] and type(visualStateHandler.stateFuncs[currentState]) == 'function' then
							visualStateHandler.stateFuncs[currentState](buttonInfo, oldState)
						end
						if hasExtraStateHandlers and extraStateHandlers[currentState] and type(extraStateHandlers[currentState]) == 'function' then
							extraStateHandlers[currentState](sourceWidget, buttonInfo, oldState)
						end
					end
				end
			)
			
			local disabledFunc		= visualStateHandler.stateFuncs.disabled
			
			if (not buttonInfo.widgets.button:IsEnabled()) and disabledFunc and type(disabledFunc) == 'function' then
				disabledFunc(buttonInfo)
			end
			
			return buttonInfo -- In case it needs to be used elsewhere
		end
	end,
	visualStateHandlers = {
		standardButton2 = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Background', 'Label' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_up'] or '/ui/shared/frames/stnd_btn_up.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
					
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)	
					end
					
				end,
				over = function(buttonInfo)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_over'] or '/ui/shared/frames/stnd_btn_over.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
				end,
				down = function(buttonInfo)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Background:SetColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Background:SetBorderColor(0.6, 0.6, 0.6)
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Background:SetRenderMode('grayscale')
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Label:SetColor(0.5, 0.5, 0.5)
					buttonInfo.widgets.Background:SetColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetBorderColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_up'] or '/ui/shared/frames/stnd_btn_up.tga')
				end
			}
		},
		primaryButton = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Background', 'Label' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_up'] or '/ui/shared/frames/primary_btn_up.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
					
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)	
					end
					
				end,
				over = function(buttonInfo)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_over'] or '/ui/shared/frames/primary_btn_over.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
				end,
				down = function(buttonInfo)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Background:SetColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Background:SetBorderColor(0.6, 0.6, 0.6)
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Background:SetRenderMode('grayscale')
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Label:SetColor(0.5, 0.5, 0.5)
					buttonInfo.widgets.Background:SetColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetBorderColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_up'] or '/ui/shared/frames/primary_btn_up.tga')
				end
			}
		},
		standardButtonBlue = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Background', 'Label' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_up'] or '/ui/shared/frames/blue_btn_up.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
					
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)	
					end
					
				end,
				over = function(buttonInfo)
					buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_over'] or '/ui/shared/frames/blue_btn_over.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
				end,
				down = function(buttonInfo)
					buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Background:SetColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Background:SetBorderColor(0.6, 0.6, 0.6)
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Background:SetRenderMode('grayscale')
					buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
					buttonInfo.widgets.Label:SetColor(0.5, 0.5, 0.5)
					buttonInfo.widgets.Background:SetColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetBorderColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetTexture(buttonInfo['texture_up'] or '/ui/shared/frames/blue_btn_up.tga')
				end
			}
		},
		navButton = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Background', 'Label' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end
					buttonInfo.widgets.Label:SetColor(1,1,1)
					if buttonInfo.widgets.Background:GetType() == 'frame' and (not buttonInfo.skipColor) then
						buttonInfo.widgets.Background:SetBorderColor(1,1,1)
						buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
						buttonInfo.widgets.Background:SetColor(1,1,1)
					end
				end,
				over = function(buttonInfo)
					-- buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
					-- buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()					
					
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.02, 200, 0.8, 0.2)

					buttonInfo.widgets.Label:SetColor(1,1,1)
					if buttonInfo.widgets.Background:GetType() == 'frame' and (not buttonInfo.skipColor) then
						buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
						buttonInfo.widgets.Background:SetColor(1,1,1)
						buttonInfo.widgets.Background:SetBorderColor(1,1,1)
					end
				end,
				down = function(buttonInfo)
					if buttonInfo.widgets.Background:GetType() == 'frame' and (not buttonInfo.skipColor) then
						buttonInfo.widgets.Background:SetColor(0.6, 0.6, 0.6)
						buttonInfo.widgets.Background:SetBorderColor(0.6, 0.6, 0.6)
					end
				end,				
				disabled = function(buttonInfo)
					buttonInfo.widgets.Label:SetColor(0.5, 0.5, 0.5)
					if buttonInfo.widgets.Background:GetType() == 'frame' and (not buttonInfo.skipColor) then
						buttonInfo.widgets.Background:SetRenderMode('grayscale')
						buttonInfo.widgets.Background:SetColor(0.8, 0.8, 0.8)
						buttonInfo.widgets.Background:SetBorderColor(0.8, 0.8, 0.8)
					end
				end
			}
		},
		standardButton2Check = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Background', 'Label', 'Check' },
			stateNum = function(buttonInfo, stateName)
				if (not buttonInfo.disableCheck) then
					if buttonInfo.widgets.button:GetButtonState() == 1 then
						buttonInfo.widgets.Check:SetVisible(true)
					else
						buttonInfo.widgets.Check:SetVisible(false)
					end
				end
			end,
			stateFuncs = {
				up = function(buttonInfo, oldState)
				
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end
					
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture('/ui/shared/frames/stnd_btn_up.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
					buttonInfo.stateHandler.stateNum(buttonInfo, stateName)
				end,
				over = function(buttonInfo)
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Background:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Label:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetTexture('/ui/shared/frames/stnd_btn_over.tga')
					buttonInfo.widgets.Background:SetColor(1,1,1)
					buttonInfo.widgets.Background:SetBorderColor(1,1,1)
					buttonInfo.stateHandler.stateNum(buttonInfo, stateName)
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Background:SetRenderMode('grayscale')
					buttonInfo.widgets.Label:SetColor(0.5, 0.5, 0.5)
					buttonInfo.widgets.Background:SetColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetBorderColor(0.8, 0.8, 0.8)
					buttonInfo.widgets.Background:SetTexture('/ui/shared/frames/stnd_btn_up.tga')
					buttonInfo.stateHandler.stateNum(buttonInfo, stateName)
				end
			}
		},
		optionsTab = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Label', 'Highlight' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end
					
					buttonInfo.widgets.Highlight:FadeOut(175)
				end,
				over = function(buttonInfo)
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Highlight:FadeIn(175)
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Highlight:FadeOut(175)
				end
			}
		},
		basicBounce = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end
				end,
				over = function(buttonInfo)
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
				end
			}
		},
		socialEntryUserActionItem = {
			validate = function(buttonInfo)
				buttonInfo.baseTexture	= buttonInfo.widgets.Icon:GetTexture()
				if buttonInfo.textureSwap == nil then buttonInfo.textureSwap = true end
				-- buttonInfo.baseColorR, buttonInfo.baseColorG, buttonInfo.baseColorB, buttonInfo.baseColorA = buttonInfo.widgets.Icon:GetColor()
				return true
			end,
			requiredWidgets = { 'Icon' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					buttonInfo.widgets.Icon:UnregisterWatchLua('System')
					buttonInfo.widgets.Icon:SetRotation(0)
					buttonInfo.widgets.Icon:Scale('85@', '85%', 250)
					buttonInfo.widgets.Icon:Sleep(300, function()
						buttonInfo.widgets.Icon:SetWidth('85@')
						buttonInfo.widgets.Icon:SetHeight('85%')		
					end)
					buttonInfo.widgets.Icon:SetColor(
						(buttonInfo.baseColorR or 1),
						(buttonInfo.baseColorG or 1),
						(buttonInfo.baseColorB or 1),
						(buttonInfo.baseColorA or 1)
					)
					if buttonInfo.textureSwap then
						buttonInfo.widgets.Icon:SetTexture(buttonInfo.baseTexture)
					end
				end,
				over = function(buttonInfo)
					buttonInfo.widgets.Icon:UnregisterWatchLua('System')
					buttonInfo.widgets.Icon:RegisterWatchLua('System', function(widget, trigger)
						widget:SetRotation(math.sin(((trigger.hostTime % 300) / 300) * (3.14159265 * 2)) * 8)
					end, false, nil, 'hostTime')
					buttonInfo.widgets.Icon:Scale('100@', '100%', 250)
					buttonInfo.widgets.Icon:Sleep(250, function()
						buttonInfo.widgets.Icon:SetWidth('100@')
						buttonInfo.widgets.Icon:SetHeight('100%')
					end)
					buttonInfo.widgets.Icon:SetColor('#64e0ff')
					if buttonInfo.textureSwap and buttonInfo.overTexture then
						buttonInfo.widgets.Icon:SetTexture(buttonInfo.overTexture)
					end
				end
			}
		},
		key = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Highlight' }, -- highlightFrame
			stateFuncs = {
				up = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end
					buttonInfo.widgets.Highlight:FadeOut(100)
				end,
				over = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					end
					buttonInfo.widgets.Highlight:FadeIn(100)
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Highlight:SetVisible(false)
				end
			}
		},
		closeXButton = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Backer' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end

					buttonInfo.widgets.Backer:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Backer:SetColor(1,1,1)
					buttonInfo.widgets.Backer:SetBorderColor(1,1,1)
					buttonInfo.widgets.Backer:SetTexture('/ui/shared/frames/stnd_btn_up.tga')
				end,
				over = function(buttonInfo)
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Backer:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Backer:SetColor(1,1,1)
					buttonInfo.widgets.Backer:SetBorderColor(1,1,1)
					buttonInfo.widgets.Backer:SetTexture('/ui/shared/frames/stnd_btn_over.tga')
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Backer:SetRenderMode('grayscale')
					buttonInfo.widgets.Backer:SetColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Backer:SetBorderColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Backer:SetTexture('/ui/shared/frames/stnd_btn_over.tga')
				end
			}
		},
		iconButton = {
			validate = function(buttonInfo)
				buttonInfo.bodyWidth			= buttonInfo.widgets.Body:GetWidth()
				buttonInfo.bodyHeight			= buttonInfo.widgets.Body:GetHeight()
				return true
			end,
			requiredWidgets = { 'Body', 'Backer' },
			stateFuncs = {
				up = function(buttonInfo, oldState)
					if oldState ~= 'over' then
						libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, 400, 0.05, 150, 0.85, 0.15)
					end

					buttonInfo.widgets.Backer:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Backer:SetColor(1,1,1)
					buttonInfo.widgets.Backer:SetBorderColor(1,1,1)
					buttonInfo.widgets.Backer:SetTexture('/ui/shared/frames/stnd_btn_up.tga')
				end,
				over = function(buttonInfo)
					libAnims.bounceIn(buttonInfo.widgets.Body, buttonInfo.bodyWidth, buttonInfo.bodyHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					buttonInfo.widgets.Backer:SetRenderMode(buttonInfo['rendermode'] or 'normal')
					buttonInfo.widgets.Backer:SetColor(1,1,1)
					buttonInfo.widgets.Backer:SetBorderColor(1,1,1)
					buttonInfo.widgets.Backer:SetTexture('/ui/shared/frames/stnd_btn_over.tga')
				end,
				disabled = function(buttonInfo)
					buttonInfo.widgets.Backer:SetRenderMode('grayscale')
					buttonInfo.widgets.Backer:SetColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Backer:SetBorderColor(0.6, 0.6, 0.6)
					buttonInfo.widgets.Backer:SetTexture('/ui/shared/frames/stnd_btn_over.tga')
				end
			}
		},		
		abilityButtonPrimary = {
			validate = function(buttonInfo)
				buttonInfo.iconWidth		= buttonInfo.widgets.icon:GetWidth()
				buttonInfo.iconHeight		= buttonInfo.widgets.icon:GetHeight()
				buttonInfo.glossWidth		= buttonInfo.widgets.gloss:GetWidth()
				buttonInfo.glossHeight		= buttonInfo.widgets.gloss:GetHeight()
				buttonInfo.useAnims			= true
				return true
			end,
			requiredWidgets = { 'icon', 'gloss' },
			stateFuncs = {
				over	= function(buttonInfo)
					if buttonInfo.useAnims then
						libAnims.bounceIn(buttonInfo.widgets.icon, buttonInfo.iconWidth, buttonInfo.iconHeight, nil, nil, 0.02, 200, 0.8, 0.2)
						libAnims.bounceIn(buttonInfo.widgets.gloss, buttonInfo.glossWidth, buttonInfo.glossHeight, nil, nil, 0.02, 200, 0.8, 0.2)
						buttonInfo.widgets.gloss:SetTexture('/ui/elements:gloss_over')
					end
				end,
				up		= function(buttonInfo, oldState)
					if buttonInfo.useAnims then
						if oldState ~= 'over' then
							libAnims.bounceIn(buttonInfo.widgets.icon, buttonInfo.iconWidth, buttonInfo.iconHeight, nil, 400, 0.05, 150, 0.85, 0.15)
							libAnims.bounceIn(buttonInfo.widgets.gloss, buttonInfo.glossWidth, buttonInfo.glossHeight, nil, 400, 0.05, 150, 0.85, 0.15)
						end

						buttonInfo.widgets.gloss:SetTexture('/ui/elements:gloss_up')
					end
				end,
				down	= function(buttonInfo)
					if buttonInfo.useAnims then
						buttonInfo.widgets.gloss:SetTexture('/ui/elements:gloss_down')
					end
				end
			}
		},
		abilityButtonStash = {
			validate = function(buttonInfo)
				buttonInfo.iconWidth		= buttonInfo.widgets.icon:GetWidth()
				buttonInfo.iconHeight		= buttonInfo.widgets.icon:GetHeight()
				return true
			end,
			requiredWidgets = { 'icon' },
			stateFuncs = {
				over	= function(buttonInfo)
					if buttonInfo.useAnims then
						libAnims.bounceIn(buttonInfo.widgets.icon, buttonInfo.iconWidth, buttonInfo.iconHeight, nil, nil, 0.02, 200, 0.8, 0.2)
					end
				end,
				up		= function(buttonInfo, oldState)
					if buttonInfo.useAnims then
						if oldstate ~= 'over' then
							libAnims.bounceIn(buttonInfo.widgets.icon, buttonInfo.iconWidth, buttonInfo.iconHeight, nil, 400, 0.05, 150, 0.85, 0.15)
						end
						
					end
				end
			}
		},
	}
}

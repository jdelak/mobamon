local interface = object
mainUI = mainUI or {}
mainUI.contextMenu = mainUI.contextMenu or {}
gameUI = gameUI or {}
gameUI.contextMenu = gameUI.contextMenu or {}
Windows = Windows or {}
Windows.state = Windows.state or {}

local function register()
		
	local function printdebug(...)
		if GetCvarBool('ui_debugContextMenu') then
			println(...)
		end
	end
		
	local function GetWidget(widget, fromInterface, hideErrors)
		fromInterface = fromInterface or 'context'
		printdebug('GetWidget ' .. tostring(widget) .. ' from ' .. tostring(fromInterface))
		if (widget) then
			local returnWidget		
			if (Windows.ContextMenu) and (Windows.ContextMenu:GetInterface(fromInterface)) then
				returnWidget = Windows.ContextMenu:GetInterface(fromInterface):GetWidget(widget)
			else
				println('^o GetWidget context could not find interface ' .. tostring(fromInterface))
			end	
			if (returnWidget) then
				return returnWidget
			else
				if (not hideErrors) then println('GetWidget context failed to find ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface)) end
				return nil		
			end	
		else
			println('GetWidget called without a target')
			return nil
		end
	end	
	
	if (Windows.ContextMenu) and (Windows.ContextMenu:IsValid()) then
		Windows.ContextMenu:Close()		
		printdebug('We had a reference to the context menu on startup so we closed it')
	end
	Windows.ContextMenu = nil
	Windows.state.ContextVisible = false

	function mainUI.contextMenu.ShowContextMenu()
		printdebug('mainUI.contextMenu.ShowContextMenu()')
		if (Windows.ContextMenu) and (Windows.ContextMenu:IsValid()) then
			libThread.threadFunc(function()	
				
				printdebug('mainUI.contextMenu.ShowContextMenu(): OpenMenu')
				GetWidget('general_context_menu_player'):OpenMenu(false)
				
				printdebug('Wating one frame then resizing window')
				wait(1)		
				if (GetWidget('general_context_menu_player_listbox')) and (GetWidget('general_context_menu_player_listbox'):IsValid()) then
					printdebug('mainUI.contextMenu.ShowContextMenu(): Resize the window to the listbox size')
					Windows.ContextMenu:Resize(GetWidget('general_context_menu_player_listbox'):GetWidthFromString('+8s'), GetWidget('general_context_menu_player_listbox'):GetHeightFromString('+12s'), false)
				else
					printdebug('mainUI.contextMenu.ShowContextMenu(): ^r Listbox was not valid')
				end
				
				printdebug('Wating one frame then moving window')
				wait(1)
				if (Windows.ContextMenu) and (Windows.ContextMenu:IsValid()) then
					if (ContextMenuMultiWindowTrigger.activeMultiWindowWindow == 'friends') and (Windows.Friends) then
						local posX, posY = Windows.Friends:GetCursorPos()
						posX, posY = Windows.Friends:ClientToScreen(posX, posY)
						Windows.ContextMenu:Move(posX, posY)
						printdebug('mainUI.contextMenu.ShowContextMenu(): This is for friends, move window based on friends position')
					elseif (ContextMenuMultiWindowTrigger.activeMultiWindowWindow == 'chat') and (Windows.Chat) then
						local posX, posY = Windows.Chat:GetCursorPos()
						posX, posY = Windows.Chat:ClientToScreen(posX, posY)
						Windows.ContextMenu:Move(posX, posY)	
						printdebug('mainUI.contextMenu.ShowContextMenu(): This is for chat, move window based on friends position')
					else
						Windows.ContextMenu:Move(Input.GetCursorPosX(), Input.GetCursorPosY())
						printdebug('mainUI.contextMenu.ShowContextMenu(): Not sure what this is for, move window based on cursor position')
					end
				else
					printdebug('mainUI.contextMenu.ShowContextMenu(): ^r Context menu was not valid')
				end
				
				printdebug('Wating one frame then showing context menu and listbox')
				wait(1)
				if (Windows.ContextMenu) and (Windows.ContextMenu:IsValid()) then
					Windows.ContextMenu:Show(true)
					printdebug('mainUI.contextMenu.ShowContextMenu(): Show the context menu')
				else
					printdebug('mainUI.contextMenu.ShowContextMenu(): ^r Context menu window was invalid - cannot show the context menu')
				end
				if (GetWidget('general_context_menu_player_listbox')) and (GetWidget('general_context_menu_player_listbox'):IsValid()) then
					GetWidget('general_context_menu_player_listbox'):SetVisible(1)
					printdebug('mainUI.contextMenu.ShowContextMenu(): Show the listbox ')
				else
					printdebug('mainUI.contextMenu.ShowContextMenu(): ^r Listbox was invalid - cannot show the Listbox')
				end
				
			end)
		end
	end		
		
	function mainUI.contextMenu.HideContextMenu()
		printdebug('mainUI.contextMenu.HideContextMenu()')
		if (Windows.ContextMenu) and (Windows.ContextMenu:IsValid()) then
			Windows.ContextMenu:Hide(true)
			printdebug('mainUI.contextMenu.HideContextMenu(): Hide the window ')
		else
			printdebug('mainUI.contextMenu.HideContextMenu(): ^r Window not valid - Cannot Hide the window ')
		end
		if (GetWidget('general_context_menu_player_listbox')) then
			GetWidget('general_context_menu_player_listbox'):SetVisible(0)
			printdebug('mainUI.contextMenu.HideContextMenu(): Hide the listbox ')
		else
			printdebug('mainUI.contextMenu.HideContextMenu(): ^r listbox not valid - Cannot hide the listbox ')
		end
	end			
		
	function mainUI.contextMenu.SilentlySpawnContextMenu()
		printdebug('mainUI.contextMenu.SilentlySpawnContextMenu() ')
		local widget = object or interface
		if (Windows.ContextMenu) and (not Windows.state.ContextVisible) then
			printdebug('mainUI.contextMenu.SilentlySpawnContextMenu(): Window exists but state is not visible, call ShowContextMenu')
			mainUI.contextMenu.ShowContextMenu()		
		elseif (not Windows.state.ContextVisible) then
			printdebug('mainUI.contextMenu.SilentlySpawnContextMenu(): Window does not exist and is not visible, spawn it, then call ShowContextMenu')
			Windows.state.ContextVisible = true
			Windows.ContextMenu = Window.New(
					interface:GetXFromString('0s'),
					interface:GetYFromString('0s'),
					interface:GetWidthFromString('200s'),
					interface:GetHeightFromString('500s'),
				{
					Window.BORDERLESS,
					Window.THREADED,
					Window.COMPOSITE,
					Window.RESIZABLE,
					-- Window.CENTER,
					Window.HIDDEN,
					Window.POSITION,
					Window.NOACTIVATE,
					Window.TOPMOST,
				},
				"/ui_dev/context/context.interface",
				Translate('window_name_context_menu')
			)
			mainUI.contextMenu.ShowContextMenu()
		end
	end	
	
	interface:RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
		if (trigger.contextMenuArea >= 0) then
			printdebug('ContextMenuMultiWindowTrigger ' .. tostring(trigger.contextMenuArea) .. ' ^g Attempt to show context menu')
			mainUI.contextMenu.SilentlySpawnContextMenu()
		else
			printdebug('ContextMenuMultiWindowTrigger ' .. tostring(trigger.contextMenuArea) .. ' ^y Attempt to hide context menu')
			mainUI.contextMenu.HideContextMenu()
		end
	end, true)	

end

register()

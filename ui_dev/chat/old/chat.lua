mainUI 					= mainUI 					or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
mainUI.savedLocally.openMemberlists = mainUI.savedLocally.openMemberlists or {}
mainUI.savedRemotely.subscribedGroups = mainUI.savedRemotely.subscribedGroups or {}
Windows = Windows or {}
Chat = Chat or {}
local interface = object
local interfaceName = object:GetName()
Chat[interfaceName] = Chat[interfaceName] or {}

ClientInfo = ClientInfo or {}
ClientInfo.duplicateUsernameTable = ClientInfo.duplicateUsernameTable or {}
mainUI.chatManager = {
	channelBody					= object:GetWidget('chatWindowChannelArea'),
	channelList					= object:GetWidget('mainChannelListbox'),
}

local ChatStatusTriggerUI = LuaTrigger.GetTrigger('ChatStatusTriggerUI') or LuaTrigger.CreateCustomTrigger('ChatStatusTriggerUI', {
		{ name	=   'chatChannelMultiWindowOpen',					type	= 'boolean'},	
		{ name	=   'chatChannelLauncherWindowOpen',				type	= 'boolean'},	
		{ name	=   'instantMessageMultiWindowOpen',				type	= 'boolean'},	
		{ name	=   'instantMessageLauncherWindowOpen',				type	= 'boolean'},	
	}
)

ChatStatusTriggerUI.chatChannelMultiWindowOpen 								= false
ChatStatusTriggerUI.chatChannelLauncherWindowOpen 							= false
ChatStatusTriggerUI.instantMessageMultiWindowOpen 							= false
ChatStatusTriggerUI.instantMessageLauncherWindowOpen 						= false
ChatStatusTriggerUI:Trigger(false)

local function InitMainChatWindowControlClient(object)
	println('^y^: InitMainChatWindowControlClient ')

	Chat[interfaceName].RegisterIMWindow = function()
	
	end
	
	Chat.RegisterIMWindow = function()
		Chat[interfaceName].RegisterIMWindow()
	end		
	
	Chat[interfaceName].RegisterChatChannelWindow = function()
	
	end
	
	Chat.RegisterChatChannelWindow = function()
		Chat[interfaceName].RegisterChatChannelWindow()
	end	

	local function ChatChannelWindowRegister(object)

	end
	
	local function ChatChannelLauncherRegister(object)
		
		UnwatchLuaTriggerByKey('mainPanelStatus', 'WindowControlmainPanelStatus')
		WatchLuaTrigger('mainPanelStatus', function(trigger)	
			if (not trigger.chatConnected) and (trigger.chatConnectionState ~= 0) then
				Windows.SpawnChatChannelWindow()	
				trigger.chatConnected = true
			elseif (trigger.chatConnected) and (trigger.chatConnectionState == 0) then
				trigger.chatConnected = false
			else

			end		
		end, 'WindowControlmainPanelStatus', 'main', 'chatConnected', 'chatConnectionState')
		
		function Windows.SpawnInstantMessageWindow()
			if (Windows.instantMessageWindow) then
				Windows.instantMessageWindow:Restore()	
				ChatStatusTriggerUI.instantMessageMultiWindowOpen = true
				ChatStatusTriggerUI.instantMessageLauncherWindowOpen = false
				ChatStatusTriggerUI:Trigger(false)
			else
				local width = interface:GetWidthFromString('640s')
				local height = interface:GetHeightFromString('400s')
				Windows.instantMessageWindow = Windows.instantMessageWindow or Window.New(
					0,
					0,
					width,
					height,
					{
						Window.BORDERLESS,
						Window.THREADED,
						Window.COMPOSITE,
						-- Window.RESIZABLE,
						Window.CENTER,
					},
					"/ui_dev/chat/chat_window_im.interface",
					"Chat"
				)
				ChatStatusTriggerUI.instantMessageMultiWindowOpen = true
				ChatStatusTriggerUI.instantMessageLauncherWindowOpen = false
				ChatStatusTriggerUI:Trigger(false)
			end
		end		
		
		function Windows.SpawnChatChannelWindow()
			if (Windows.chatChannelWindow) then
				Windows.chatChannelWindow:Restore()	
				ChatStatusTriggerUI.chatChannelMultiWindowOpen = true
				ChatStatusTriggerUI.chatChannelLauncherWindowOpen = false
				ChatStatusTriggerUI:Trigger(false)
			else
				local width = interface:GetWidthFromString('640s')
				local height = interface:GetHeightFromString('400s')
				Windows.chatChannelWindow = Windows.chatChannelWindow or Window.New(
					0,
					0,
					width,
					height,
					{
						Window.BORDERLESS,
						Window.THREADED,
						Window.COMPOSITE,
						-- Window.RESIZABLE,
						Window.CENTER,
					},
					"/ui_dev/chat/chat_window_channel.interface",
					"Chat"
				)
				ChatStatusTriggerUI.chatChannelMultiWindowOpen = true
				ChatStatusTriggerUI.chatChannelLauncherWindowOpen = false
				ChatStatusTriggerUI:Trigger(false)
			end
		end	
		
		if (Windows.chatChannelWindow) then
			Windows.chatChannelWindow:Close()	
		end		
		if (Windows.chatChannelWindow) then
			Windows.chatChannelWindow:Close()	
		end		
		Windows.chatChannelWindow = nil
		Windows.chatChannelWindow = nil			
		
	end
	
	if (interfaceName == 'chat_window_channel') then
		ChatChannelWindowRegister(object)
	elseif (interfaceName == 'main') then
		ChatChannelLauncherRegister(object)		
	end
	
end

if GetCvarBool('ui_multiWindowChat') then
	InitMainChatWindowControlClient(object)
end

libThread.threadFunc(function()
	wait(1000)
	Windows.SpawnChatChannelWindow()
end)



-- Custom Triggers that need to be accessed globally

LuaTrigger.CreateCustomTrigger('simpleMultiWindowTipGrowYData',
	{
		{ name	= 'show',		type	= 'boolean' },
		{ name	= 'title',		type	= 'string' },
		{ name	= 'body',		type	= 'string' },
		{ name	= 'icon',		type	= 'string' },
		{ name	= 'hasIcon',	type	= 'boolean' },
		{ name	= 'hasTitle',	type	= 'boolean' },
		{ name	= 'hasBody',	type	= 'boolean' },
		{ name	= 'width',		type	= 'number' },
		{ name	= 'xOffset',	type	= 'number' },
		{ name	= 'yOffset',	type	= 'number' },

	}
)

LuaTrigger.CreateCustomTrigger('simpleTipGrowYData',
	{
		{ name	= 'show',		type	= 'boolean' },
		{ name	= 'title',		type	= 'string' },
		{ name	= 'body',		type	= 'string' },
		{ name	= 'icon',		type	= 'string' },
		{ name	= 'hasIcon',	type	= 'boolean' },
		{ name	= 'hasTitle',	type	= 'boolean' },
		{ name	= 'hasBody',	type	= 'boolean' },
		{ name	= 'width',		type	= 'number' },
		{ name	= 'xOffset',	type	= 'number' },
		{ name	= 'yOffset',	type	= 'number' },

	}
)

LuaTrigger.CreateCustomTrigger('simpleTipNoFloatData',
	{
		{ name	= 'show',		type	= 'boolean' },
		{ name	= 'title',		type	= 'string' },
		{ name	= 'body',		type	= 'string' },
		{ name	= 'icon',		type	= 'string' },
		{ name	= 'hasIcon',	type	= 'boolean' },
		{ name	= 'hasTitle',	type	= 'boolean' },
		{ name	= 'hasBody',	type	= 'boolean' },
		{ name	= 'x',			type	= 'string' },
		{ name	= 'y',			type	= 'string' },
		{ name	= 'align',		type	= 'string' },
		{ name	= 'valign',		type	= 'string' },
		{ name	= 'width',		type	= 'number' }
	}
)

-- Context Menu

ContextMenuTrigger = LuaTrigger.CreateCustomTrigger('ContextMenuTrigger',
	{
		{ name	= 'contextMenuArea',				type	= 'number' },
		{ name	= 'selectedUserIsLocalClient',		type	= 'boolean' },
		{ name	= 'selectedUserIsFriend',			type	= 'boolean' },
		{ name	= 'selectedUserOnlineStatus',		type	= 'boolean' },
		{ name	= 'selectedUserIsInGame',			type	= 'boolean' },
		{ name	= 'selectedUserIsInParty',			type	= 'boolean' },
		{ name	= 'selectedUserIsInLobby',			type	= 'boolean' },
		{ name	= 'localClientIsSpectating',		type	= 'boolean' },
		{ name	= 'needToApprove',					type	= 'boolean' },
		{ name	= 'selectedUserIdentID',			type	= 'string' },
		{ name	= 'selectedUserUniqueID',			type	= 'string' },
		{ name	= 'selectedUserUsername',			type	= 'string' },
		{ name	= 'channelID',						type	= 'string' },
		{ name	= 'endMatchSection',				type	= 'number' },
		{ name	= 'gameAddress',					type	= 'string' },
		{ name	= 'selectedUserIsIgnored',			type	= 'boolean' },
		{ name	= 'joinableGame',					type	= 'boolean' },
		{ name	= 'joinableParty',					type	= 'boolean' },
		{ name	= 'spectatableGame',				type	= 'boolean' },
	}
)

LuaTrigger.CreateCustomTrigger('socialEntryDataDragged',	-- For the visual clone that you're dragging
	{
		{ name		= 'exists',		type	= 'boolean' },
		{ name		= 'type',		type	= 'number' },
		{ name		= 'title',		type	= 'string' },
		{ name		= 'subtitle',	type	= 'string' },
		{ name		= 'status',		type	= 'number' },
		{ name		= 'icon',		type	= 'string' }
	}
)

LuaTrigger.CreateCustomTrigger('socialPanelInfoHovering',
	{
		{ name	= 'friendHoveringIndex',				type	= 'number' },
		{ name	= 'friendHoveringIdentID',				type	= 'string' },
		{ name	= 'friendHoveringUniqueID',				type	= 'string' },
		{ name	= 'friendHoveringName',					type	= 'string' },
		{ name	= 'friendHoveringAcceptStatus',			type	= 'string' },
		{ name	= 'friendHoveringGameAddress',			type	= 'string' },
		{ name	= 'friendHoveringLabel',				type	= 'string' },
		{ name	= 'friendHoveringWidgetIndex',			type	= 'number' },
		{ name	= 'friendHoveringIsPending',			type	= 'boolean' },
		{ name	= 'friendHoveringIsInParty',			type	= 'boolean' },
		{ name	= 'friendHoveringIsInLobby',			type	= 'boolean' },
		{ name	= 'friendHoveringIsInGame',				type	= 'boolean' },
		{ name	= 'friendHoveringCanSpectate',			type	= 'boolean' },
		{ name	= 'friendHoveringIsHoveringMenu',		type	= 'boolean' },
		{ name 	= 'friendHoveringIsOnline',				type	= 'boolean' },
		{ name 	= 'friendHoveringType',					type	= 'number' },
		{ name 	= 'friendHoveringSubType',				type	= 'string' },
		{ name	= 'joinableGame',						type	= 'boolean' },
		{ name	= 'joinableParty',						type	= 'boolean' },
		{ name	= 'spectatableGame',					type	= 'boolean' },
	}
)

LuaTrigger.CreateCustomTrigger('socialPanelInfo',
	{
		{ name	= 'friendsListUserOpen',		type	= 'boolean' },
		{ name	= 'friendsListOpen',			type	= 'boolean' },
		{ name	= 'friendsListReOrderLock',		type	= 'boolean' },
		{ name	= 'friendsListSingleUpdate',	type	= 'boolean' },
		{ name	= 'friendsListQueueUpdate',		type	= 'boolean' },
		{ name	= 'friendHoveringIndex',		type	= 'number' },
		{ name	= 'friendHoveringWidgetIndex',	type	= 'number' },
		{ name	= 'partyListReOrderLock',		type	= 'boolean' },
		{ name	= 'partyListQueueUpdate',		type	= 'boolean' },
		{ name	= 'partyListSingleUpdate',		type	= 'boolean' },
	}
)

local optionsTrigger = LuaTrigger.CreateCustomTrigger('optionsTrigger',
	{
		{ name	= 'updateVisuals',				type	= 'bool' },
		{ name	= 'hasChanges',					type	= 'bool' },
		{ name	= 'isSynced',					type	= 'bool' },
	}
)

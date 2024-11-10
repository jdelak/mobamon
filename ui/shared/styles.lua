-- Lua styles

-- styles = {}

--[[

	// Colors for General Purpose
	#define BLACK		CVec4f(0.00f, 0.00f, 0.00f, 1.00f)
	#define BLUE		CVec4f(0.00f, 0.00f, 1.00f, 1.00f)
	#define BROWN		CVec4f(0.30f, 0.16f, 0.01f, 1.00f)
	#define CYAN		CVec4f(0.00f, 1.00f, 1.00f, 1.00f)
	#define GRAY		CVec4f(0.50f, 0.50f, 0.50f, 1.00f)
	#define GREEN		CVec4f(0.00f, 0.50f, 0.00f, 1.00f)
	#define LIME		CVec4f(0.00f, 1.00f, 0.00f, 1.00f)
	#define MAGENTA		CVec4f(1.00f, 0.00f, 1.00f, 1.00f)
	#define MAROON		CVec4f(0.50f, 0.00f, 0.00f, 1.00f)
	#define NAVY		CVec4f(0.00f, 0.00f, 0.50f, 1.00f)
	#define OLIVE		CVec4f(0.50f, 0.50f, 0.00f, 1.00f)
	#define ORANGE		CVec4f(1.00f, 0.65f, 0.00f, 1.00f)
	#define PURPLE		CVec4f(0.50f, 0.00f, 0.50f, 1.00f)
	#define RED			CVec4f(1.00f, 0.00f, 0.00f, 1.00f)
	#define SILVER		CVec4f(0.75f, 0.75f, 0.75f, 1.00f)
	#define TEAL		CVec4f(0.00f, 0.50f, 0.50f, 1.00f)
	#define WHITE		CVec4f(1.00f, 1.00f, 1.00f, 1.00f)
	#define YELLOW		CVec4f(1.00f, 1.00f, 0.00f, 1.00f)
	
	// Exact Player Colors
	#define PCBLUE		CVec4f(0.00f, 0.26f, 1.00f, 1.00f)
	#define PCTEAL		CVec4f(0.11f, 0.90f, 0.73f, 1.00f) 
	#define PCPURPLE	CVec4f(0.33f, 0.00f, 0.51f, 1.00f) 
	#define PCYELLOW	CVec4f(1.00f, 0.99f, 0.00f, 1.00f) 
	#define PCORANGE	CVec4f(1.00f, 0.54f, 0.06f, 1.00f) 
	#define PCPINK		CVec4f(0.90f, 0.36f, 0.69f, 1.00f) 
	#define PCGRAY		CVec4f(0.58f, 0.59f, 0.59f, 1.00f) 
	#define PCLIGHTBLUE	CVec4f(0.49f, 0.75f, 0.95f, 1.00f) 
	#define PCDARKGREEN	CVec4f(0.06f, 0.38f, 0.28f, 1.00f) 
	#define PCBROWN		CVec4f(0.31f, 0.17f, 0.02f, 1.00f) 
	
	#define GOLDENSHIELD		CVec4f(0.859f, 0.749f, 0.290f, 1.0f)
	#define SILVERSHIELD		CVec4f(0.486f, 0.552f, 0.654f, 1.0f)
	#define LEGION_RED			CVec4f(1.00f, 0.00f, 0.00f, 1.00f)
	#define HELLBOURNE_GREEN	CVec4f(0.125f, 0.75f, 0.0f, 1.0f)
	
	#define CLEAR		CVec4f(1.00f, 1.00f, 1.00f, 0.00f)

--]]


-- Generic
styles_mainSwapAnimationDuration	= 500

styles_colors_whiteText				= '#f5f2e2'
styles_colors_gems					= '#c7daea'
styles_colors_hotkeyCanSet			= '#00CCFF'
styles_colors_hotkeyNoSet			= '#FFFFFF'
styles_colors_hotkeyDisabled		= '.6 .6 .6 1'

styles_colors_greenText				= '#22EE33'

styles_colors_relation_self			= '1 1 0'				
styles_colors_relation_ally			= '0 1 0'				
styles_colors_relation_enemy		= '1 0 0'				



styles_colors_stats					= {
	power			= '#ffc600',
	baseAttackSpeed	= '#fc0000',
	attackSpeed		= '#fc0000',
	armor			= '#da4733',
	magicArmor		= '#2f6ed7',
	mitigation		= '#da4733',
	resistance		= '#2f6ed7',
	healthMax		= '#ffff00',
	manaMax			= '#009afc',
	healthRegen		= '#ffff00',
	manaRegen		= '#009afc',
}

styles_colors_stats_empty			= '#555555'

-- Inventory

-- #404040
styles_inventoryStatusColorUnleveledR	= 0.25
styles_inventoryStatusColorUnleveledG	= 0.25
styles_inventoryStatusColorUnleveledB	= 0.25

-- #676045
styles_inventoryStatusColorDisabledR	= 0.4
styles_inventoryStatusColorDisabledG	= 0.376
styles_inventoryStatusColorDisabledB	= 0.27

-- #4444ff
styles_inventoryStatusNeedManaR	= 0.266
styles_inventoryStatusNeedManaG	= 0.266
styles_inventoryStatusNeedManaB	= 1

styles_itemsNarrowX = {
	libGeneral.HtoP(0.5),
	libGeneral.HtoP(7),
	libGeneral.HtoP(13.5),
	libGeneral.HtoP(0.5),
	libGeneral.HtoP(7),
	libGeneral.HtoP(13.5),
	libGeneral.HtoP(20),
}

styles_itemsNarrowY = {
	libGeneral.HtoP(-7),
	libGeneral.HtoP(-7),
	libGeneral.HtoP(-7),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
}

styles_itemsWideX = {
	libGeneral.HtoP(0.5),
	libGeneral.HtoP(7),
	libGeneral.HtoP(13.5),
	libGeneral.HtoP(20),
	libGeneral.HtoP(26.5),
	libGeneral.HtoP(33),
	libGeneral.HtoP(39.5),
}

styles_itemsWideY = {
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
	libGeneral.HtoP(-0.5),
}


-- Hall of Heroes
styles_hallOfHeroes_gameViewModelOrient	= '-25 0 5'

-- AltInfo

styles_altInfoHeroWidthReg			= libGeneral.HtoP(9.6)
styles_altInfoHeroHeightReg			= styles_altInfoHeroWidthReg * 0.25
styles_altInfoHeroWidthExpanded		= libGeneral.HtoP(16)
styles_altInfoHeroHeightExpanded	= styles_altInfoHeroWidthExpanded * 0.25

styles_altInfoSelfSizeModifier		= 1.4

styles_altInfoSelfWidthReg			= styles_altInfoHeroWidthReg * styles_altInfoSelfSizeModifier
styles_altInfoSelfHeightReg			= styles_altInfoSelfWidthReg * 0.25
styles_altInfoSelfWidthExpanded		= styles_altInfoHeroWidthExpanded * styles_altInfoSelfSizeModifier
styles_altInfoSelfHeightExpanded	= styles_altInfoSelfWidthExpanded * 0.25


styles_altInfoHeroHealthContainerHeightReg		= '45%'
styles_altInfoHeroHealthContainerHeightExpanded	= '45%'	-- '47%'
styles_altInfoHeroManaContainerHeightReg		= '36%'
styles_altInfoHeroManaContainerHeightExpanded	= '36%'

styles_altInfoHeroShoppingIconContainerYReg			= 0
styles_altInfoHeroShoppingIconContainerYInvOnly		= '-25@'
styles_altInfoHeroShoppingIconContainerYExpanded	= '-50@'

-- Skill Panel (level up panel)

styles_skillPanelEntryBacker			= '#191919'
styles_skillPanelEntryBackerOver		= '#212121'
styles_skillPanelEntryBackerDisabled	= '#0B0B0B'
styles_skillPanelEntryInset				= '#0B0B0B'
styles_skillPanelEntryInsetOver			= '#101010'
styles_skillPanelEntryInsetDisabled		= 'black'
styles_skillPanelEntryHeader			= '#333333'
styles_skillPanelEntryHeaderOver		= '#444444'
styles_skillPanelEntryHeaderDisabled	= '#222222'
-- styles_skillPanelEntryBorder			= '#555555'

styles_skillPanelEntryBBacker			= '#1a0b0f'
styles_skillPanelEntryBBackerOver		= '#2a1118'
styles_skillPanelEntryBBackerDisabled	= '#141414'
styles_skillPanelEntryBInset			= '#0b0507'
styles_skillPanelEntryBInsetOver		= '#14090d'
styles_skillPanelEntryBInsetDisabled	= '#060606'
styles_skillPanelEntryBHeader			= '#371720'
styles_skillPanelEntryBHeaderOver		= '#481b28'
styles_skillPanelEntryBHeaderDisabled	= '#252525'
-- styles_skillPanelEntryBBorder			= '#a2425d'

-- "More Info" Positions
styles_allyXExpanded		= libGeneral.HtoP(0)
styles_allyXNormal			= libGeneral.HtoP(-8)

styles_enemyXExpanded		= libGeneral.HtoP(0)
styles_enemyXNormal			= libGeneral.HtoP(8)

styles_heroXExpanded		= libGeneral.HtoP(0)
styles_heroXNormal			= libGeneral.HtoP(-8)

styles_heroHealthYNormal		= libGeneral.HtoP(4)
styles_heroHealthYExpanded		= 0
styles_heroHealthHeightOffset	= libGeneral.HtoP(3.5)

styles_heroManaYNormal			= libGeneral.HtoP(4)
styles_heroManaYExpanded		= 0
styles_heroManaHeightOffset		= libGeneral.HtoP(3.5)

styles_heroPrimariesBaseY		= libGeneral.HtoP(-1.5)
styles_heroSecondariesBaseY		= libGeneral.HtoP(-10.2)

styles_heroLevelUpButtonBaseY			= libGeneral.HtoP(-21)
styles_heroLevelUpButtonHeightOffset	= libGeneral.HtoP(9)

styles_teamYExpanded		= libGeneral.HtoP(1.25)
styles_teamYNormal			= libGeneral.HtoP(-7)

-- styles_levelPip					= '#333333'
styles_levelPipR				= 0.2
styles_levelPipG				= 0.2
styles_levelPipB				= 0.2

-- styles_levelPipMet				= '#FFCC00'
styles_levelPipMetR				= 1
styles_levelPipMetG				= 0.8
styles_levelPipMetB				= 0

-- styles_chargePip					= styles_levelPip
styles_chargePipR				= 0.75
styles_chargePipG				= 0.75
styles_chargePipB				= 0.75

-- styles_chargePipMet				= styles_levelPipMet
styles_chargePipMetR			= styles_levelPipMetR
styles_chargePipMetG			= styles_levelPipMetG
styles_chargePipMetB			= styles_levelPipMetB

-- styles_chargePipNeedMana			= '#00CCFF'
styles_chargePipNeedManaR		= 0
styles_chargePipNeedManaG		= 1
styles_chargePipNeedManaB		= 1

-- styles_abilityNeedMana			= '#0084ff'

styles_abilityNeedManaR			= 0
styles_abilityNeedManaG			= 0.517
styles_abilityNeedManaB			= 1

-- styles_abilityDisabled			= 'red'
styles_abilityDisabledR			= 1
styles_abilityDisabledG			= 0
styles_abilityDisabledB			= 0

-- styles_abilityisPassive			= 'green'	-- Darker green
styles_abilityisPassiveR		= 0
styles_abilityisPassiveG		= 0.5
styles_abilityisPassiveB		= 0

-- styles_abilityOnCooldown			= 'yellow'

styles_abilityOnCooldownR		= 1
styles_abilityOnCooldownG		= 1
styles_abilityOnCooldownB		= 0

-- styles_abilityReady				= 'lime'
styles_abilityReadyR			= 0
styles_abilityReadyG			= 1
styles_abilityReadyB			= 0

-- styles_abilityUnusable			= 'orange'	-- I believe this is for stuff that's in use/unavailable for misc reasons
styles_abilityUnusableR			= 1
styles_abilityUnusableG			= 0.65
styles_abilityUnusableB			= 0

-- styles_abilityUnleveled			= '0.75 0.75 0.5'
styles_abilityUnleveledR		= 0.75
styles_abilityUnleveledG		= 0.75
styles_abilityUnleveledB		= 0.5

styles_allyItemAbilityOffset	= '25@'

-- styles_vitalBarNoVisColor		= '#999999'
styles_vitalBarNoVisColorR		= 0.6
styles_vitalBarNoVisColorG		= 0.6
styles_vitalBarNoVisColorB		= 0.6

-- styles_healthBackerColor			= '#001d03'
styles_healthBackerColorR		= 0
styles_healthBackerColorG		= 0.113
styles_healthBackerColorB		= 0.012

styles_healthOtherTapColorR		= 0.75
styles_healthOtherTapColorG		= 0.75
styles_healthOtherTapColorB		= 0.75

styles_healthMyTapColorR		= 1
styles_healthMyTapColorG		= 0
styles_healthMyTapColorB		= 0

-- styles_healthBackerColorEnemy	= '#1d0100'
styles_healthBackerColorEnemyR	= 0.113
styles_healthBackerColorEnemyG	= 0.003
styles_healthBackerColorEnemyB	= 0

-- styles_healthBackerColorDisco	= '#0B0B0B'
styles_healthBackerColorDiscoR	= 0.043
styles_healthBackerColorDiscoG	= 0.043
styles_healthBackerColorDiscoB	= 0.043

-- styles_healthBackerOtherTapBG	= 
styles_healthBackerColorOtherTapR	= 0.188
styles_healthBackerColorOtherTapG	= 0
styles_healthBackerColorOtherTapB	= 0.227

-- styles_healthBackerColorDef		= '#0B0B0B'		-- Default charcoal (unknown/etc.)
styles_healthBackerColorDefR	= 0.043
styles_healthBackerColorDefG	= 0.043
styles_healthBackerColorDefB	= 0.043

-- styles_healthBackerColorNeutral	= '#30003a'
styles_healthBackerColorNeutralR	= 0.188
styles_healthBackerColorNeutralG	= 0
styles_healthBackerColorNeutralB	= 0.227

-- styles_healthBarColor			= '#22EE33'
styles_healthBarColorR			= 0.133
styles_healthBarColorG			= 0.933
styles_healthBarColorB			= 0.2

-- styles_healthBarColorEnemy		= '#ff381c'
styles_healthBarColorEnemyR		= 1
styles_healthBarColorEnemyG		= 0.219
styles_healthBarColorEnemyB		= 0.109

-- styles_healthBarColorNeutral	= '#d200ff'
styles_healthBarColorNeutralR	= 0.823
styles_healthBarColorNeutralG	= 0
styles_healthBarColorNeutralB	= 1

-- styles_healthBarColorDisco		= '#00CCFF'		-- Disconnected Players
styles_healthBarColorDiscoR		= 0
styles_healthBarColorDiscoG		= 0.8
styles_healthBarColorDiscoB		= 1

-- styles_manaBarColor				= '#00CCFF'
styles_manaBarColorR			= 0
styles_manaBarColorG			= 0.8
styles_manaBarColorB			= 1

-- styles_vitalBarNoVisColor		= '#999999'
styles_vitalBarNoVisColorR		= 0.6
styles_vitalBarNoVisColorG		= 0.6
styles_vitalBarNoVisColorB		= 0.6

-- styles_stateNeutral				= '#0044FF'
styles_stateNeutralR			= 0
styles_stateNeutralG			= 0.266
styles_stateNeutralB			= 1

-- styles_stateBuff				= 'lime'
styles_stateBuffR				= 0
styles_stateBuffG				= 1
styles_stateBuffB				= 0

-- styles_stateDebuff				= 'red'
styles_stateDebuffR				= 1
styles_stateDebuffG				= 0
styles_stateDebuffB				= 0

-- styles_glowAlly					= 'lime'
styles_glowAllyR				= 0
styles_glowAllyG				= 1
styles_glowAllyB				= 0

-- styles_glowEnemy					= 'red'
styles_glowEnemyR				= 1
styles_glowEnemyG				= 0
styles_glowEnemyB				= 0

-- styles_glowNeutral				= '#FF00FF'
styles_glowNeutralR				= 1
styles_glowNeutralG				= 0
styles_glowNeutralB				= 1

-- Chat Styles
styles_gameChatContainerX			= libGeneral.HtoP(56.0)
styles_gameChatContainerXShopOpen	= libGeneral.HtoP(56.0)

styles_gameChatContainerY			= '-16.0h'
styles_gameChatContainerY_expanded	= '-19.8h'
styles_gameChatContainerYShopOpen	= '-16.0h'

-- styles_chatMessageColorTeam			= '#00CCFF'
styles_chatMessageColorTeamR		= 1
styles_chatMessageColorTeamG		= 1
styles_chatMessageColorTeamB		= 1

-- styles_chatMessageColorAll			= 'white'
styles_chatMessageColorAllR			= 1
styles_chatMessageColorAllG			= 0.7
styles_chatMessageColorAllB			= 0.7

-- styles_chatMinDisplayTime		= 3000
styles_chatMaxDisplayTime			= 8500	-- 15000
styles_chatFadeTime					= 1000
-- styles_chatMaxCharsExpected		= 90

-- styles_chatNameColorSelf			= 'white'
styles_chatNameColorSelfR			= 1
styles_chatNameColorSelfG			= 1
styles_chatNameColorSelfB			= 0

-- styles_chatNameColorAlly			= '#22EE33'
styles_chatNameColorAllyR			= 0.133
styles_chatNameColorAllyG			= 0.933
styles_chatNameColorAllyB			= 0.2

-- styles_chatNameColorEnemy			= '#FF2211'
styles_chatNameColorEnemyR			= 1
styles_chatNameColorEnemyG			= 0.133
styles_chatNameColorEnemyB			= 0.066

-- styles_chatNameColorSpectator		= '#AAAAAA'
styles_chatNameColorSpectatorR		= 0.666
styles_chatNameColorSpectatorG		= 0.666
styles_chatNameColorSpectatorB		= 0.666

styles_chatItemPadding				= libGeneral.HtoP(0.35)
styles_chatIconSpectator			= '/ui/elements:icon_spectator'

-- Events

-- styles_eventAllyColor				= 'lime'
styles_eventAllyColorR				= 0
styles_eventAllyColorG				= 1
styles_eventAllyColorB				= 0

-- styles_eventEnemyColor				= 'red'
styles_eventEnemyColorR				= 1
styles_eventEnemyColorG				= 0
styles_eventEnemyColorB				= 0


-- Scoreboard

styles_scoreboardEntrySpace			= libGeneral.HtoP(5.5)	-- Height + padding, basically

-- Shop

styles_shopTransitionTime			= 150
styles_allyPositionShopOpen			= '51h'
styles_allyPositionShopClosed		= '1h'

styles_heroPositionShopOpen			= '51h'
styles_heroPositionShopClosed		= '1h'

styles_heroStatesPositionShopOpen	= libGeneral.HtoP(51)
styles_heroStatesPositionShopClosed	= libGeneral.HtoP(1)

styles_heroStatesYPositionBase		= libGeneral.HtoP(-9.8)

styles_selectedUnitAnimTime			= 150

styles_selectedStatePositionVisible	= '6.25h'
styles_selectedStatePositionHidden	= '-4h'

styles_gameTestButtonShopOpen		= libGeneral.HtoP(87.5)
styles_gameTestButtonShopClosed		= libGeneral.HtoP(51.5)

styles_gameMenuButtonShopOpen		= libGeneral.HtoP(78.5)
styles_gameMenuButtonShopClosed		= libGeneral.HtoP(28.5)

styles_shopButtonYPositionShopOpen		= libGeneral.HtoP(-9)
styles_shopButtonYPositionShopClosed	= libGeneral.HtoP(-0.5)

styles_shopButtonXPositionShopOpen		= libGeneral.HtoP(2)
styles_shopButtonXPositionShopClosed	= libGeneral.HtoP(0.5)

-- Misc centered around things moving out of each other's way
styles_uiSpaceShiftTime					= 150

-- Ability Tip

styles_abilityTipBaseY					= libGeneral.HtoP(-19.5)
-- styles_abilityTipLevelUpOffset		= libGeneral.HtoP(4)
styles_abilityTipChannelOffset			= libGeneral.HtoP(4.5)

-- Channel Bar

styles_channelBarBaseY					= libGeneral.HtoP(-19.5)
styles_channelBarLevelUpOffset			= libGeneral.HtoP(3)



-- Deal with changing health colors
styles_healthBarAllyColor		= nil
styles_healthBarEnemyColor		= nil
styles_healthBarSelfColor		= nil
styles_healthBarNeutralColor	= nil
--taps
styles_healthBarMyTapColor		= nil
--styles_healthBarEnemyTapColor	= nil --not using atm.
--lerps
styles_healthBarAllyLerpColor	= nil
styles_healthBarEnemyLerpColor	= nil
styles_healthBarSelfLerpColor	= nil
--backings
styles_healthBarAllyColorBack	= nil
styles_healthBarEnemyColorBack	= nil
styles_healthBarSelfColorBack	= nil
styles_healthBarNeutralColorBack	= nil
--names
styles_healthBarAllyNameColor	= nil
styles_healthBarEnemyNameColor	= nil
--towers etc
styles_healthBarAllyColor2		= nil
styles_healthBarEnemyColor2		= nil

local saturationForNonHeroes	= 0.133
local saturationForNames		= 0.8

local function updateHeroHealthColors()
	--load colors from cvars
	
	------ALLY
	styles_healthBarAllyColor = GetCvarString("cg_allyHealthColor", true)
	if not styles_healthBarAllyColor then
		styles_healthBarAllyColor = "0 1 0"
		SetSave("cg_allyHealthColor", styles_healthBarAllyColor, "string")
	end
	styles_healthBarAllyColor2 = libColors.saturateColor(styles_healthBarAllyColor, saturationForNonHeroes)
	styles_healthBarAllyColorBack = libColors.multiplyColor(styles_healthBarAllyColor2, 0.2)
	styles_healthBarAllyNameColor = libColors.saturateColor(styles_healthBarAllyColor, saturationForNames)
	
	------ENEMY
	styles_healthBarEnemyColor = GetCvarString("cg_enemyHealthColor", true)
	if not styles_healthBarEnemyColor then
		styles_healthBarEnemyColor = "1 0 0"
		SetSave("cg_enemyHealthColor", styles_healthBarEnemyColor, "string")
	end
	styles_healthBarEnemyColor2 = libColors.saturateColor(styles_healthBarEnemyColor, saturationForNonHeroes)
	styles_healthBarEnemyColorBack = libColors.multiplyColor(styles_healthBarEnemyColor2, 0.2)
	styles_healthBarEnemyNameColor = libColors.saturateColor(styles_healthBarEnemyColor, saturationForNames)
	styles_healthBarMyTapColor = styles_healthBarEnemyColor
	
	------SELF
	styles_healthBarSelfColor = GetCvarString("cg_selfHealthColor", true)
	if not styles_healthBarSelfColor then
		styles_healthBarSelfColor = "1 1 0"
		SetSave("cg_selfHealthColor", styles_healthBarSelfColor, "string")
	end
	styles_healthBarSelfColorBack = libColors.multiplyColor(libColors.saturateColor(styles_healthBarSelfColor, saturationForNonHeroes), 0.3)
	
	------NEUTRAL
	styles_healthBarNeutralColor = GetCvarString("cg_neutralHealthColor", true)
	if not styles_healthBarNeutralColor then
		styles_healthBarNeutralColor = "0.823 0 1"
		SetSave("cg_neutralHealthColor", styles_healthBarNeutralColor, "string")
	end
	styles_healthBarNeutralColorBack = libColors.multiplyColor(libColors.saturateColor(styles_healthBarNeutralColor, saturationForNonHeroes), 0.2)
	
	--lerps are calculated now. If lerps are still nil, we need to set them.
	styles_healthBarAllyLerpColor  = libColors.invertColor(styles_healthBarAllyColor)
	styles_healthBarEnemyLerpColor = libColors.invertColor(styles_healthBarEnemyColor)
	styles_healthBarSelfLerpColor  = libColors.invertColor(styles_healthBarSelfColor)
	
	local updateColorsTrigger = LuaTrigger.GetTrigger('updateHealthColors')
	if updateColorsTrigger then
		updateColorsTrigger:Trigger()
	end
end
updateHeroHealthColors()

styles_alwaysShowHeroLevel = false
styles_alwaysShowHeroNames = false
local function updateHeroNamePlates()
	styles_alwaysShowHeroLevel = GetCvarBool("_game_always_show_hero_levels_new", true) or false
	styles_alwaysShowHeroNames = GetCvarBool("_game_always_show_hero_names_new", true) or false
	
	local updateAltInfoHeroTrigger = LuaTrigger.GetTrigger('AltInfoHero')
	if updateAltInfoHeroTrigger then
		updateAltInfoHeroTrigger:Trigger()
	end
end
updateHeroNamePlates()

WatchLuaTrigger('optionsTrigger', function(widget, trigger)
	updateHeroHealthColors()
	updateHeroNamePlates()
end)
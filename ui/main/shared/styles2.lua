-- New Lua Styles

style_main_bgWheelSpinTime			= 240000

style_main_dropdownItem				= 'simpleDropdownItem'
style_crafting_costPerComponentPip	= 400
style_crafting_componentTypeIcons	= {
	power			= '/ui/shared/textures/itemtype_damage.tga',
	baseAttackSpeed		= '/ui/shared/textures/itemtype_damage.tga',
	health			= '/ui/shared/textures/itemtype_health.tga',
	maxHealth		= '/ui/shared/textures/itemtype_health.tga',
	hp				= '/ui/shared/textures/itemtype_health.tga',
	mana			= '/ui/shared/textures/itemtype_mana.tga',
	mp				= '/ui/shared/textures/itemtype_mana.tga',
	maxMana			= '/ui/shared/textures/itemtype_mana.tga',
	baseHealthRegen	= '/ui/shared/textures/itemtype_healthregen.tga',
	healthRegen		= '/ui/shared/textures/itemtype_healthregen.tga',
	hpregen			= '/ui/shared/textures/itemtype_healthregen.tga',
	manaRegen		= '/ui/shared/textures/itemtype_manaregen.tga',
	mpregen			= '/ui/shared/textures/itemtype_manaregen.tga',
	baseManaRegen	= '/ui/shared/textures/itemtype_manaregen.tga',
	armor			= '/ui/main/shared/textures/herorole_survival.tga',
	magicArmor		= '/ui/main/shared/textures/herorole_survival.tga',	
}

style_crafting_componentTypeColors	= {
	power			= '#FFDD33',
	baseAttackSpeed		= '#FFDD33',
	health			= '#ff391c',
	hp				= '#ff391c',
	maxHealth		= '#ff391c',
	mana			= '#1c71ff',
	mp				= '#1c71ff',
	maxMana			= '#1c71ff',
	healthRegen		= '#f07b6a',
	baseHealthRegen	= '#f07b6a',
	hpregen			= '#f07b6a',
	manaRegen		= '#00CCFF',
	baseManaRegen	= '#00CCFF',
	mpregen			= '#00CCFF',
	armor			= '#FFFFFF',
	magicArmor		= '#00FFFF',
}

style_crafting_tier_common_color		= '#3fd149'	-- '#ff391c'
style_crafting_tier_rare_color			= '#089cd9'
style_crafting_tier_legendary_color		= '#b712d6'

style_item_emptySlot	= '/ui/shared/textures/pack3.tga'
style_crafting_componentTypeColorEmpty	= '0 0 0 0.5'
style_crafting_componentTypeIconEmpty	= '/ui/shared/textures/itemtype_crafted.tga'

style_endMatch_commodityNames	= {	-- Must be in this order
	Translate('crafting_ore_singular'),
	Translate('crafting_essences_singular'),
	Translate('corral_petfood_singular'),
	Translate('corral_habitatcurrency_singular'),
	Translate('currency_gems_singular')
}

style_endMatch_commodityIcons	= {	-- Must be in this order
	'/ui/main/shared/textures/commodity_essence.tga',
	'/ui/main/shared/textures/commodity_essence.tga',
	'/ui/main/shared/textures/commodity_seal.tga',
	'/ui/main/shared/textures/commodity_seal.tga',
	'/ui/main/shared/textures/gem.tga'
}

style_crafting_componentEmptyAddIcon	= '/ui/main/crafting/textures/component_blank.tga'

style_gearDyeColors = {	-- These should be considered to be temp - later on they should be moved into .entity, .material, etc. files
	Hero_Flintbeastwood	= '#1761dc',
	Hero_Assassin		= '#1761dc',
	blue				= '#1761dc',
	violet				= '#a717dc',
	green				= '#32cb2a',
	teal				= '#26c5dd',
	pink				= '#dc33a6',
	red					= '#f02525',
	orange				= '#d67f22',
	yellow				= '#ebe53d',
	gray				= '#c7c7c7',
	black				= '#242424',
	irish				= '#1fa015',
	redwhiteblue		= '#bad7e9',
	gold				= '#FFCC00'
}

-- Sound styles (use these instead of a sound path for common sounds)
style_sound_sampleSoundType		= '/soundpath/file.wav'
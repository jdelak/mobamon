-- Gold Report
function goldReportRegister(object)
	local container		= object:GetWidget('tipGoldReport')
	local kills			= object:GetWidget('tipGoldReportKills')
	local deaths		= object:GetWidget('tipGoldReportDeaths')
	local assists		= object:GetWidget('tipGoldReportAssists')
	local creepKills	= object:GetWidget('tipGoldReportCreepKills')
	local goldKills		= object:GetWidget('tipGoldReportGoldKills')
	local goldAssists	= object:GetWidget('tipGoldReportGoldAssists')
	local goldCreeps	= object:GetWidget('tipGoldReportGoldCreeps')
	local goldBuildings	= object:GetWidget('tipGoldReportGoldBuildings')

	local function widgetsRegister()
		kills:RegisterWatchLua('PlayerScore', function(widget, trigger) widget:SetText(math.floor(trigger.heroKills)) end, true, nil, 'heroKills')
		deaths:RegisterWatchLua('PlayerScore', function(widget, trigger) widget:SetText(math.floor(trigger.deaths)) end, true, nil, 'deaths')
		assists:RegisterWatchLua('PlayerScore', function(widget, trigger) widget:SetText(math.floor(trigger.assists)) end, true, nil, 'assists')
		creepKills:RegisterWatchLua('PlayerScore', function(widget, trigger) widget:SetText(math.floor(trigger.creepKills)) end, true, nil, 'creepKills')
		goldKills:RegisterWatchLua('GoldReport', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger.killGold)) end, true, nil, 'killGold')
		goldAssists:RegisterWatchLua('GoldReport', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger.assistGold)) end, true, nil, 'assistGold')
		goldCreeps:RegisterWatchLua('GoldReport', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger.creepGold)) end, true, nil, 'creepGold')
		goldBuildings:RegisterWatchLua('GoldReport', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger.buildingGold)) end, true, nil, 'buildingGold')
	end

	local function widgetsUnregister()
		kills:UnregisterWatchLua('PlayerScore')
		deaths:UnregisterWatchLua('PlayerScore')
		assists:UnregisterWatchLua('PlayerScore')
		creepKills:UnregisterWatchLua('PlayerScore')
		goldKills:UnregisterWatchLua('GoldReport')
		goldAssists:UnregisterWatchLua('GoldReport')
		goldCreeps:UnregisterWatchLua('GoldReport')
		goldBuildings:UnregisterWatchLua('GoldReport')
	end

	container:RegisterWatch('goldReportVis', function(widget, showGoldReport)
		if AtoB(showGoldReport) then
			local goldReport	= LuaTrigger.GetTrigger('GoldReport')
			local playerScore	= LuaTrigger.GetTrigger('PlayerScore')
			widgetsRegister()
			container:SetVisible(true)
			goldReport:Trigger()
			playerScore:Trigger()
		else
			widgetsUnregister()
			container:SetVisible(false)
		end
	end)
end

goldReportRegister(object)
local progressBar = object:GetWidget('loadingProgressBar')

progressBar:RegisterWatchLua(
	'LoadingProgress', function(widget, trigger)
		widget:SetValue(trigger.loadPercent)
	end
)
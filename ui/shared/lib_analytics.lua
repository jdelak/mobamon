
local function analyticsRegister(object)

	mainUI									= mainUI									or {}
	mainUI.Analytics						= mainUI.Analytics							or {}
	
	mainUI.savedLocally 					= mainUI.savedLocally 						or {}	
	mainUI.savedLocally.currentFeature 		= mainUI.savedLocally.currentFeature 		or 'nofeature1'		
	
	mainUI.savedRemotely 					= mainUI.savedRemotely 						or {}	
	mainUI.savedRemotely.analytics 			= mainUI.savedRemotely.analytics 			or {}		
	
	function mainUI.Analytics.AddFeatureStartInstance(featureName)
		mainUI.savedLocally.currentFeature							= featureName 													or 'nofeature2'
		mainUI.savedRemotely.analytics 								= mainUI.savedRemotely.analytics 								or {}
		mainUI.savedRemotely.analytics[featureName]					= mainUI.savedRemotely.analytics[featureName] 					or {}
		mainUI.savedRemotely.analytics[featureName].startCount		= mainUI.savedRemotely.analytics[featureName].startCount 		or 0
		mainUI.savedRemotely.analytics[featureName].startCount		= mainUI.savedRemotely.analytics[featureName].startCount 		+ 1
		SaveState()
	end	
	
	function mainUI.Analytics.AddFeatureFinishInstance(featureName)
		local featureName 											= featureName 													or mainUI.savedLocally.currentFeature or 'nofeature3'
		mainUI.savedRemotely.analytics 								= mainUI.savedRemotely.analytics 								or {}
		mainUI.savedRemotely.analytics[featureName]					= mainUI.savedRemotely.analytics[featureName] 					or {}
		mainUI.savedRemotely.analytics[featureName].finishCount		= mainUI.savedRemotely.analytics[featureName].finishCount 		or 0
		mainUI.savedRemotely.analytics[featureName].finishCount		= mainUI.savedRemotely.analytics[featureName].finishCount 		+ 1
		SaveState()	
	end	

end

analyticsRegister(object)
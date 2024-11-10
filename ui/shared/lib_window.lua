-- Simple Window management library

libWindow = {
	init = function(container, body, minimizeButton, closeButton, resizeHandle, titleBar, minWidth, minHeight, startMinimized, noResize, heightSnap, heightSnapOffset, widthAdjust, heightAdjust)
		local containerX = container:GetX()
		local containerY = container:GetY()
		heightSnapOffset = heightSnapOffset or 0
		container:SetCallback('onclick', function(sourceWidget) sourceWidget:BringToFront() end)

		container:SetWidth(math.max(container:GetWidth(), minWidth))
		container:SetHeight(math.max(container:GetHeight(), minHeight))
		container:SetX(containerX)
		container:SetY(containerY)

		local minimizeWindow = function()
			local containerX = container:GetX()
			local containerY = container:GetY()
			body:SetVisible(not body:IsVisibleSelf())
			if body:IsVisibleSelf() then
				container:SetHeight( math.max(resizeHandle:GetY() + (resizeHandle:GetHeight() * 0.5), minHeight) )
			else
				container:SetHeight(titleBar:GetHeight())
			end

			resizeHandle:SetVisible(body:IsVisibleSelf() and not noResize)
			resizeHandle:SetX(container:GetWidth() - (resizeHandle:GetWidth() * 0.5))
			resizeHandle:SetY(container:GetHeight() - (resizeHandle:GetHeight() * 0.5))

			container:SetX(containerX)
			container:SetY(containerY)
			if body:IsVisibleSelf() then
				libGeneral.resizeToTarget(container, resizeHandle, minWidth, minHeight)
			end
		end

		minimizeButton:SetCallback('onclick', minimizeWindow)

		if startMinimized then minimizeWindow() end

		closeButton:SetCallback(
			'onclick', function(sourceWidget)
				container:SetVisible(false)
			end
		)

		resizeHandle:SetVisible(not noResize)

		if not noResize then
			resizeHandle:SetX(container:GetWidth() - (resizeHandle:GetWidth() * 0.5))
			resizeHandle:SetY(container:GetHeight() - (resizeHandle:GetHeight() * 0.5))

			resizeHandle:SetCallback(
				'onstartdrag', function(sourceWidget)
					resizeHandle:RegisterWatchLua(
						'System', function(sourceWidget, trigger)
							local resizeMinHeight = minHeight
							if not body:IsVisibleSelf() then
								resizeMinHeight = titleBar:GetHeight() - libGeneral.HtoP(0.5)
							end
							libGeneral.resizeToTarget(container, resizeHandle, minWidth, resizeMinHeight, widthAdjust, heightAdjust)
						end, false, nil, 'hostTime')
					container:BringToFront()
				end
			)

			resizeHandle:SetCallback(
				'onenddrag', function(sourceWidget)
					local containerX = container:GetX()
					local containerY = container:GetY()
					resizeHandle:UnregisterWatchLua('System')
					if heightSnap > 0 then
						container:SetHeight(libGeneral.findNearestSnap(container:GetHeight(), heightSnap) + heightSnapOffset)
						container:SetX(containerX)
						container:SetY(containerY)
						resizeHandle:SetX(container:GetWidth() - (resizeHandle:GetWidth() * 0.5))
						resizeHandle:SetY(container:GetHeight() - (resizeHandle:GetHeight() * 0.5))
					end
				end
			)

			resizeHandle:SetCallback(
				'onhide', function(sourceWidget)
					sourceWidget:UICmd("BreakDrag()")
				end
			)
		end
	end
}
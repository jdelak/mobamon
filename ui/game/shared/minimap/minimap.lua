-- Minimap

 function mapClickPos(rightClick, sourceWidget, xPos, yPos)
 	local clickCmd = 'MinimapClick'
 	if rightClick then
 		clickCmd = 'MinimapRightClick'
 	end
 	if AtoB(sourceWidget:UICmd(clickCmd..'('..xPos..', '..yPos..')')) then
 		sourceWidget:BreakDrag()
 	end
 end
 
function registerMinimap(object)
	local minimap		= object:GetWidget('gameMinimap')
	
	minimap:SetCallback( 'onclick', function(...) mapClickPos(false, ...) end )
	minimap:SetCallback( 'onrightclick', function(...) mapClickPos(true, ...) end )
end

registerMinimap(object)
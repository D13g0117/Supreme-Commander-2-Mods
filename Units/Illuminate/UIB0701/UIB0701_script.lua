-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0701/uib0701_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Mass Extractor: UIB0701
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MassCollectionUnit = import('/lua/sim/MassCollectionUnit.lua').MassCollectionUnit

UIB0701 = Class(MassCollectionUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
		MassCollectionUnit.OnStopBeingBuilt(self,builder,layer)
		self:AddManualScrollerU(1, -0.05)
	end,

    OnKilled = function(self, instigator, type, overkillRatio)
		if self.AnimationManipulator then
			self.AnimationManipulator:Destroy()
		end
        MassCollectionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}
TypeClass = UIB0701
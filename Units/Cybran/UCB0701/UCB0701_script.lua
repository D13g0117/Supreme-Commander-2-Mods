-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0701/ucb0701_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Cybran Mass Extractor UCB0701
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MassCollectionUnit = import('/lua/sim/MassCollectionUnit.lua').MassCollectionUnit

UCB0701 = Class(MassCollectionUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
		MassCollectionUnit.OnStopBeingBuilt(self,builder,layer)
		self:AddManualScrollerU(1, -0.05)
		self.Trash:Add( CreateRotator(self, 'Turbine01', 'y', nil, 0, -20, -20) )
        self.Trash:Add( CreateRotator(self, 'Turbine02', 'y', nil, 0, 20, 20) )
		self.Trash:Add( CreateRotator(self, 'Turbine03', 'y', nil, 0, -20, -20) )
        self.Trash:Add( CreateRotator(self, 'Turbine04', 'y', nil, 0, 20, 20) )
	end,
}
TypeClass = UCB0701
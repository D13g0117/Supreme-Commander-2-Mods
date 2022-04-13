-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uib0902/uib0902_script.lua
--  Author(s): 	Gordon Duclos
--  Summary  :  SC2 Illuminate Transport Beacon: UIB0902
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UCB0903 = Class(StructureUnit) {
    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self, builder, layer)
		self:SetDoNotTarget(true)
		self:SetCanTakeDamage(false)
		self.IgnoreDamage = true
    end,
}
TypeClass = UCB0903
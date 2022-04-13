-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb9998/scb9998.lua
--  Author(s):	Brian Fricks
--  Summary  :  LARGE O-GRID BLOCKER: SCB9998
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB9998 = Class(StructureUnit) {

	OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self:SetCanTakeDamage(false)
        self:SetCanBeKilled(false)
	end,
}
TypeClass = SCB9998
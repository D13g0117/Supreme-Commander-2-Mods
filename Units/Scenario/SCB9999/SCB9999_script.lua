-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb9999/scb9999.lua
--  Author(s):	Brian Fricks
--  Summary  :  O-GRID BLOCKER: SCB9999
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB9999 = Class(StructureUnit) {

	OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self:SetCanTakeDamage(false)
        self:SetCanBeKilled(false)
	end,
}
TypeClass = SCB9999
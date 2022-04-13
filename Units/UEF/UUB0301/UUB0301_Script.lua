-----------------------------------------------------------------------------
--  File     : /units/uef/uub0301/uub0301_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Radar Station: UUB0301
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UUB0301 = Class(StructureUnit) {
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)

		self.Trash:Add(CreateRotator(self, 'Radar01', 'y', nil, 0, 10, -10))		
		self.Trash:Add(CreateRotator(self, 'Radar02', 'y', nil, 0, 10, 60))
		self.Trash:Add(CreateRotator(self, 'Radar03', 'y', nil, 0, 10, -20))
	end,
}
TypeClass = UUB0301
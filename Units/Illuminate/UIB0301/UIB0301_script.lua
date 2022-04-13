-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0301/uib0301_script.lua
--  Author(s):
--  Summary  : SC2 Illuminate Radar System: UIB0301
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UIB0301 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.Trash:Add( CreateRotator(self, 'Vane01', 'y', nil, 0, 50, 20) )
		self.Trash:Add( CreateRotator(self, 'Vane02', 'y', nil, 0, 40, -30) )
		self.Trash:Add( CreateRotator(self, 'Vane03', 'y', nil, 0, 150, 40) )
    end,
}
TypeClass = UIB0301
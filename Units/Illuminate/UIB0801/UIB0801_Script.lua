-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uib0801/uib0801_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Research Station: UIB0801
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local ResearchUnit = import('/lua/sim/ResearchUnit.lua').ResearchUnit

UIB0801 = Class(ResearchUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
		ResearchUnit.OnStopBeingBuilt(self,builder,layer)
        self.Spinners = {
            Spinner1 = CreateRotator(self, 'UIB0801_ring_01', 'z', nil, 0, 60, 360):SetTargetSpeed(50),
            Spinner2 = CreateRotator(self, 'UIB0801_ring_02', 'z', nil, 0, 30, 360):SetTargetSpeed(50),
        }
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )
	end,
	
}
TypeClass = UIB0801
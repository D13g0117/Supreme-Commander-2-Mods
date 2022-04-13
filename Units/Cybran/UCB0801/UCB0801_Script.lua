-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucb0801/ucb0801_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Research Station: UCB0801
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local ResearchUnit = import('/lua/sim/ResearchUnit.lua').ResearchUnit

UCB0801 = Class(ResearchUnit) {
    OnCreate = function(self, createArgs)
		ResearchUnit.OnCreate(self, createArgs)
		
		self.Spinners = {
			Spinner01 = CreateRotator(self, 'Radar03', 'y', nil, 0, 60, 360):SetTargetSpeed(30),
			Spinner02 = CreateRotator(self, 'Radar02', 'y', nil, 0, 60, 360):SetTargetSpeed(-40),
		}
		self.Trash:Add(self.Spinner)
	end,
}
TypeClass = UCB0801
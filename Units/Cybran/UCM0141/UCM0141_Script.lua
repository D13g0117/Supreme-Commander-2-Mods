-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucm0111/ucm0141_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Point Defense Upgrade: UCM0141
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCM0141 = Class(StructureUnit) {
    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {}
    },
	
	OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)
	end,
}
TypeClass = UCM0141
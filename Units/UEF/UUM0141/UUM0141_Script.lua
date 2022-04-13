-----------------------------------------------------------------------------
--  File     :  /units/uef/uum0111/uum0141_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Point Defense Upgrade: UUM0141
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUM0141 = Class(StructureUnit) {
    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {}
    },
	
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)
	end,
}
TypeClass = UUM0141
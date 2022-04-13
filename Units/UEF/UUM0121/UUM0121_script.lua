-----------------------------------------------------------------------------
--  File     :  /units/uef/uum0121/uum0121_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Anti-Air Upgrade: UUM0121
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUM0121 = Class(StructureUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
    },
	
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)
	end,

}
TypeClass = UUM0121
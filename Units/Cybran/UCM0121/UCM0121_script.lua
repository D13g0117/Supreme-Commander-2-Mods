-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucm0121/ucm0121_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran AA Railgun Upgrade: UCM0121
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCM0121 = Class(StructureUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
    },
	
	OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)
	end,

}
TypeClass = UCM0121
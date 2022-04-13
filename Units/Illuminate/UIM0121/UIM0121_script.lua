-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uim0121/uim0121_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate AA Railgun Upgrade: UIM0121
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIM0121 = Class(StructureUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
    },
	
	OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)
	end,
}
TypeClass = UIM0121
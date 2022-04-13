-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uim0141/uim0141_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Point Defense Upgrade: UIM0141
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIM0141 = Class(StructureUnit) {
    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {}
    },
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)

		self.Spinners = {
			Spinner01 = CreateRotator(self, 'UIM0141', 'y', nil, 0, 50, 360):SetTargetSpeed(30),
			Spinner02 = CreateRotator(self, 'Vane02', 'z', nil, 0, 40, 360):SetTargetSpeed(-60),
		}
		self.Trash:Add(self.Spinner)
	end,
}
TypeClass = UIM0141
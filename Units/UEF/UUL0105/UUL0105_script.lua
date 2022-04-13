-----------------------------------------------------------------------------
--  File     :  /units/uef/uul0105/uul0105_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Mobile Anti-Air Gun: UUL0105
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUL0105 = Class(MobileUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        Turret02 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UUL0105
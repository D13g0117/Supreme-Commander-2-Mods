-----------------------------------------------------------------------------
--  File     :  /units/uef/uul0104/uul0104_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Mobile Missile Launcher: UUL0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon


UUL0104 = Class(MobileUnit) {
    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {},
        MissileRack01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UUL0104
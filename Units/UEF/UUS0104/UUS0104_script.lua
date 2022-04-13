-----------------------------------------------------------------------------
--  File     :  /units/uef/uus0104/uus0104_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Attack Submarine: UUS0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUS0104 = Class(SeaUnit) {

    Weapons = {
        Torpedo01 = Class(DefaultProjectileWeapon) {},
        PlasmaGun = Class(DefaultProjectileWeapon) {}
    },
}
TypeClass = UUS0104
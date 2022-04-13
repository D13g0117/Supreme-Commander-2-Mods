-----------------------------------------------------------------------------
--  File     : /units/uef/uub0101/uub0101_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF UUB0101 Point Defense 
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0101 = Class(StructureUnit) {
    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {}
    },
}
TypeClass = UUB0101
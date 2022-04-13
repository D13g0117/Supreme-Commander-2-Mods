-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucb0101/ucb0101_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Point Defense Tower: UCB0101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCB0101 = Class(StructureUnit) {
    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {},
    },

}

TypeClass = UCB0101
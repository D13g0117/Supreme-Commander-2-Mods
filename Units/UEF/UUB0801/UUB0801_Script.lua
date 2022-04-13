-----------------------------------------------------------------------------
--  File     :  /units/uef/uub0801/uub0801_script.lua
--  Author(s):	Gordon Duclos, Brian Fricks, Aaron Lundquist
--  Summary  :  SC2 UEF Research Station: UUB0801
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ResearchUnit = import('/lua/sim/ResearchUnit.lua').ResearchUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0801 = Class(ResearchUnit) {
    Weapons = {
        PointDefense01 = Class(DefaultProjectileWeapon) {},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UUB0801
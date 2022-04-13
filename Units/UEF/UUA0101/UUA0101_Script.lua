-----------------------------------------------------------------------------
--  File     :  /units/uef/uua0101/uua0101_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Fighter: UUA0101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUA0101 = Class(AirUnit) {

    BeamExhaustCruise = {'/effects/emitters/units/uef/general/gunship_thruster_beam_01_emit.bp'},
    BeamExhaustIdle = {'/effects/emitters/units/uef/general/gunship_thruster_beam_02_emit.bp'},
    
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UUA0101
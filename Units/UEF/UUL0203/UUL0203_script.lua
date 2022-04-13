-----------------------------------------------------------------------------
--  File     : /units/uef/uul0203/uul0203_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Mobile Anti-Missile Defense: UUL0203
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUL0203 = Class(MobileUnit) {

    Weapons = {
        AntiMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam02,
		},
    },
}
TypeClass = UUL0203
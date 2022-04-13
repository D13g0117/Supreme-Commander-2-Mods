-----------------------------------------------------------------------------
--  File     : /units/uef/uus0102/uus0102_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Cruiser: UUS0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUS0102 = Class(SeaUnit) {
    DestructionTicks = 200,

    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {},
		FrontTurret01 = Class(DefaultProjectileWeapon) {},
        FrontTurret02 = Class(DefaultProjectileWeapon) {},
        BackTurret02 = Class(DefaultProjectileWeapon) {},
        BackTurret03 = Class(DefaultProjectileWeapon) {},
        PhalanxGun01 = Class(DefaultProjectileWeapon) {},
        AntiMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam02,
		},
    },
}
TypeClass = UUS0102
-----------------------------------------------------------------------------
--  File     : /units/uef/uus0105/uus0105_script.lua
--  Author(s): Julie Brockett & Gordon Duclos
--  Summary  : SC2 UEF Battleship: UUS0105
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUS0105 = Class(SeaUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
        AntiAir03 = Class(DefaultProjectileWeapon) {},
        AntiAir04 = Class(DefaultProjectileWeapon) {},

        FrontTurret01 = Class(DefaultProjectileWeapon) {},
        FrontTurret02 = Class(DefaultProjectileWeapon) {},
        FrontTurret03 = Class(DefaultProjectileWeapon) {},
        FrontTurret04 = Class(DefaultProjectileWeapon) {},
        BackTurret01 = Class(DefaultProjectileWeapon) {},
        BackTurret02 = Class(DefaultProjectileWeapon) {},

        AntiMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam,
		},
    },
}
TypeClass = UUS0105
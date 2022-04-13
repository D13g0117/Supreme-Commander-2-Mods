-----------------------------------------------------------------------------
--  File     :  /units/uef/uul0103/uul0103_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 UEF Assault Bot: UUL0103
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUL0103 = Class(MobileUnit) {
	DestructionExplosionWaitDelayMin = 0.5,
	DestructionExplosionWaitDelayMax = 0.5,
	
    Weapons = {
        Gauss01 = Class(DefaultProjectileWeapon) {},
        Gauss02 = Class(DefaultProjectileWeapon) {},
        MissileRack01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UUL0103
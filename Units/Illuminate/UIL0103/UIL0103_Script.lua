-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uil0103/uil0103_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Assault Bot: UIL0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIL0103 = Class(MobileUnit) {
	DestructionExplosionWaitDelayMin = 0.5,
	DestructionExplosionWaitDelayMax = 0.5,
	
    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {},
        AAGun01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UIL0103
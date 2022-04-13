-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uil0104/uil0104_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Mobile Missile Launcher: UIL0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local HoverUnit = import('/lua/sim/HoverUnit.lua').HoverUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIL0104 = Class(HoverUnit) {
    Weapons = {
        MissileRack = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UIL0104
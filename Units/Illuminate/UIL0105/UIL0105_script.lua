-----------------------------------------------------------------------------
--  File     : /units/illuminate/uil0105/uil0105_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Mobile Anti-Air Gun: UIL0105
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local HoverUnit = import('/lua/sim/HoverUnit.lua').HoverUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIL0105 = Class(HoverUnit) {
    Weapons = {
        AAGun01 = Class(DefaultProjectileWeapon) {},
        AAGun02 = Class(DefaultProjectileWeapon) {},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        HoverUnit.OnStopBeingBuilt(self,builder,layer)
        
        local sx, sy, sz = self:GetUnitSizes() 
        self.volume = (sx * sz)*2
    end, 
}
TypeClass = UIL0105
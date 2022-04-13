-----------------------------------------------------------------------------
--  File     :  /units/uef/uul0102/uul0102_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Mobile Artillery: UUL0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon


local function PassData(self, proj)
    local data = {
        Radius = self:GetBlueprint().CameraVisionRadius or 5,
        Lifetime = self:GetBlueprint().CameraLifetime or 5,
        Army = self.unit:GetArmy(),
    }
    if proj and not proj:BeenDestroyed() then
        proj:PassData(data)
    end
end

local MainGun = Class(DefaultProjectileWeapon) {
    CreateProjectileAtMuzzle = function(self, muzzle)
		PassData( self, DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle) )

		-- Base dust effects when unit fires
        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Land.UUL0102.BaseLaunch01 )
    end,
}

UUL0102 = Class(MobileUnit) {
    Weapons = {
        MainGun = Class(MainGun) { },
		MainGunLongBarrel = Class(MainGun) {},
		MainGunDoubleBarrel = Class(MainGun) {},
        MissileRack01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UUL0102
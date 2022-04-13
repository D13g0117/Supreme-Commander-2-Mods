-----------------------------------------------------------------------------
--  File     : /units/uef/uub0104/uub0104_script.lua
--  Author(s): Gordon Duclos, Eric Williamson, Aaron Lundquist
--  Summary  : SC2 UEF Fortified Artillery Structure: UUB0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0104 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
        local bp = self:GetBlueprint()
        if bp.Audio.Activate then
            self:PlaySound(bp.Audio.Activate)
        end
    end,

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Base.UUB0104.BaseLaunch01 )
            end,
        },
        HardenedArtillery = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Base.UUB0104.BaseLaunch01 )
            end,
        },
    },

	OnHardenArtillery = function( self, abilityBP, state )
		if state == 'activate' then
			self:SetWeaponEnabledByLabel('MainGun', false)
			self:SetWeaponEnabledByLabel('HardenedArtillery', true)

			local MainGunAim = self:GetWeapon('MainGun'):GetAimManipulator()
			local HardenedArtilleryAim = self:GetWeapon('HardenedArtillery'):GetAimManipulator()
			MainGunAim:SetPrecedence(0)
			HardenedArtilleryAim:SetPrecedence(10):SetHeadingPitch(MainGunAim:GetHeadingPitch())
		else
			self:SetWeaponEnabledByLabel('MainGun', true)
			self:SetWeaponEnabledByLabel('HardenedArtillery', false)

			local MainGunAim = self:GetWeapon('MainGun'):GetAimManipulator()
			local HardenedArtilleryAim = self:GetWeapon('HardenedArtillery'):GetAimManipulator()
			HardenedArtilleryAim:SetPrecedence(0)
			MainGunAim:SetPrecedence(10):SetHeadingPitch(HardenedArtilleryAim:GetHeadingPitch())
		end
	end,
}
TypeClass = UUB0104
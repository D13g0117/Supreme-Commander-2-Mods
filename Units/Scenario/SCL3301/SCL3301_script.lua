-----------------------------------------------------------------------------
--  File     :  /units/scenario/scl3301/scl3301_script.lua
--  Author(s):  Chris Daroza
--  Summary  :  SC2 Dinosaur: SCL3301
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/Utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat

SCL3301 = Class(ExperimentalMobileUnit) {
    Weapons = {
		FlameThrower01 = Class(DefaultProjectileWeapon) {},
    },

    DeathThread = function(self)

        local army = self:GetArmy()

        -- Create Initial explosion effects
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death01 do
			CreateAttachedEmitter ( self, 'UCX0111_Root', self:GetArmy(), v ):ScaleEmitter( 2 )
		end

        WaitSeconds( 1.0 )

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death01 do
			CreateAttachedEmitter ( self, 'UCX0111_Head', self:GetArmy(), v )
		end

		WaitSeconds( 3.4 )

		self:PlayUnitSound('Destroyed')

        -- When the unit impacts with the ground
        -- Other: Damage force ring to force trees over and camera shake
        self:ShakeCamera(20, 4, 1, 2.0)

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter( 2 )
		end

		WaitSeconds( 0.5 )

		local bp = self:GetBlueprint()
		local scale = (bp.SizeX + bp.SizeZ) * 2


		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy())

        local bp = self:GetBlueprint()
        for i, numWeapons in bp.Weapons do
            if(bp.Weapons[i].Label == 'MegalithDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapons[i].DamageRadius, bp.Weapons[i].Damage, bp.Weapons[i].DamageType, bp.Weapons[i].DamageFriendly)
                break
            end
        end

        self:CreateWreckage()
        self:ShakeCamera(2, 1, 0, 0.05)

		WaitSeconds( 0.5 )
        self:Destroy()
    end,
}
TypeClass = SCL3301
-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0111/ucx0111_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Experimental Lizardbot: UCX0111
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/Utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat

UCX0111 = Class(ExperimentalMobileUnit) {
    Weapons = {
		FlameThrower01 = Class(DefaultProjectileWeapon) {},
        FragMissile01 = Class(DefaultProjectileWeapon) {

			OnCreate = function(self)
				DefaultProjectileWeapon.OnCreate(self)
			end,

			CreateProjectileForWeapon = function(self, bone)
				local proj = DefaultProjectileWeapon.CreateProjectileForWeapon( self, bone )

				if bone == 'UCX0111_RightMissile02' then
					proj:SetSequencingId(1)
					proj:SetSide('Right')
				elseif bone == 'UCX0111_RightMissile03' then
					proj:SetSequencingId(2)
					proj:SetSide('Right')
				elseif bone == 'UCX0111_RightMissile04' then
					proj:SetSequencingId(3)
					proj:SetSide('Right')
				elseif bone == 'UCX0111_LeftMissile02' then
					proj:SetSequencingId(1)
					proj:SetSide('Left')
				elseif bone == 'UCX0111_LeftMissile03' then
					proj:SetSequencingId(2)
					proj:SetSide('Left')
				elseif bone == 'UCX0111_LeftMissile04' then
					proj:SetSequencingId(3)
					proj:SetSide('Left')
				end

				return proj
			end,
   		},
        TacticalMissile01 = Class(DefaultProjectileWeapon) {},
        TacticalMissile02 = Class(DefaultProjectileWeapon) {},
    },

    DeathThread = function(self)
		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end


        local army = self:GetArmy()

        -- Create Initial explosion effects
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death01 do
			CreateAttachedEmitter ( self, 'UCX0111_Root', self:GetArmy(), v ):ScaleEmitter( 2 )
		end

        WaitSeconds( 1.0 )

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death01 do
			CreateAttachedEmitter ( self, 'UCX0111_Head', self:GetArmy(), v )
		end

		WaitSeconds( 2.0 )

        -- When the unit impacts with the ground
        -- Other: Damage force ring to force trees over and camera shake
        self:PlayUnitSound('Destroyed')
        self:ShakeCamera(20, 4, 1, 2.0)

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter( 2 )
		end

		WaitSeconds( 0.4 )

		local bp = self:GetBlueprint()
		local scale = (bp.SizeX + bp.SizeZ) * 2
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 5 )

        local bp = self:GetBlueprint()
        for i, numWeapons in bp.Weapons do
            if(bp.Weapons[i].Label == 'MegalithDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapons[i].DamageRadius, bp.Weapons[i].Damage, bp.Weapons[i].DamageType, bp.Weapons[i].DamageFriendly)
                break
            end
        end

        self:CreateWreckage()
        self:ShakeCamera(2, 1, 0, 0.05)

        self:Destroy()
    end,
}
TypeClass = UCX0111
-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0101/ucx0101_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UCX0101: Cybran Megalith
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/Utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local MegalithCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').MegalithCollisionBeam

local MegalithBeamWeapon = Class(DefaultBeamWeapon){
	BeamType = MegalithCollisionBeam,
}

UCX0101 = Class(ExperimentalMobileUnit) {

    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 13, 2, 0.0, 0.0, 0.255 )
            end,
        
        },
        Laser02 = Class(MegalithBeamWeapon){},
        Laser03 = Class(MegalithBeamWeapon){},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
        AntiAir03 = Class(DefaultProjectileWeapon) {},
        AntiAir04 = Class(DefaultProjectileWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.WeaponsEnabled = true
    end,

    CreateDamageEffects = function(self, bone, army )
        for k, v in EffectTemplates.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
    end,

    CreateDeathExplosionDustRing = function( self )
        local blanketSides = 18
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 11

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)

            local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 0.5, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.5)
        end
    end,

    CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + GetRandomFloat(-0.3, 0.3)
            velocity.z = velocity.z + GetRandomFloat(-0.3, 0.3)
            velocity.y = velocity.y + GetRandomFloat( 0.0, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(3, 4)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = GetRandomFloat( 12, 22 )
        end
    end,

    CreateExplosionDebris = function( self, army )
        for k, v in EffectTemplates.Explosions.Land.CybranDefaultDestroyEffectsSmall01 do
            CreateAttachedEmitter( self, 'UCX0101_Root', army, v ):OffsetEmitter( 0, 1, 0 )
        end
    end,

    DeathThread = function(self)
		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end
	
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create Initial explosion effects
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death01 do
			CreateEmitterAtBone( self, 'UCX0101_Root', army, v )
		end

        self:CreateFirePlumes( army, {'UCX0101_Root'}, 0 )
        self:CreateFirePlumes( army, {'UCX0101_RightAnkle02', 'UCX0101_LeftAnkle', 'UCX0101_Tail',}, 0.5 )

        self:CreateExplosionDebris( army )

        WaitSeconds(1)

        -- Create damage effects on turret bone
        self:CreateDamageEffects( 'UCX0101_Root', army )

        WaitSeconds( 0.6 )
        self:CreateFirePlumes( army, {'UCX0101_LeftHip1', 'UCX0101_LeftHip2', 'UCX0101_RightHip01', 'UCX0101_RightHip02', 'UCX0101_Root', 'UCX0101_Pelvis', 'UCX0101_Tail',}, 0.5 )
        WaitSeconds(0.2)

        self:CreateDeathExplosionDustRing()

        -- When the spider bot impacts with the ground
        -- Effects: Explosion on turret, dust effects on the muzzle tip, large dust ring around unit
        -- Other: Damage force ring to force trees over and camera shake
        self:ShakeCamera(20, 4, 1, 2.0)

		WaitSeconds( 0.5 )

		self:CreateUnitDestructionDebris()

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0101.Death02 do
			CreateEmitterAtBone( self, 'UCX0101_Root', army, v )
		end

		local bp = self:GetBlueprint()
		local scale = (bp.SizeX + bp.SizeZ) * 1.5
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 4 )

        self:CreateExplosionDebris( army )

		local bp = self:GetUnitWeaponBlueprint('MegalithDeath')
		if bp then
			DamageArea(self, self:GetPosition(), bp.DamageRadius, bp.Damage, bp.DamageType, bp.DamageFriendly)
		end

        self:CreateWreckage()
        self:ShakeCamera(2, 1, 0, 0.05)

        self:Destroy()
    end,

    OnMotionHorzEventChange = function( self, new, old )
        ExperimentalMobileUnit.OnMotionHorzEventChange(self, new, old)

        if ( old == 'Stopped' ) then
            local bpDisplay = self:GetBlueprint().Display
            if bpDisplay.AnimationWalk and self.Animator then
                self.Animator:SetDirectionalAnim(true)
                self.Animator:SetRate(bpDisplay.AnimationWalkRate)
            end
         end
    end,
    
    PlayNISTeleportInEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in EffectTemplates.GenericTeleportIn01 do
            CreateEmitterAtEntity(self,army,v):ScaleEmitter(1.7)
        end
    end,
}
TypeClass = UCX0101
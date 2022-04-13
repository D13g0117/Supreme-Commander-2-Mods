-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0116/ucx0116_script.lua
--  Author(s): Gordon Duclos
--  Summary  : Cybran Proto-Brain!
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local RandomFloat = import('/lua/system/Utilities.lua').GetRandomFloat
local AURA_PULSE_TIME = 6
local AURA_RADIUS = 50
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local BrainCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').BrainCollisionBeam

local BrainBeamWeapon = Class(DefaultBeamWeapon){
	BeamType = BrainCollisionBeam,
}

UCX0116 = Class(ExperimentalAirUnit) {
	Weapons = {
        Laser01 = Class(BrainBeamWeapon){},
        Laser02 = Class(BrainBeamWeapon){},
        Laser03 = Class(BrainBeamWeapon){},
        Laser04 = Class(BrainBeamWeapon){},
        Laser05 = Class(BrainBeamWeapon){},
        Laser06 = Class(BrainBeamWeapon){},
        Laser07 = Class(BrainBeamWeapon){},
        Laser08 = Class(BrainBeamWeapon){},
    },

    Parent = nil,

    SetParent = function(self, parent)
        self.Parent = parent
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
		if self.Parent then
			self.Parent:NotifyOfBrainDeath(self)
			self.Parent = nil
		end
        ExperimentalAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/16)
        end

        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
    end,

    MovementAmbientExhaustBones = {
        { 'Effect06', 'Effect07', 'Effect09', },
        { 'Effect01', 'Effect02', 'Effect08', },
		{ 'Effect04', 'Effect08', 'Effect09', },
		{ 'Effect02', 'Effect06', 'Effect09', },
		{ 'Effect02', 'Effect07', 'Effect08', },
    },

    OnMotionHorzEventChange = function(self, new, old )
		ExperimentalAirUnit.OnMotionHorzEventChange(self, new, old)

		if self.ThrustExhaustTT1 == nil then
			if self.MovementAmbientExhaustEffectsBag then
				CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			else
				self.MovementAmbientExhaustEffectsBag = {}
			end
			self.ThrustExhaustTT1 = self:ForkThread(self.MovementAmbientExhaustThread)
		end

        if new == 'Stopped' and self.ThrustExhaustTT1 != nil then
			KillThread(self.ThrustExhaustTT1)
			CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			self.ThrustExhaustTT1 = nil
        end
    end,

    MovementAmbientExhaustThread = function(self)
		while not self:IsDead() do
            local ExhaustEffects = EffectTemplates.Units.Cybran.Experimental.UCX0116.Thrust01
			local ExhaustBeam = '/effects/emitters/ambient/units/missile_exhaust_fire_beam_06_emit.bp'
			local army = self:GetArmy()

			local bones = self.MovementAmbientExhaustBones[Random(1,table.getn(self.MovementAmbientExhaustBones))]

			for kE, vE in ExhaustEffects do
				for kB, vB in bones do
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeam ))
				end
			end

			WaitSeconds(RandomFloat(0.8,1.2)) -- time on
			CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')

			WaitSeconds(RandomFloat(0.1,0.3)) -- time off
		end
    end,

    DeathThread = function(self)
        local army = self:GetArmy()

        local layer = self:GetCurrentLayer()
        if layer == 'Seabed' then
            self:ForkThread(self.SeaFloorImpactEffects)
        else
            -- explosion effects override on ground impact.
            for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0116.Death01 do
			    CreateEmitterAtEntity( self, army, v )
		    end

		    -- Ground decal
		    CreateDecal(self:GetPosition(),RandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', 20, 20, 150, 15, army, 7 )

            self:ShakeCamera(20, 4, 1, 0.5)
        end

        ExperimentalAirUnit.DeathThread(self)
    end,

	OnAttachToProtoBrainStructure = function(self)
		KillThread( self.tt1 )
	end,

	OnDetachFromProtoBrainStructure = function(self)
		self.tt1 = self:ForkThread( self.AuraThread )
	end,

	CreateUnitAirDestructionEffects = function( self, scale )
        -- custom plume effects, not using bp.Death.AirExplosionEffect due to offset issues.
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0116.DeathTrail01 do
			table.insert( self.DestroyedEffectsBag, CreateAttachedEmitter(self, 'Brain01', self:GetArmy(), v))
		end

		ExperimentalAirUnit.CreateUnitAirDestructionEffects(self)
    end,

	AuraThread = function( self )
		local targets
		while not self:IsDead() do
			local aiBrain = self:GetAIBrain()
			targets = {}
			targets = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, self:GetPosition(), AURA_RADIUS, 'Ally' )

			for k, v in targets do
				ApplyBuff( v, 'ProtobrainExperience', self )

				local x, y, z = v:GetUnitSizes()
                local vol = x*y*z
                local unitClass = 'Small'

                if vol >= 0.45 and vol < 15 then
                    unitClass = 'Medium'
                elseif vol > 15 then
                    unitClass = 'Large'
                end

				if Random(0,1) == 1 then
			        for kEffect, vEffect in EffectTemplates.Units.Cybran.Experimental.UCX0116.BuffEffectsFlying[unitClass] do
				        CreateAttachedEmitter(v, -1, v:GetArmy(), vEffect)
			        end
				end
			end

			WaitSeconds(AURA_PULSE_TIME)
		end
	end,

	SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        volume = sx * sz
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(volume/10)
    end,
}
TypeClass = UCX0116
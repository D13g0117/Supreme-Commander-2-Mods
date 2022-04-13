-----------------------------------------------------------------------------
--  File     : UCX0112
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Soul Ripper II
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local util = import('/lua/system/utilities.lua')

UCX0112 = Class(ExperimentalAirUnit) {

	BeamExhaustCruise = {'/effects/emitters/units/cybran/general/cybran_transport_thruster_beam_02_emit.bp',},
	BeamExhaustIdle = {'/effects/emitters/units/cybran/general/cybran_transport_thruster_beam_01_emit.bp',},
	
    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon){},
        Laser02 = Class(DefaultProjectileWeapon){},
        Laser03 = Class(DefaultProjectileWeapon){},
        
        Missile01 = Class(DefaultProjectileWeapon){},
        Missile02 = Class(DefaultProjectileWeapon){},
        Missile03 = Class(DefaultProjectileWeapon){},
        
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
    },

    MovementAmbientExhaustBones = {
		'Exhaust01',
		'Exhaust02',
		'Exhaust03',
		'Exhaust04',
    },

    MovementAmbientExhaustThread = function(self)
		while not self:IsDead() do
            local ExhaustEffects = EffectTemplates.Units.Cybran.Experimental.UCX0116.Thrust01
			local ExhaustBeam = '/effects/emitters/ambient/units/missile_exhaust_fire_beam_06_emit.bp'
			local army = self:GetArmy()

			for kE, vE in ExhaustEffects do
				for kB, vB in self.MovementAmbientExhaustBones do
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeam ))
				end
			end

			WaitSeconds(2)
			CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')

			WaitSeconds(util.GetRandomFloat(1,7))
		end
    end,
    
	CreateUnitDestructionDebris = function( self )
		ExperimentalAirUnit.CreateUnitDestructionDebris(self)
		self:HideBone('Turret02', true)
	end,    
	
	CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/35)
        end
        
        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
    end,
    
    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes() 
        volume = sx * sz
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(volume/22)
    end,
}
TypeClass = UCX0112
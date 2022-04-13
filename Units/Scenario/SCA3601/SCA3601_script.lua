-----------------------------------------------------------------------------
--  File     :  /units/scenario/sca3601/sca3601_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Drone: SCA3601
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

SCA3601 = Class(AirUnit) {

	BeamExhaustCruise = {
		'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_01_beam_emit.bp',
		'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_02_beam_emit.bp',
	},
	BeamExhaustIdle = {
		'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_01_beam_emit.bp',
		'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_02_beam_emit.bp',
	},

	ContrailEffects = {
	},

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {},
    },

    EngineRotateBones = {
        'VTOL03',
        'VTOL04',
    },
    
    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/2)
        end
        
        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
    end,
}
TypeClass = SCA3601
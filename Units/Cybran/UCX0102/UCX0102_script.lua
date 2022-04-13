-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0102/ucx0102_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Giant Transport
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local util = import('/lua/system/utilities.lua')

UCX0102 = Class(ExperimentalAirUnit) {

    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {},
        Laser02 = Class(DefaultProjectileWeapon) {},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
    },

	BeamExhaustCruise = {'/effects/emitters/units/cybran/general/cybran_transport_thruster_beam_02_emit.bp',},
	BeamExhaustIdle = {'/effects/emitters/units/cybran/general/cybran_transport_thruster_beam_01_emit.bp',},
	
	EngineRotateBones = {
    },
    
        EngineRotateBones = {
        'VTOL01',
        'VTOL02',
        'VTOL03',
        'VTOL04',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalAirUnit.OnStopBeingBuilt(self,builder,layer)
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
        self.EffectsBag = {}
        self.EngineManipulators = {}
        
        -- create the engine thrust manipulators
        for k, v in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, "thruster", v))
        end

        -- set up the thursting arcs for the engines
        for keys,values in self.EngineManipulators do
            --                      XMAX,XMIN,YMAX,YMIN,ZMAX,ZMIN, TURNMULT, TURNSPEED
            values:SetThrustingParam( 0, 0, -0.50, 0.50, 0, 0, 125, 0.04 )
            self.Trash:Add(values)
        end
    end,

    -- Persistent, variable time action, destroyed when transport is done picking up units!
	LoadEffects = {
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_pickup_02_wisps_emit.bp',
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_pickup_03_beam_emit.bp',
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_pickup_04_topglow_emit.bp',
	},
	LoadEffects02 = {
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_pickup_01_glow_emit.bp',
	},
	-- Fire and forget effects.
	UnLoadEffects = {
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_dropoff_02_beam_emit.bp',
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_dropoff_03_wisps_emit.bp',
	},
	UnLoadEffects02 = {
		'/effects/emitters/units/illuminate/air/general/event/transport/transport_dropoff_01_glow_emit.bp',
	},
	
    OnStartTransportLoading = function(self)
		local army = self:GetArmy()
		local layer = self:GetCurrentLayer()

		-- Test terrain height to play a flying ver
		if layer == 'Air' then
			for kEmit, vEmit in self.LoadEffects do
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, -2, army, vEmit ) )
			end
		elseif layer == 'Land' then
			for kEmit, vEmit in self.LoadEffects02 do
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, -2, army, vEmit ) )
			end
		end
    end,

    OnStopTransportLoading = function(self)
		if self.EffectsBag then
			for k, v in self.EffectsBag do
				v:Destroy()
			end
			self.EffectsBag = {}
		end
    end,

	OnStartTransportUnloading = function(self)	
		local army = self:GetArmy()
		local layer = self:GetCurrentLayer()

		-- Test terrain height to play a flying ver
		if layer == 'Air' then
			for kEmit, vEmit in self.UnLoadEffects do
				 CreateAttachedEmitter( self, -2, army, vEmit )
			end
		elseif layer == 'Land' then
			for kEmit, vEmit in self.UnLoadEffects02 do
				 CreateAttachedEmitter( self, -2, army, vEmit )
			end
		end
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
TypeClass = UCX0102
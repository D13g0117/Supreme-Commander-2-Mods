-----------------------------------------------------------------------------
--  File     :  /units/cybran/uca0901/uca0901_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 Cybran Transport: UCA0901
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCA0901 = Class(AirUnit) {
    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {},
    },

	BeamExhaustCruise = {'/effects/emitters/units/cybran/general/cybran_transport_thruster_beam_02_emit.bp',},
	BeamExhaustIdle = {'/effects/emitters/units/cybran/general/cybran_transport_thruster_beam_01_emit.bp',},

    EngineRotateBones = {
        'VTOL01',
        'VTOL02',
        'VTOL03',
        'VTOL04',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        AirUnit.OnStopBeingBuilt(self,builder,layer)
		self.EffectsBag = {}
        
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, 'Thruster', value))
        end

        -- set up the thursting arcs for the engines
        for key,value in self.EngineManipulators do
            --                          XMAX, XMIN, YMAX,YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( 0, 0, -0.3, 0.3, 0, 0, 35, 0.05 )
        end

        for k, v in self.EngineManipulators do
            self.Trash:Add(v)
        end
    end,
    
    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
        attached:DetachFrom()
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        AirUnit.OnKilled(self, instigator, type, overkillRatio)
        -- TransportDetachAllUnits takes 1 bool parameter. If true, randomly destroys some of the transported
        -- units, otherwise successfully detaches all.
        self:TransportDetachAllUnits(true)
    end,
    
    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/30)
        end
        
        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
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
}
TypeClass = UCA0901
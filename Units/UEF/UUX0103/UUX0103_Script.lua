-----------------------------------------------------------------------------
--  File     : /units/uef/uux0103/uux0103_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Experimental Transport: UUX0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local util = import('/lua/system/utilities.lua')

local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUX0103 = Class(ExperimentalAirUnit) {
    AirDestructionEffectBones = {
        'UUX0103',
    },

    ShieldEffects = {
        '/effects/emitters/units/uef/general/terran_shield_generator_mobile_01_emit.bp',
        '/effects/emitters/units/uef/general/terran_shield_generator_mobile_02_emit.bp',
    },

	BeamExhaustCruise = {'/effects/emitters/units/uef/general/transport_thruster_beam_01_emit.bp'},
    BeamExhaustIdle = {'/effects/emitters/units/uef/general/transport_thruster_beam_02_emit.bp'},

    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
        RiotGun1 = Class(DefaultProjectileWeapon) {},
        RiotGun2 = Class(DefaultProjectileWeapon) {},
        RiotGun3 = Class(DefaultProjectileWeapon) {},
        RiotGun4 = Class(DefaultProjectileWeapon) {},

        -- Removing zappers until design evaulates unit; removed due to aiming speed issues
        -- Dru - from eric
        --AntiMissile01 = Class(DefaultBeamWeapon) {
		--	BeamType = CollisionBeamFile.ZapperCollisionBeam,
		--},
        --AntiMissile02 = Class(DefaultBeamWeapon) {
		--	BeamType = CollisionBeamFile.ZapperCollisionBeam,
		--},
    },

    DestructionTicks = 250,
    EngineRotateBones = {
        'VTOL01',
        'VTOL02',
        'VTOL03',
        'VTOL04',
        'VTOL05',
        'VTOL06',
        'VTOL07',
        'VTOL08',
        'VTOL09',
        'VTOL10',
        'VTOL11',
        'VTOL12',
    },

    RearBones = {
    },

    OnCreate = function(self, createArgs)
        ExperimentalAirUnit.OnCreate(self, createArgs)

        self.UnfoldAnim = CreateAnimator(self)
        self.UnfoldAnim:PlayAnim('/units/UEF/xea0306/xea0306_aunfold.sca')
        self.UnfoldAnim:SetRate(0)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalAirUnit.OnStopBeingBuilt(self,builder,layer)
        self.EngineManipulators = {}
		self.EffectsBag = {}

        self.UnfoldAnim:SetRate(1)

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

        self.RearEngines = {}

        for k,v in self.RearBones do
            --local rearThrust = CreateThrustController(self, "rearThruster", v)
            --table.insert(self.RearEngines, rearThrust )
            --self.Trash:Add( rearThrust )
            --rearThrust:SetThrustingParam( 0, 0, -1, 1, -1, 1, 1.0, 0.25 )
        end


        self.LandingAnimManip = CreateAnimator(self)
        self.LandingAnimManip:SetPrecedence(0)
        self.Trash:Add(self.LandingAnimManip)
        self.LandingAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand):SetRate(1)
    end,

    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
        attached:DetachFrom()
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        ExperimentalAirUnit.OnKilled(self, instigator, type, overkillRatio)
        -- TransportDetachAllUnits takes 1 bool parameter. If true, randomly destroys some of the transported
        -- units, otherwise successfully detaches all.
        self:TransportDetachAllUnits(true)
    end,

    OnMotionVertEventChange = function(self, new, old)
        ExperimentalAirUnit.OnMotionVertEventChange(self, new, old)
        if (new == 'Down') then
            self.LandingAnimManip:SetRate(-1)
        elseif (new == 'Up') then
            self.LandingAnimManip:SetRate(1)
        end
    end,

    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
        self:ForkThread(self.AirDestructionEffectsThread, self )
    end,

    AirDestructionEffectsThread = function( self )
    end,

    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/40)
        end

        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
    end,

    GetUnitSizes = function(self)
        local bp = self:GetBlueprint()
        if self:GetFractionComplete() < 1.0 then
            return bp.SizeX, bp.SizeY, bp.SizeZ * 0.5
        else
            return bp.SizeX, bp.SizeY, bp.SizeZ
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

	SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        volume = sx * sz
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(volume/25)
    end,
}
TypeClass = UUX0103

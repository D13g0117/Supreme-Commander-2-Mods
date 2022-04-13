-----------------------------------------------------------------------------
--  File     : /units/illuminate/uia0901/uia0901_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Transport: UIA0901
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/Utilities.lua')

UIA0901 = Class(AirUnit) {
	
	BeamExhaustCruise = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_01_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_02_emit.bp',
	},
    BeamExhaustIdle = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_03_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_04_emit.bp',
    },

    AirDestructionEffectBones = {
        'UIA0901',
    },
    ContrailEffects = {
    },

    EngineRotateBones = {
        'VTOL01',
		'VTOL02',
		'VTOL03',
		'VTOL04',
    },

    Weapons = {
        AutoGun = Class(DefaultProjectileWeapon) {},
        AntiMissile = Class(DefaultProjectileWeapon) {
			CreateProjectileAtMuzzle = function(self, muzzle)
				local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
				if proj then
					local bp = self:GetBlueprint()
					if bp.Flare then
						proj:AddFlare(bp.Flare)
					end
				end
			end,        
        },
    },

    OnStopBeingBuilt = function(self,builder,layer)
        AirUnit.OnStopBeingBuilt(self,builder,layer)
        self.EngineManipulators = {}
		self.EffectsBag = {}

        -- create the engine thrust manipulators
        for k, v in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, "thruster", v))
        end

        -- set up the thursting arcs for the engines
        for keys,values in self.EngineManipulators do
            --                      XMAX,XMIN,	YMAX,YMIN,	ZMAX,ZMIN, TURNMULT, TURNSPEED
            values:SetThrustingParam( 0, 0, -0.50, 0.50, 0, 0, 100, 0.06 )
        end
        
        -- Create ambient spinners
		CreateRotator(self, 'Spinner01', 'y', nil, 0, 60, 360):SetTargetSpeed(26)
		CreateRotator(self, 'Spinner02', 'y', nil, 0, 60, 360):SetTargetSpeed(-32)
		CreateRotator(self, 'Spinner03', 'y', nil, 0, 60, 360):SetTargetSpeed(-26)
		CreateRotator(self, 'Spinner04', 'y', nil, 0, 60, 360):SetTargetSpeed(32)
    end,

    CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + utilities.GetRandomFloat(-0.3, 0.3)
            velocity.z = velocity.z + utilities.GetRandomFloat(-0.1, 0.1)
            velocity.y = velocity.y + utilities.GetRandomFloat(-0.1, 0.1)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(2, 8)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = utilities.GetRandomFloat( 4, 9 )
        end
    end,
    
    CreateUnitAirDestructionEffects = function( self, scale )
		local bp = self:GetBlueprint()
		local AirExplosionEffect = bp.Death.AirExplosionEffect
		local AirPlumeEffect = bp.Death.AirDestructionPlumeEffect
		local army = self:GetArmy()

		if AirExplosionEffect then
			local faction = bp.General.FactionName
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Units[faction][layer].General[AirExplosionEffect]
			if emitters then
				CreateBoneEffects( self, 'UIA0901', army, emitters )
			end
			self:CreateFirePlumes( army, {'UIA0901', 'Connector03', 'Front01',}, 0 )
		end

		if AirPlumeEffect then
			local emitters = EffectTemplates.Wreckage[AirPlumeEffect] or {}
			for kEffect, vEffect in emitters do
				CreateAttachedEmitter(self, 'UIA0901', army, vEffect)
			end
		end
    end,
    
    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/20)
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
TypeClass = UIA0901
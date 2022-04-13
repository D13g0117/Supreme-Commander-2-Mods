-----------------------------------------------------------------------------
--  File     : /units/uef/uux0102/uux0102_script.lua
--  Author(s): Aaron Lundquist, Ode, Gordon Duclos
--  Summary  : SC2 UEF Experimental Assault Plane: UUX0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/Utilities.lua')
local RandomFloat = utilities.GetRandomFloat

UUX0102 = Class(ExperimentalAirUnit) {

	BeamExhaustCruise = {'/effects/emitters/units/uef/general/transport_thruster_beam_01_emit.bp'},
    BeamExhaustIdle = {'/effects/emitters/units/uef/general/transport_thruster_beam_02_emit.bp'},
    
    Weapons = {
        RightCannon = Class(DefaultProjectileWeapon) {},
        FrontRiotGun = Class(DefaultProjectileWeapon) {},
	    RightRiotGun01 = Class(DefaultProjectileWeapon) {},
	    RightRiotGun02 = Class(DefaultProjectileWeapon) {},
    },  
    
   	OnCreate = function(self, createArgs)
		ExperimentalAirUnit.OnCreate(self, createArgs)

		self.EngineRotateBones = {'VTOL01', 'VTOL02', 'VTOL03', 'VTOL04',}
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, "thruster", value))
        end

        -- set up the thursting arcs for the engines
        for k,v in self.EngineManipulators do
            --                    XMAX, XMIN, YMAX, YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
			-- MIN XYZ MAX XYZ TURN MULT SPEED
            v:SetThrustingParam( -0.1, 0.1, -0.5, 0.5, 0, 0, 50.0, 0.1 )
        end

        for k, v in self.EngineManipulators do
            self.Trash:Add(v)
        end
	end,

    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/13)
        end
        
        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
    end,
    
    CreateExplosionDebris = function( self, army, bone )
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 do
            CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 0, 0 )
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
			local emitters = EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsMed01
			if emitters then
				CreateBoneEffects( self, -2, army, emitters )
			end
		end

		self:CreateExplosionDebris( army, 'VTOL01' )     
		self:CreateExplosionDebris( army, 'VTOL03' )     
    end,
    
    
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
  
		self:CreateUnitDestructionDebris()
			
        WaitSeconds(0.1)

		for k, v in EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v )
		end
		
        self:ShakeCamera(20, 4, 1, 2.0)
        				
		self:CreateWreckage(0.1)
		-- Ground decal		
		CreateDecal(self:GetPosition(),RandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', 20, 20, 60, 60, self:GetArmy(), 5)
				
		WaitSeconds(0.5)
        self:ShakeCamera(2, 1, 0, 0.05)
        self:Destroy()
    end,
}
TypeClass = UUX0102
-----------------------------------------------------------------------------
--  File     :  /units/uef/uux0112/uux0112_script.lua
--  Author(s):	Gordon Duclos
--  Summary  :  SC2 UEF Experimental Air Fortress: UUX0112
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/Utilities.lua')
local RandomFloat = utilities.GetRandomFloat

UUX0112 = Class(ExperimentalAirUnit) {

	BeamExhaustCruise = {'/effects/emitters/units/uef/general/transport_thruster_beam_01_emit.bp'},
    BeamExhaustIdle = {'/effects/emitters/units/uef/general/transport_thruster_beam_02_emit.bp'},

    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
        AntiAir03 = Class(DefaultProjectileWeapon) {},
        AntiAir04 = Class(DefaultProjectileWeapon) {},
        RiotGun1 = Class(DefaultProjectileWeapon) {},
        RiotGun2 = Class(DefaultProjectileWeapon) {},
        RiotGun3 = Class(DefaultProjectileWeapon) {},
        RiotGun4 = Class(DefaultProjectileWeapon) {},
        RiotGun5 = Class(DefaultProjectileWeapon) {},
        RiotGun6 = Class(DefaultProjectileWeapon) {},
        RiotGun7 = Class(DefaultProjectileWeapon) {},
        RiotGun8 = Class(DefaultProjectileWeapon) {},
    },

	OnCreate = function(self, createArgs)
		ExperimentalAirUnit.OnCreate(self, createArgs)
        self.UnitBeingBuilt = nil

		self.EngineRotateBones = {'VTOL01', 'VTOL02', 'VTOL03', 'VTOL04', 'VTOL05', 'VTOL06', 'VTOL07', 'VTOL08' }
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, "thruster", value))
        end

        -- set up the thursting arcs for the engines
        for k,v in self.EngineManipulators do
            --                  minRoll, maxRoll, minPitch, maxPitch, minYaw, maxYaw, turnForceMult, turnSpeed
            v:SetThrustingParam( -0.5,     0.5,      -0.5,       0.5,       0,    0,     150,         0.02 )
        end

        for k, v in self.EngineManipulators do
            self.Trash:Add(v)
        end
	end,

    CreateExplosionDebris = function( self, army, bone )
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 do
            CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 0, 0 )
        end
    end,

    CreateUnitAirDestructionEffects = function( self, scale )
    	local army = self:GetArmy()

        for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
            CreateAttachedEmitter( self, 'UUX0112', army, v ):OffsetEmitter( 0, 6, 0 ):ScaleEmitter( 3 )
        end

        self:CreateExplosionDebris( army, 'VTOL01' )
		self:CreateExplosionDebris( army, 'VTOL03' )
		self:CreateExplosionDebris( army, 'VTOL05' )
		self:CreateExplosionDebris( army, 'VTOL07' )
    end,

    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/80)
        end

        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
    end,

    -- ON KILLED: THIS FUNCTION PLAYS WHEN THE UNIT TAKES A MORTAL HIT.  IT PLAYS ALL THE DEFAULT DEATH EFFECT
    -- IT ALSO SPAWNS THE WRECKAGE BASED UPON HOW MUCH IT WAS OVERKILLED. UNIT WILL SPIN OUT OF CONTROL TOWARDS
    -- GROUND AND WHEN IT IMPACTS IT WILL DESTROY ITSELF
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp = self:GetBlueprint()
        if self:GetCurrentLayer() == 'Air' then

            self.CreateUnitAirDestructionEffects( self, 1.0 )
			self:CreateUnitDestructionDebris()
            self.OverKillRatio = overkillRatio
            self:PlayUnitSound('Killed')
			self:PlayUnitAmbientSound('FallingLoop')
            self:OnKilledVO()
            self.Callbacks.OnKilled:Call(self, instigator, type)
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
        else
            self.DeathBounce = 1
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
            ExperimentalAirUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,

    OnImpact = function(self, with, other)
		if not self:IsDead() then
			return
		end

        -- Damage the area we have impacted with.
		local bp = self:GetUnitWeaponBlueprint('DeathImpact')
		if bp then
			DamageArea(self, self:GetPosition(), bp.DamageRadius, bp.Damage, bp.DamageType, bp.DamageFriendly)
		end

		-- Ground decal
		CreateDecal(self:GetPosition(),RandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', 20, 20, 60, 60, self:GetArmy(), 5)

        self:ShakeCamera(20, 4, 2, 2.0)

		self:StopUnitAmbientSound('FallingLoop')

        if with == 'Water' then
            self:PlayUnitSound('AirUnitWaterImpact')
            self:PlayUnitAmbientSound('Sinking')
            self:ForkThread(self.CreateUnitWaterImpactEffect)
        else
            -- This is a bit of safety to keep us from calling the death thread twice in case we bounce twice quickly
            if not self.DeathBounce then
				self:StopUnitAmbientSound('Sinking')
                self:ForkThread(self.DeathThread, self.OverKillRatio )
                self.DeathBounce = 1
            end
        end
    end,

    BuildAttachBone = 'UUX0112',

    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:DetachAll(self.BuildAttachBone)
    end,

    OnStartBuild = function(self, unitBuilding, order)
        ExperimentalAirUnit.OnStartBuild(self, unitBuilding, order)

        self.UnitBeingBuilt = unitBuilding
        unitBuilding:SetDoNotTarget(true)
        unitBuilding:SetCanTakeDamage(false)
        unitBuilding:SetUnSelectable(true)
        unitBuilding:HideMesh()
        local bone = self.BuildAttachBone
        self:DetachAll(bone)
        unitBuilding:AttachBoneTo(-2, self, bone)
        self.UnitDoneBeingBuilt = false
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        if not unitBeingBuilt or unitBeingBuilt:IsDead() then
            return
        end
        
		-- Callbacks
		ExperimentalAirUnit.ClassCallbacks.OnStopBuild:Call( self, unitBeingBuilt )
		self.Callbacks.OnStopBuild:Call( self, unitBeingBuilt )        

        unitBeingBuilt:DetachFrom(true)
        unitBeingBuilt:SetDoNotTarget(false)
        unitBeingBuilt:SetCanTakeDamage(true)
        unitBeingBuilt:SetUnSelectable(false)
        self:DetachAll(self.BuildAttachBone)
        if self:TransportHasAvailableStorage(unitBeingBuilt) then
            self:TransportAddUnitToStorage(unitBeingBuilt)
        else
            local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
            IssueMoveOffFactory({unitBeingBuilt}, worldPos)
            unitBeingBuilt:ShowMesh()
        end
        
        -- If there are no available storage slots, pause the builder!
        if self:GetNumberOfAvailableStorageSlots() == 0 then
            self:SetBuildDisabled(true)
            self:SetPaused(true)
        end   
                
		self.UnitBeingBuilt = nil
        self:RequestRefreshUI()
    end,

    OnFailedToBuild = function(self)
        ExperimentalAirUnit.OnFailedToBuild(self)
        self:DetachAll(self.BuildAttachBone)
    end,
    
    OnTransportUnloadUnit = function(self,unit)
        if self:IsBuildDisabled() and self:GetNumberOfAvailableStorageSlots() > 0 then
            self:SetBuildDisabled(false)
            self:RequestRefreshUI()
        end   
    end,        

    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        volume = sx * sz
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(volume/80)
    end,
}
TypeClass = UUX0112

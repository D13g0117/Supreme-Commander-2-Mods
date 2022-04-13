-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0112/uix0112_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist, Eric Williamson
--  Summary  : SC2 Illuminate Experimental Giant Saucer: UIX0112
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local DarkenoidMainCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').DarkenoidMainCollisionBeam
local DarkenoidSmallCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').DarkenoidSmallCollisionBeam
local utilities = import('/lua/system/Utilities.lua')
local RandomFloat = utilities.GetRandomFloat

local DarkenoidSmallBeamWeapon = Class(DefaultBeamWeapon){
	BeamType = DarkenoidSmallCollisionBeam,
}

UIX0112 = Class(ExperimentalAirUnit) {
    Weapons = {
		MainBeam01 = Class(DefaultBeamWeapon){
			BeamType = DarkenoidMainCollisionBeam,
		},
		BeamTurret01 = Class(DarkenoidSmallBeamWeapon){},
		BeamTurret02 = Class(DarkenoidSmallBeamWeapon){},
		BeamTurret03 = Class(DarkenoidSmallBeamWeapon){},
		PinWheelBomb01 = Class(DefaultProjectileWeapon){
			IdleState = State {
				OnGotTarget = function(self)
					self.unit.SpinnerTarget = true
					DefaultProjectileWeapon.IdleState.OnGotTarget(self)
				end,
			},
		},
    },
    
	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalAirUnit.OnStopBeingBuilt(self,builder,layer)
		self:ForkThread( self.SpinnerThread )
	end,

	SpinnerThread = function(self)
        local animator = CreateAnimator(self)
        animator:PlayAnim('/units/illuminate/uix0112/uix0112_Aopen01.sca')
        self.Trash:Add(animator)
        WaitFor(animator)		
		self.Spinner = CreateRotator(self, 'OutterRing', 'y', nil, 0, 60, 360):SetTargetSpeed(16)
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false

		while not self:IsDead() do
			if self.SpinnerTarget then
				self.Spinner:SetTargetSpeed(150)
				self.SpinnerTarget = false
				WaitSeconds(5)
				self.Spinner:SetTargetSpeed(16)
			else
				WaitSeconds(1)
			end
		end
	end,
	
	CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + RandomFloat(-0.8, 0.8)
            velocity.z = velocity.z + RandomFloat(-0.5, 0.8)
            velocity.y = velocity.y + RandomFloat(-0.3, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(RandomFloat(-1, 1)):SetVelocity(RandomFloat(3, 10)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = RandomFloat( 15, 25 )
        end
    end,
    
    CreateUnitDestructionDebris = function( self )
		if not self.DestructionPartsCreated then
			self.DestructionPartsCreated = true
			local DestructionParts = self:GetBlueprint().Death.DestructionParts
			
			if DestructionParts then
				local scale = self:GetBlueprint().Display.UniformScale
				for k, v in DestructionParts do
					
					if v.Mesh then
						self:CreateDestructionPart( v, scale, v.Mesh)
						self:HideBone( v.AttachBone, true )
					elseif v.Meshes then
						for kMesh, vMesh in v.Meshes do
							self:CreateDestructionPart(v, scale, vMesh)
						end
						self:HideBone( v.AttachBone, true )						
					end
				end
			end
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
			local emitters = EffectTemplates.Units.Illuminate.Experimental.UIX0112.Death01
			if emitters then
				CreateBoneEffects( self, -2, army, emitters )
			end
		end

		self:CreateFirePlumes( army, {'Turret01', 'Turret02', 'Turret04', 'Turret05', 'Turret07', 'Turret08', 'Turret10'}, 1 )	
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
    end,
    
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
  
		self:CreateUnitDestructionDebris()
			
        WaitSeconds(0.1)
        -- When the unit impacts with the ground
        -- Damage force ring to force trees over and camera shake

        self:ShakeCamera(20, 4, 1, 2.0)
        				
		self:CreateWreckage(0.1)
		-- Ground decal		
		CreateDecal(self:GetPosition(),RandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', 36, 36, 60, 60, self:GetArmy(), 5)
		
		WaitSeconds(0.2)
		                       
		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
        
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)
        WaitSeconds(0.2)
		
        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)
		
		WaitSeconds(0.5)
        self:ShakeCamera(2, 1, 0, 0.05)
        self:Destroy()
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
        self.detector = CreateCollisionDetector(self)
        self.Trash:Add(self.detector)
        self.detector:WatchBone('UIX0112')
        self.detector:WatchBone('Turret01')
        self.detector:WatchBone('Turret02')
        self.detector:WatchBone('Turret03')
        self.detector:WatchBone('Turret04')
        self.detector:WatchBone('Turret05')
        self.detector:WatchBone('Turret06')
        self.detector:WatchBone('Turret07')
        self.detector:WatchBone('Turret08')
        self.detector:EnableTerrainCheck(true)
        self.detector:Enable()
        ExperimentalAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnAnimTerrainCollision = function(self, bone,x,y,z)
		-- enable the following line if you want only one explosion effect on death
		--self.detector:Disable()
        DamageArea(self, {x,y,z}, 5, 1000, 'Default', true, false)
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0112.Death02 do
			CreateAttachedEmitter ( self, bone, self:GetArmy(), v )
		end  
    end,
}
TypeClass = UIX0112
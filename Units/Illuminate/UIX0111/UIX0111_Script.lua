-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0111/uix0111_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Experimental Assault Bot: UIX0111
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DeathClaw = import('UIX0111_DeathClaw.lua').DeathClaw
local EyeLaser = import('UIX0111_EyeLaser.lua').EyeLaser
local UnitLauncher = import('UIX0111_UnitLauncher.lua').UnitLauncher
local TurretWeapon = import('/lua/sim/weapon.lua').TurretWeapon
local utilities = import('/lua/system/Utilities.lua')
local AURA_PULSE_TIME = 6
local AURA_RADIUS = 30

UIX0111 = Class(ExperimentalMobileUnit) {

    Weapons = {
        BodyYaw = Class(TurretWeapon) {
            OnGotTarget = function(self)
                local target = self:GetCurrentTarget()

                if target and IsBlip(target) then
                    target = target:GetSource()
                end

                if target and target.DeathClawed then
                    self:ResetTarget()
                end
            end,
        },
        EyeLaser01 = Class(EyeLaser) {},

        -- Right Arm
        DeathClaw01 = Class(DeathClaw) {},
        UnitLauncher01 = Class(UnitLauncher) {
		    OnCreate = function(self)
                UnitLauncher.OnCreate(self)
                self.ClawWeapon = self.unit:GetWeapon('DeathClaw01')
				self.ClawWeapon:SetUnitLauncher( self )
				self.AimControl:SetEnabled(false)
            end,
		},

        -- Left Arm
        DeathClaw02 = Class(DeathClaw) {},
        UnitLauncher02 = Class(UnitLauncher) {
		    OnCreate = function(self)
                UnitLauncher.OnCreate(self)
                self.ClawWeapon = self.unit:GetWeapon('DeathClaw02')
				self.ClawWeapon:SetUnitLauncher( self )
				self.AimControl:SetEnabled(false)
            end,
        },
    },

    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
		self.RightClawRotators = {}
		self.LeftClawRotators = {}
		self:ForkThread( self.AuraThread )
    end,

	AuraThread = function(self)
		local targets
		while not self:IsDead() do
			local aiBrain = self:GetAIBrain()
			targets = {}
			targets = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS - categories.EXPERIMENTAL - categories.COMMAND, self:GetPosition(), AURA_RADIUS, 'Ally' )
			for k, v in targets do
				if v != self and not v:IsBeingBuilt() then
					ApplyBuff( v, 'ArmorEnhancementColossus', self )

					-- Removed for perf
					--for kEffect, vEffect in EffectTemplates.Units.Illuminate.Land.UIL0202.UIL0202BuffEffectsMed01 do
					--	CreateEmitterAtEntity( v, v:GetArmy(), vEffect )
					--end

				end
			end
			WaitSeconds(AURA_PULSE_TIME)
		end
	end,

    CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + utilities.GetRandomFloat(-0.5, 0.5)
            velocity.z = velocity.z + utilities.GetRandomFloat(-0.5, 0.5)
            velocity.y = velocity.y + utilities.GetRandomFloat( 0.1, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, 1)):SetVelocity(utilities.GetRandomFloat(3, 5)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = utilities.GetRandomFloat( 15, 25 )
        end
    end,

    CreateExplosionDebris = function( self, army, bone )
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 do
            CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 0, 0 )
        end
    end,

    DeathThread = function(self)

		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end

        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'UIX0111_Root', self:GetArmy(), v )
		end
        WaitSeconds(1.0)
        self:CreateExplosionDebris( army, 'UIX0111_Head' )
        WaitSeconds(0.3)
        self:CreateExplosionDebris( army, 'UIX0111_RightHip' )
        WaitSeconds(0.4)
        self:CreateExplosionDebris( army, 'UIX0111_LeftShoulderPad' )
        self:CreateExplosionDebris( army, 'UIX0111_RightFinger02' )
		WaitSeconds(0.5)
		self:CreateExplosionDebris( army, 'UIX0111_RightElbow' )
		WaitSeconds(0.3)
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'UIX0111_Root', self:GetArmy(), v )
		end
		WaitSeconds(0.2)
		self:CreateExplosionDebris( army, 'UIX0111_LeftKnee' )
		self:CreateUnitDestructionDebris()

        WaitSeconds(0.1)
        -- When the unit impacts with the ground
        -- Effects: large dust around unit
        -- Other: Damage force ring to force trees over and camera shake

		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death03 do
			CreateAttachedEmitter ( self, 'UIX0111_RightKnee', self:GetArmy(), v )
		end

        self:ShakeCamera(20, 4, 1, 2.0)

		WaitSeconds(0.1)
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death03 do
			CreateAttachedEmitter ( self, 'UIX0111_LeftHip', self:GetArmy(), v )
		end

		self:CreateFirePlumes( army, {'UIX0111_Head', 'UIX0111_Chest', 'UIX0111_Antenna01', 'UIX0111_LeftShoulderPad', 'UIX0111_RightElbow', 'UIX0111_RightClaw', 'UIX0111_LeftClaw'}, 0.5 )
		WaitSeconds(0.4)

		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death03 do
			CreateAttachedEmitter ( self, 'UIX0111_RightShoulderPad', self:GetArmy(), v )
		end

		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end

        self:CreateWreckage(0.1)

        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)
        WaitSeconds(0.2)

        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

		WaitSeconds(0.7)
        self:ShakeCamera(2, 1, 0, 0.05)

        self:Destroy()
    end,

	RightClaw_FingerBones = {
		{ Bone = 'UIX0111_RightFinger01', Axis = 'x', Angle = 80 },
		{ Bone = 'UIX0111_RightFinger03', Axis = 'x', Angle = 80 },
		{ Bone = 'UIX0111_RightFinger05', Axis = 'x', Angle = 80 },
		{ Bone = 'UIX0111_RightFinger07', Axis = 'x', Angle = 80 },
		{ Bone = 'UIX0111_RightFinger02', Axis = 'x', Angle = 90 },
		{ Bone = 'UIX0111_RightFinger04', Axis = 'x', Angle = 90 },
		{ Bone = 'UIX0111_RightFinger06', Axis = 'x', Angle = 90 },
		{ Bone = 'UIX0111_RightFinger08', Axis = 'x', Angle = 90 },
	},

	LeftClaw_FingerBones = {
		{ Bone = 'UIX0111_LeftFinger01', Axis = 'x', Angle = -80 },
		{ Bone = 'UIX0111_LeftFinger03', Axis = 'x', Angle = -80 },
		{ Bone = 'UIX0111_LeftFinger05', Axis = 'x', Angle = -80 },
		{ Bone = 'UIX0111_LeftFinger07', Axis = 'x', Angle = -80 },
		{ Bone = 'UIX0111_LeftFinger02', Axis = 'x', Angle = -90 },
		{ Bone = 'UIX0111_LeftFinger04', Axis = 'x', Angle = -90 },
		{ Bone = 'UIX0111_LeftFinger06', Axis = 'x', Angle = -90 },
		{ Bone = 'UIX0111_LeftFinger08', Axis = 'x', Angle = -90 },
	},

	DeployClaw = function(self, index)
		if index == 1 then
			if table.empty(self.RightClawRotators) then
				for k, v in self.RightClaw_FingerBones do
					local rotator = CreateRotator(self, v.Bone, v.Axis, v.Angle, 150, 100 )
					table.insert( self.RightClawRotators, { Rotator = rotator, Goal = v.Angle } )
					self.Trash:Add( rotator )
				end
			else
                for k, v in self.RightClawRotators do
					v.Rotator:SetGoal(v.Goal)
				end
			end
		elseif index == 2 then
			if table.empty(self.LeftClawRotators) then
				for k, v in self.LeftClaw_FingerBones do
					local rotator = CreateRotator(self, v.Bone, v.Axis, v.Angle, 150, 100 )
					table.insert( self.LeftClawRotators, { Rotator = rotator, Goal = v.Angle } )
					self.Trash:Add( rotator )
				end
			else
                for k, v in self.LeftClawRotators do
					v.Rotator:SetGoal(v.Goal)
				end
			end
		end
	end,

	RetractClaw = function(self, index)
		if index == 1 then
			if not table.empty(self.RightClawRotators) then
                for k, v in self.RightClawRotators do
					v.Rotator:SetGoal(0)
				end
			end
		elseif index == 2 then
			if not table.empty(self.LeftClawRotators) then
                for k, v in self.LeftClawRotators do
					v.Rotator:SetGoal(0)
				end
			end
		end
	end,
}
TypeClass = UIX0111

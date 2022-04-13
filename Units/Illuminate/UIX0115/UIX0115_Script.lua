-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0115/uix0115_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Experimental Pulinsmash: UIX0115
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TargetCategory = categories.MOBILE - categories.COMMAND - categories.EXPERIMENTAL - categories.TRANSPORTATION

local SmashAttach = 'Pull_Attachpoint'
local RateOfFire = 5

local SpinUpTime = 5
local SpinBone = 'MainTurret01'
local SpinSpeed = 180

local MassPercent = 0.15
local LaunchTimeout = 10

UIX0115 = Class(ExperimentalMobileUnit) {

    EffectBones = {
		'Joint01',
		'Joint02',
		'Joint03',
		'Joint04',
    },

    OnStopBeingBuilt = function(self, creator, layer)
        ExperimentalMobileUnit.OnStopBeingBuilt(self, creator, layer)
        self.Spinner = CreateRotator(self, SpinBone, 'y', nil, 0, SpinSpeed / SpinUpTime, 0)
        self.Trash:Add(self.Spinner)
		self.Animator = CreateAnimator(self)
        self.EffectsBag = {}
        self.BuildChargeEffects = {}
        local bp = self:GetBlueprint()
        self.SmashWait = bp.SmashWait or 3.0
        self.SmashRadius = bp.SmashRadius or 50.0
    end,

    OnPullinsmash = function( self, abilityBP, state )
		if state == 'activate' and not self.Smashin then
            self.Smashin = true
            self.SpinUpThread = self:ForkThread( self.SpinUp )

            self:PlayUnitAmbientSound('MagneticLoop')

            -- base effects on unit activate
            for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0115.Activate01 do
				table.insert( self.EffectsBag, CreateAttachedEmitter(self, -2, self:GetArmy(), v ))
			end

			for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0115.Activate04 do
				table.insert( self.BuildChargeEffects, CreateAttachedEmitter(self, -2, self:GetArmy(), v ))
			end

			local bp = self:GetBlueprint()
			local scale = 0.5
			self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY + (bp.SizeY*0.25)) or 0, bp.CollisionOffsetZ or 0, bp.SizeX * scale, bp.SizeY * scale * 0.5, bp.SizeZ * scale )
		else
            self.Smashin = false

            self:StopUnitAmbientSound('MagneticLoop')

            -- Stop any old threads running
            if self.SpinUpThread then KillThread(self.SpinUpThread) end
            if self.TargetThread then KillThread(self.TargetThread) end

            self.SpinDownThread = self:ForkThread( self.SpinDown )

			local bp = self:GetBlueprint()
			local scale = 0.5
			self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY + (bp.SizeY*0.5)) or 0,bp.CollisionOffsetZ or 0, bp.SizeX * scale, bp.SizeY * scale, bp.SizeZ * scale )

		    if self.LaunchThread then
				KillThread(self.LaunchThread)
			end

			if self.PullAttached and not self.PullAttached:IsDead() then
				self:LaunchTarget()
			else
				self.PullAttached = false
			end
        end
    end,

--[[
    When we start pulling we do a spinup, this gets the spinner going full bore
    When spinup is finished, we start searching for targets
    When a target is found we pull in the target along a slider
    When the target is finished on the slider we then send it to be handled then search again
    In handling the target, if there is another unit we blow them both up or something
        If there is not another unit, we wait a certain amount of time then blow up the new unit
    When the ability is toggled off, we do a spin down then let the unit move
]]
    -- Here we start rotating the claws in and spin the unit
    SpinUp = function(self)
        -- Start the spinnin
        self.Spinner:SetTargetSpeed(SpinSpeed)
		self.Animator:PlayAnim('/units/illuminate/uix0115/uix0115_aunpack01.sca')
        self:PlayUnitSound('Unpack')

        WaitSeconds(SpinUpTime)

		-- Destroy all intermediary effects
		for k, v in self.BuildChargeEffects do
			v:Destroy()
		end
		self.BuildChargeEffects = {}

		-- spinning effects when unit is at full speed
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0115.Activate02 do
			table.insert( self.EffectsBag, CreateAttachedEmitter(self, -2, self:GetArmy(), v ))
		end

		for kBone, vBone in self.EffectBones do
			for kEffect, vEffect in EffectTemplates.Units.Illuminate.Experimental.UIX0115.Activate03 do
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, vBone, self:GetArmy(), vEffect ) )
			end
		end

        self.TargetThread = self:ForkThread( self.SearchForTarget )
    end,

    SpinDown = function(self)
        self:CleanupActivateEffects()
        self.Spinner:SetTargetSpeed(0)
		self.Animator:PlayAnim('/units/illuminate/uix0115/uix0115_apack01.sca')
        self:PlayUnitSound('Pack')
    end,

    CleanupActivateEffects = function(self)
        if self.EffectsBag then
			for k, v in self.EffectsBag do
				v:Destroy()
			end
			self.EffectsBag = {}
		end
        if self.BuildChargeEffects then
			for k, v in self.BuildChargeEffects do
				v:Destroy()
			end
			self.BuildChargeEffects = {}
		end
    end,

    SearchForTarget = function(self)
        local aiBrain = self:GetAIBrain()

        while self and not self:IsDead() and self.Smashin do
			
			-- Don't search for targets if the pullinsmash is stunned
			if not self:IsStunned() then
			
				local enemies = aiBrain:GetUnitsAroundPoint( TargetCategory, self:GetPosition(), self.SmashRadius, 'Enemy' )
				
				if not table.empty(enemies) then

					for k,v in enemies do
						if v:IsEntityState('DoNotTarget') or v:IsUnitState('Attached') then
							continue
						end

						if v.Grabbed then
							continue
						end

						v:SetDoNotTarget(true)
						v:SetCanTakeDamage(false)
						v.Grabbed = true

						self:ForkThread(self.PullTarget, v)
						break
					end

					WaitSeconds(self.SmashWait)
				else
					WaitSeconds(0.5)
				end
			end
			
            WaitSeconds(1/RateOfFire)
        end
    end,

    PullTarget = function(self, target)
        local targetPosition = target:GetPosition()
        local bonePosition = self:GetBonePosition(SmashAttach)
		local army = self:GetArmy()
		local diffVec = VDiff( bonePosition, targetPosition )
		local dist = VDist3(targetPosition, bonePosition)
		local pullVelocity = 60
		self.PullingTarget = target

		local proj01 = target:CreateProjectile('/projectiles/Illuminate/IPullinsmash01/IPullinsmash01_proj.bp',0,0,0,nil,nil,nil)
		proj01:SetVelocity( diffVec[1], diffVec[2], diffVec[3] )
		proj01:SetVelocity( pullVelocity )
		target:AttachBoneTo(0, proj01, -1 )
		target:SetCollisionShape('None', 0, 0, 0, 0)
		target:DestroyIdleEffects()
		target:DestroyMovementEffects()

		local time = dist / pullVelocity

		-- Pulled energy
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0115.PulledUnitLines01 do
			local emit = CreateEmitterAtEntity( target, army, v )
			emit:SetEmitterCurveParam('XDIR_CURVE', diffVec[1], 0.1)
			emit:SetEmitterCurveParam('YDIR_CURVE', diffVec[2], 0.1)
			emit:SetEmitterCurveParam('ZDIR_CURVE', diffVec[3], 0.1)
		end
		-- Pulled debris
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0115.PulledUnitDebris01 do
			local emit = CreateAttachedEmitter( target, -2, army, v )
		end

		WaitSeconds(time)

        if not target:IsDead() then
		    -- If we have deactivated while pulling, lets do get rid of this unit
			if self.Smashin then
				self:HandleTarget(target)
			else
				local proj02 = target:CreateProjectile('/projectiles/Illuminate/IPullinsmash02/IPullinsmash02_proj.bp',0,0,0,nil,nil,nil)
				target:DetachFrom(true,true)
				target:AttachBoneTo(0, proj02, -1 )
				proj02:SetVelocity( diffVec[1], diffVec[2], diffVec[3] )
				proj02:SetVelocity( pullVelocity )
				proj02:SetBallisticAcceleration( -9.8 )
				proj02:SetAttachedUnit( target )
			end
        end
    end,

	DestroyTarget = function(self, target)
        -- Award mass resources for this target
        local aiBrain = self:GetAIBrain()
        local attachBp = target:GetBlueprint()
        local massGain = MassPercent * attachBp.Economy.MassValue
        aiBrain:GiveResource( 'MASS', massGain )

		-- Award xp to the pullnsmash
		local xp = target:GetBlueprint().General.ExperienceValue
		self:AwardExperience( xp )

		target:Destroy()
	end,

    HandleTarget = function(self, target)

		-- If we don't have an attached unit, then attach this one and spin it!
		-- If we have a target then already, then destroy it and the unit,
        if not self.PullAttached then
            self.PullAttached = target
			self.PullingTarget = false
            target:DetachFrom(true,true)
            target:AttachBoneTo(-1, self, SmashAttach)
            self.LaunchThread = self:ForkThread( self.LaunchTargetThread )
        else
			-- Kill the launch thread, since we destroying the attached unit.
		    if self.LaunchThread then
				KillThread(self.LaunchThread)
			end

            -- pulled unit destroy effects
            for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0115.PulledUnitDestroy01 do
				table.insert( self.EffectsBag, CreateEmitterAtEntity( self, self:GetArmy(), v ))
			end

			if self.PullAttached and not self.PullAttached:IsDead() then
				self:DestroyTarget(self.PullAttached)
				self:DestroyTarget(target)
			end

            self.PullAttached = false
			self.PullingTarget = false
        end
    end,

	LaunchTargetThread = function(self)
		-- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
		local targetSpinner01 = CreateRotator(self.PullAttached, 0, 'z', nil, 260, 260, 260)
		local targetSpinner02 = CreateRotator(self.PullAttached, 0, 'x', nil, 260, 260, 260)
		self.Trash:Add(targetSpinner01)
		self.Trash:Add(targetSpinner02)
		WaitSeconds(LaunchTimeout)
		targetSpinner01:Destroy()
		targetSpinner02:Destroy()
		if self.PullAttached and not self.PullAttached:IsDead() then
			self:LaunchTarget()
		else
			self.PullAttached = false
		end
	end,

    LaunchTarget = function(self)
        local aiBrain = self:GetAIBrain()

        -- get the resources
        local attachBp = self.PullAttached:GetBlueprint()
        local massGain = MassPercent * attachBp.Economy.MassValue
        aiBrain:GiveResource( 'MASS', massGain )

		local xp = self.PullAttached:GetBlueprint().General.ExperienceValue
		self:AwardExperience( xp )

		local proj = self.PullAttached:CreateProjectile('/projectiles/Illuminate/IPullinsmash02/IPullinsmash02_proj.bp',0,0,0,nil,nil,nil)
		proj:SetVelocity( Random() * 0.3, 1, Random() * 0.3 )
		proj:SetVelocity( 20 )
		proj:SetBallisticAcceleration( -9.8 )
		proj:SetAttachedUnit( self.PullAttached )
		self.PullAttached:DetachFrom(true,true)
		self.PullAttached:AttachBoneTo(0, proj, -1 )

        self.PullAttached = false
    end,
	
	OnAddToStorage = function(self, unit)
        LOG("Pullinshamsh OnAddToStoragea()")
		if self.Smashin then
            LOG("Pullinshamsh was smashing")
			self:OnPullinsmash(nil, 'deactivate')
            self.WasSmashin = true
		end
		ExperimentalMobileUnit.OnAddToStorage(self, unit)
	end,
    
	OnRemoveFromStorage = function(self, unit)
		if self.WasSmashin then
            self:OnPullinsmash(nil, 'activate')
            self.WasSmashin= false
		end
		ExperimentalMobileUnit.OnRemoveFromStorage(self, unit)
	end,

	OnKilled = function(self, instigator, type, overkillRatio)
		if self.PullAttached and not self.PullAttached:IsDead() then
			self:LaunchTarget()
		end
		if self.PullingTarget and not self.PullingTarget:IsDead() then
			local targetPosition = self.PullingTarget:GetPosition()
			local bonePosition = self:GetBonePosition(SmashAttach)
			local diffVec = VDiff( bonePosition, targetPosition )
			local proj02 = self.PullingTarget:CreateProjectile('/projectiles/Illuminate/IPullinsmash02/IPullinsmash02_proj.bp',0,0,0,nil,nil,nil)
			self.PullingTarget:DetachFrom(true,true)
			self.PullingTarget:AttachBoneTo(0, proj02, -1 )
			proj02:SetVelocity( diffVec[1], diffVec[2], diffVec[3] )
			proj02:SetVelocity( pullVelocity )
			proj02:SetBallisticAcceleration( -9.8 )
			proj02:SetAttachedUnit( self.PullingTarget )
		end

		self:CleanupActivateEffects()
		self:StopUnitAmbientSound('MagneticLoop')
		ExperimentalMobileUnit.OnKilled(self, instigator, type, overkillRatio)
	end,
}
TypeClass = UIX0115
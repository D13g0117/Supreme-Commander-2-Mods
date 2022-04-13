-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0111/uix0111_deathclaw.lua
--  Author(s): Jessica Snook, Gordon Duclos
--  Summary  : SC2 Illuminate Death Claw Weapon: UIX0111_DeathClaw
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates
local DeathClawCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').DeathClawCollisionBeam

DeathClaw = Class(DefaultBeamWeapon) {

    BeamType = DeathClawCollisionBeam,

    OnCreate = function(self)
        DefaultBeamWeapon.OnCreate(self)
		self.UnitLauncherWeapon = nil
    end,

	SetUnitLauncher = function( self, weapon )
		self.UnitLauncherWeapon = weapon
	end,

    OnDestroy = function(self)
        if not self.TT1 then
            local target = self:GetCurrentTarget()

            if not target or target:BeenDestroyed() then
                return
            end

            local targetUnit = IsUnit(target)
            if not targetUnit or targetUnit:IsDead() then
                return
            end

            --LOG('*DEBUG: unset target')
            targetUnit:SetDoNotTarget(false)
			targetUnit:SetCanTakeDamage(true)
        end
        --LOG('*DEBUG: OnDestroy')
        DefaultBeamWeapon.OnDestroy(self)
    end,

	IdleState = State (DefaultBeamWeapon.IdleState) {
        OnGotTarget = function(self)
            local target = self:GetCurrentTarget()

            if not target or target:BeenDestroyed() then
                return
            end

            local targetUnit = IsUnit(target)
            if not targetUnit or targetUnit:IsDead() then
                return
            end

            if self:IsTargetAlreadyUsed(targetUnit) then
                self:ResetTarget()
                return
            end

            DefaultBeamWeapon.IdleState.OnGotTarget(self)
        end,
    },

    PlayFxBeamStart = function(self, muzzle)
        local target = self:GetCurrentTarget()
        if not target or
            EntityCategoryContains(categories.STRUCTURE, target) or
            EntityCategoryContains(categories.COMMAND, target) or
            EntityCategoryContains(categories.EXPERIMENTAL, target) or
            EntityCategoryContains(categories.NAVAL, target) or
            EntityCategoryContains(categories.SUBCOMMANDER, target) or
            not EntityCategoryContains(categories.ALLUNITS, target) then
            return
        end

        -- Can't pass recon blips down
        target = self:GetRealTarget(target)
		
        if self:IsTargetAlreadyUsed(target) or target.Grabbed then
            self:ResetTarget()
            ChangeState(self, self.IdleState)
            return
        end
		
        -- Create vacuum suck up from ground effects on the unit targetted.
        for k, v in EffectTemplate.CommanderTeleport01 do
            --CreateEmitterAtEntity( target, target:GetArmy(),v ):ScaleEmitter(0.25*target:GetFootPrintSize()/0.5)
        end

        DefaultBeamWeapon.PlayFxBeamStart(self, muzzle)
        target:SetDoNotTarget(true)
		target:SetCanTakeDamage(false)

        target.Grabbed = true

        self.TT1 = self:ForkThread(self.TractorThread, target)
    end,

    -- override this function in the unit to check if another weapon already has this
    -- unit as a target.  Target argument should not be a recon blip
    IsTargetAlreadyUsed = function(self, target)
		--LOG('IsTargetAlreadyUsed')
        local weap
        for i = 1, self.unit:GetWeaponCount() do
            weap = self.unit:GetWeapon(i)
            if (weap != self) then
                if self:GetRealTarget(weap:GetCurrentTarget()) == target then
                    --LOG("Target already used by ", repr(weap:GetBlueprint().Label))
                    return true
                end
            end
        end
        return false
    end,

    -- recon blip check
    GetRealTarget = function(self, target)
		--LOG('GetRealTarget')
        if target and not IsUnit(target) then
            local unitTarget = target:GetSource()
            local unitPos = unitTarget:GetPosition()
            local reconPos = target:GetPosition()
            local dist = VDist2(unitPos[1], unitPos[3], reconPos[1], reconPos[3])
            if dist < 10 then
                return unitTarget
            end
        end
        return target
    end,

--[[
    OnLostTarget = function(self)
		--LOG('OnLostTarget')
        --self:AimManipulatorSetEnabled(true)
        DefaultBeamWeapon.OnLostTarget(self)
        DefaultBeamWeapon.PlayFxBeamEnd(self,self.Beams[1].Beam)
    end,
]]--
    TractorThread = function(self, target)
        self.unit.Trash:Add(target)

        local beam = self.Beams[1].Beam
        if not beam then
            WARN('*DEBUG: No beam for deathclaw')
            return
        end

        local muzzle = self:GetBlueprint().MuzzleSpecial
        if not muzzle then
            WARN('*DEBUG: No muzzle for deathclaw')
            return
        end

        for k, v in EffectTemplate.Weapons.Illuminate_DeathClaw01_Pull01 do
            CreateAttachedEmitter( self.unit, muzzle, self.unit:GetArmy(), v )
        end
        
        target:SetDoNotTarget(true)
		target:SetCanTakeDamage(false)
        local pos0 = beam:GetPosition(0)
        local pos1 = beam:GetPosition(1)
        local dist = VDist3(pos0, pos1)

		self.AimControl:SetFrozen(true)
		
        self.Slider = CreateSlider(self.unit, muzzle, 0, 0, dist, -1, true)
        WaitFor(self.Slider)

        if self.unit:IsDead() or target:IsDead() then 
			self:TractorCleanup()
			return 
		end

		self.unit:DeployClaw(self:GetBlueprint().ClawIndex or 0)

        -- just in case attach fails...
        target:AttachBoneTo(-1, self.unit, muzzle)
        self.Slider:SetSpeed(35):SetGoal(0,0,0)
        WaitFor(self.Slider)

        if self.unit:IsDead() then 
			self:TractorCleanup()
			return 
		end

        if not target:IsDead() then
            -- Turn off weapons on that target
            for i = 1, target:GetWeaponCount() do
                target:GetWeapon(i):SetEnabled(false)
				target:GetWeapon(i):ResetTarget()
            end
	
			-- If this unit is an engineer turn off it's build arm manipulators
			if EntityCategoryContains(categories.ENGINEER, target) then
				target:BuildManipulatorsSetEnabled(false)
			end

			IssueClearCommands({target})

            -- Turn off the death claw so we don't suck up more units
            self:SetEnabled(false)
			self.AimControl:SetEnabled(false)
			self.AimControl:SetFrozen(false)
			self:ResetTarget()

            -- Turn on the unit launcher weapon
			if self.UnitLauncherWeapon then
                local heading,pitch = self.AimControl:GetHeadingPitch()

				self.UnitLauncherWeapon:SetEnabled(true)
				self.UnitLauncherWeapon.AimControl:SetEnabled(true)
                self.UnitLauncherWeapon.AimControl:SetHeadingPitch(heading, pitch)
				target:SetCollisionShape('None', 0, 0, 0, 0)
				self.UnitLauncherWeapon:AddUnitAmmo( target )
			end
			
			if self.Slider then
				self.Slider:Destroy()
				self.Slider = nil
			end
		else
			self:TractorCleanup()
		end
    end,
    
    TractorCleanup = function(self)
		if self.Slider then
			self.Slider:Destroy()
			self.Slider = nil
		end
		if self.AimControl then
			self.AimControl:SetFrozen(false)
		end
    end,
}
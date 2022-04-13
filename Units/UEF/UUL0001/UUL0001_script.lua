-----------------------------------------------------------------------------
--  File     : /units/uef/uul0001/uul0001_script.lua
--  Author(s): Gordon Duclos, Mike Robbins
--  Summary  : SC2 UEF Armored Command Unit: UUL0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local CommanderUnit = import('/lua/sim/commanderunit.lua').CommanderUnit
local BareBonesWeapon = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TurretWeapon = import('/lua/sim/weapon.lua').TurretWeapon

UUL0001 = Class(CommanderUnit) {

    Weapons = {
        BodyYaw = Class(TurretWeapon) {},
        MainGun = Class(DefaultProjectileWeapon) {},
        OverCharge = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.0, 0.0, 0.255 )
            end,		
		},
        AntiAir = Class(DefaultProjectileWeapon) {},
        Artillery = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Base.UUB0104.BaseLaunch01 )
            end,
        },

        TacMissile = Class(DefaultProjectileWeapon) {},
		Torpedo = Class(DefaultProjectileWeapon) {},
        DeathWeapon = Class(BareBonesWeapon) {
            OnFire = function(self)
            end,

            Fire = function(self)
				local bp = self:GetBlueprint()
				local proj = self.unit:CreateProjectile( bp.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
				proj:PassDamageData(self:GetDamageTable())
				proj:PassData(bp.NukeData)
            end,
        },
    },

    OnCreate = function(self, createArgs)
        CommanderUnit.OnCreate(self, createArgs)
        self:SetCapturable(false)
        self.HasJumpJets = false			
		self.HunkerEffectiveness = false
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CommanderUnit.OnStopBeingBuilt(self,builder,layer)
        
        if self:BeenDestroyed() then 
			return 
		end
		
        self:BuildManipulatorsSetEnabled(false)
        self:SetWeaponEnabledByLabel('MainGun', true)
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:SendAnimEvent( 'OnIdle' )
    end,    

    OnPrepareArmToBuild = function(self)
        CommanderUnit.OnPrepareArmToBuild(self)
        
        if self:BeenDestroyed() then 
			return 
		end
        
        -- Enable build manipulators
        self:BuildManipulatorsSetEnabled(true)
		
		-- Set body yaw to the desired direction
		local h,p = self:GetWeaponManipulatorByLabel('BodyYaw'):GetHeadingPitch()
		self:GetBuildArmManipulator(0):SetHeadingPitch( h,0 )
		self:GetWeaponManipulatorByLabel('BodyYaw'):SetHeadingPitch( 0,0 )
		
		-- Disable weapons that share build arm
        self:SetWeaponEnabledByLabel('MainGun', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
		self:GetWeapon('BodyYaw'):AimManipulatorSetEnabled(false)
    end,
    
    ResetCommanderForAttackState = function(self)
		-- Set the build manipulators to be disabled
        self:BuildManipulatorsSetEnabled(false)

		-- Enable weapons appropriately
        self:SetWeaponEnabledByLabel('MainGun', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
		self:GetWeapon('BodyYaw'):AimManipulatorSetEnabled(true)
		
		-- Set the body yaw to the desired direction
		local h,p = self:GetBuildArmManipulator(0):GetHeadingPitch()
		self:GetWeaponManipulatorByLabel('BodyYaw'):SetHeadingPitch( h,0 )    
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
        CommanderUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:ResetCommanderForAttackState()
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
    end,    

    OnStopCapture = function(self, target)
        CommanderUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:ResetCommanderForAttackState()
    end,
    
    OnStopReclaim = function(self, target)
        CommanderUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:ResetCommanderForAttackState()
    end,    

    OnFailedCapture = function(self, target)
        CommanderUnit.OnFailedCapture(self, target)
		self:ResetCommanderForAttackState()
    end,

    OnFailedToBuild = function(self)
        CommanderUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:ResetCommanderForAttackState()
    end,
    
    OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
        CommanderUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
        if upgradeName == "UCA_JUMPJETS" then
			self.HasJumpJets = true
			local layer = self:GetCurrentLayer()
			if layer == 'Seabed' then
				self:RemoveCommandCap('RULEUCC_Jump')
			end
		end
    end,
    
    OnLayerChange = function(self, new, old)
        CommanderUnit.OnLayerChange(self, new, old)
        if self.HasJumpJets then
            if (new == 'Land') then
                self:AddCommandCap('RULEUCC_Jump')
            elseif (new == 'Seabed') then
                self:RemoveCommandCap('RULEUCC_Jump')
            end
        end
    end,

	--[[OnPaused = function(self)
        CommanderUnit.OnPaused(self)
        if self.BuildingUnit then
            CommanderUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            CommanderUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CommanderUnit.OnUnpaused(self)
    end,]]--

	OnUnitJump = function( self, state )
		if state then
			self:StopUnitAmbientSound( 'AmbientMove' )
			self:PlayUnitAmbientSound( 'JumpLoop' )
			self:SetWeaponEnabledByLabel('MainGun', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('BodyYaw', false)
			self:SetAttackerEnableState(false)
			local bones = self:GetBlueprint().Display.JumpjetEffectBones
			if bones then
				self.JumpEffects = {}
				local army = self:GetArmy()
				for k, v in bones do
					table.insert( self.JumpEffects, CreateBeamEmitterOnEntity( self, v, army, '/effects/emitters/units/uef/uul0001/event/jump/uul0001_jumpjet_01_beam_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/uef/uul0001/event/jump/uul0001_jumpjet_02_fire_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/uef/uul0001/event/jump/uul0001_jumpjet_03_smoke_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/uef/uul0001/event/jump/uul0001_jumpjet_04_largesmoke_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/uef/uul0001/event/jump/uul0001_jumpjet_05_smokering_emit.bp') )
				end
			end
			ApplyBuff(self, 'JumpMoveSpeedIncrease02')
		else
			self:StopUnitAmbientSound( 'JumpLoop' )
			self:SetWeaponEnabledByLabel('MainGun', true)
			self:SetWeaponEnabledByLabel('BodyYaw', true)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetAttackerEnableState(true)
			if self.JumpEffects then
				for k, v in self.JumpEffects do
					v:Destroy()
				end
				self.JumpEffects = nil
			end
			RemoveBuff(self, 'JumpMoveSpeedIncrease02')
		end
	end,

	GetMainWeaponLabel = function(self)
		return 'MainGun'
	end,
}
TypeClass = UUL0001
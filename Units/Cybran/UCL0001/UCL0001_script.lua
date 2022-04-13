-----------------------------------------------------------------------------
--  File     : /units/cybran/ucl0001/ucl0001_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Armored Command Unit: UCL0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local CommanderUnit = import('/lua/sim/commanderunit.lua').CommanderUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local BareBonesWeapon = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon

UCL0001 = Class(CommanderUnit) {

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
                if proj and self.unit.KnockbackActive then
                    proj.DamageData.KnockbackDistance = 40
                    proj.DamageData.KnockbackRadius = 3
                end
            end,
            
			PlayFxMuzzleSequence = function(self, muzzle)
				DefaultProjectileWeapon.PlayFxMuzzleSequence(self,muzzle)
                if self.unit.KnockbackActive then
					CreateAttachedEmitter( self.unit, 'UCL0001_T01_B02_Muzzle01', self.unit:GetArmy(), '/effects/emitters/units/cybran/ucl0001/event/knockback/ucl0001_e_kb_01_wave_emit.bp')
					CreateAttachedEmitter( self.unit, 'UCL0001_T01_B02_Muzzle01', self.unit:GetArmy(), '/effects/emitters/units/cybran/ucl0001/event/knockback/ucl0001_e_kb_02_flatwave_emit.bp')
                end
			end,
        },
        OverCharge = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 20, 2, 0.0, 0.0, 0.35 )
            end,
        },
        AntiAir = Class(DefaultProjectileWeapon) {},
        TacMissile = Class(DefaultProjectileWeapon) {},
        Nanobots = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
                if proj and self.unit.KnockbackActive then
                    proj.DamageData.KnockbackDistance = 50
                    proj.DamageData.KnockbackRadius = 4
                end
            end,
        },
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
		self.ShuntEffect = {}
        self.MainWeaponLabel = "MainGun"
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
        CommanderUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel(self.MainWeaponLabel, true)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('Sonar')
    end,    

	GetMainWeaponLabel = function(self)
		return self.MainWeaponLabel
	end,

    OnPrepareArmToBuild = function(self)
        CommanderUnit.OnPrepareArmToBuild(self)
        
        if self:BeenDestroyed() then 
			return 
		end
		
		-- Enable build manipulators
        self:BuildManipulatorsSetEnabled(true)
		
		local h,p = self:GetWeaponManipulatorByLabel(self.MainWeaponLabel):GetHeadingPitch()
		self:GetBuildArmManipulator(0):SetHeadingPitch( h,0 )
		
		-- Disable weapons that share build arm
        self:SetWeaponEnabledByLabel(self.MainWeaponLabel, false)
        self:SetWeaponEnabledByLabel('OverCharge', false)	
    end,
    
    ResetCommanderForAttackState = function(self)
		-- Set the build manipulators to be disabled
        self:BuildManipulatorsSetEnabled(false)

		-- Enable weapons appropriately
        self:SetWeaponEnabledByLabel(self.MainWeaponLabel, true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
		
		-- Set the main gun to the desired direction
		local h,p = self:GetBuildArmManipulator(0):GetHeadingPitch()
		self:GetWeaponManipulatorByLabel(self.MainWeaponLabel):SetHeadingPitch( h,0 )
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
        if self:BeenDestroyed() then return end
        self:ResetCommanderForAttackState()
    end,

    OnFailedToBuild = function(self)
        CommanderUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:ResetCommanderForAttackState()
    end,

    OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
        CommanderUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
        if upgradeName == "CCP_NANOBOTWEAPON" then
            self.MainWeaponLabel = "Nanobots"
		elseif upgradeName == "CCP_DYNAMICPOWERSHUNT" then
			self:ForkThread(self.ShuntWatch)
		elseif upgradeName == "CCA_JUMPJETS" then
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

    --Used to activate Power Shunt - Sorian
    ShuntWatch = function( self )
        while not self:IsDead() do
			WaitSeconds(2)
            local weaponFiring = false

            for i = 1, self:GetWeaponCount() do
                wep = self:GetWeapon(i)
                if wep:WeaponHasTarget() then weaponFiring = true break end
            end

            -- If shunt is already active, check to see if we need to turn it off, 
			-- otherwise if it isn't killing things and idle, then activate powershunt
			if self.ShuntActive then
				if not self:IsIdleState() or weaponFiring then
					self:OnShuntUnit(false)
				end
			else
				if self:IsIdleState() and not weaponFiring then
					self:OnShuntUnit(true)
				end
			end
        end
    end,

    ShuntAttachBones = {
		'UCL0001_Root',
		'UCL0001_RightKnee',
		'UCL0001_LeftKnee',
		'UCL0001_RightShoulder',
		'UCL0001_LeftShoulder',
		'UCL0001_Head',
	},
	
	ShuntGroundEffects = {
		'/effects/emitters/units/cybran/ucl0001/event/powershunt/ucl0001_e_ps_02_groundglow_emit.bp',
		'/effects/emitters/units/cybran/ucl0001/event/powershunt/ucl0001_e_ps_04_groundelectricity_emit.bp',
		'/effects/emitters/units/cybran/ucl0001/event/powershunt/ucl0001_e_ps_05_lines_emit.bp',
		'/effects/emitters/units/cybran/ucl0001/event/powershunt/ucl0001_e_ps_07_electricity_emit.bp',
	},

	OnShuntUnit = function( self, bEnable )
		for k, v in self.ShuntEffect do
			v:Destroy()
		end
		self.ShuntEffect = {}

		if bEnable then
            self:SetProductionPerSecondEnergy(self:GetBlueprint().Economy.ProductionPerSecondEnergyShunt)
            self.ShuntActive = true
			self.ShuntEffect = {}

			local army = self:GetArmy()

		    local myPos = self:GetPosition()
			self.LightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, 0.5, 0, 10, 3, 0.1, -1.0, 0.5 )

			table.insert( self.ShuntEffect, CreateAttachedEmitter( self, 'UCL0001_Root', army, '/effects/emitters/units/cybran/ucl0001/event/powershunt/ucl0001_e_ps_06_core_emit.bp' ) )

			for k, v in self.ShuntAttachBones do
				table.insert( self.ShuntEffect, CreateAttachedEmitter(self, v, army, '/effects/emitters/units/cybran/ucl0001/event/powershunt/ucl0001_e_ps_01_electricity_emit.bp'))
			end

			for kEffect, vEffect in self.ShuntGroundEffects do
				table.insert( self.ShuntEffect, CreateAttachedEmitter( self, -2, army, vEffect ) )
			end
		else
            self.ShuntActive = false
            self:SetProductionPerSecondEnergy(self:GetBlueprint().Economy.ProductionPerSecondEnergy)

            if self.LightHandle then
				DestroyLight(self.LightHandle)
				self.LightHandle = nil
			end
		end
	end,

	OnUnitJump = function( self, state )
		if state then
			self:StopUnitAmbientSound( 'AmbientMove' )
			self:PlayUnitAmbientSound( 'JumpLoop' )
			self:SetWeaponEnabledByLabel(self.MainWeaponLabel, false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetAttackerEnableState(false)
			local bones = self:GetBlueprint().Display.JumpjetEffectBones
			if bones then
				self.JumpEffects = {}
				local army = self:GetArmy()
				for k, v in bones do
					table.insert( self.JumpEffects, CreateBeamEmitterOnEntity( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_01_beam_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_02_smoke_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_03_fire_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_04_largesmoke_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_05_smokering_emit.bp') )
				end
			end

			ApplyBuff(self, 'JumpMoveSpeedIncrease02')
		else
			self:StopUnitAmbientSound( 'JumpLoop' )
			self:SetWeaponEnabledByLabel(self.MainWeaponLabel, true)
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
	
	PlayNISTeleportOutEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in EffectTemplates.GenericTeleportIn01 do
            CreateEmitterAtEntity(self,army,v):ScaleEmitter(1.7)
        end
    end,
    
    -- Knockback activation and persistant effects.
	CreateKnockbackEffects = function( self )
		if not self.KnockbackEffects then
			self.KnockbackEffects = {}
			CreateAttachedEmitter( self, 'UCL0001_T01_B02_Muzzle01', self:GetArmy(), '/effects/emitters/units/cybran/ucl0001/event/knockback/ucl0001_e_kb_03_flash_emit.bp')
			table.insert( self.KnockbackEffects, CreateAttachedEmitter( self, 'UCL0001_T01_B02_Muzzle01', self:GetArmy(), '/effects/emitters/units/cybran/ucl0001/event/knockback/ucl0001_e_kb_04_energy_emit.bp'))
			table.insert( self.KnockbackEffects, CreateAttachedEmitter( self, 'UCL0001_T01_B02_Muzzle01', self:GetArmy(), '/effects/emitters/units/cybran/ucl0001/event/knockback/ucl0001_e_kb_05_electricity_emit.bp'))
		end
	end,
	
	DestroyKnockbackEffects = function( self )
		if self.KnockbackEffects then
			for k, v in self.KnockbackEffects do
				v:Destroy()
			end
		end
		self.KnockbackEffects = nil
	end,	
}
TypeClass = UCL0001
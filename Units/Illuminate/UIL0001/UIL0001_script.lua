-----------------------------------------------------------------------------
--  File     : /units/illuminate/uil0001/uil0001_script.lua
--  Author(s):
--  Summary  : SC2 Illuminate Armored Command Unit: UIL0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local CommanderUnit = import('/lua/sim/commanderunit.lua').CommanderUnit
local AIUtils = import('/lua/ai/aiutilities.lua')
local BareBonesWeapon = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIL0001 = Class( CommanderUnit ) {

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {},
        OverCharge = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 20, 5, 0.0, 0.0, 0.35 )
            end,		
		},
        AntiAir = Class(DefaultProjectileWeapon) {},
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
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
        CommanderUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('MainGun', true)
        self.ShieldEffectsBag = {}

		self.Spinners = {
            Spinner01 = CreateRotator(self, 'UIL0001_LeftGenerator', 'z', nil, 0, 60, 360):SetTargetSpeed(-20),
            Spinner02 = CreateRotator(self, 'UIL0001_RightGenerator', '-z', nil, 0, 60, 360):SetTargetSpeed(-20),
        }
		self.Trash:Add(self.Spinner)
		self:ForkThread( self.SpinnerThread )
    end,    

    OnPrepareArmToBuild = function(self)
        CommanderUnit.OnPrepareArmToBuild(self)
        
        if self:BeenDestroyed() then 
			return 
		end
        
        -- Enable build manipulators
        self:BuildManipulatorsSetEnabled(true)
		
		-- Set body yaw to the desired direction
		local h,p = self:GetWeaponManipulatorByLabel('MainGun'):GetHeadingPitch()
		self:GetBuildArmManipulator(0):SetHeadingPitch( h,0 )
		
		-- Disable weapons that share build arm
        self:SetWeaponEnabledByLabel('MainGun', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
    end,
    
    ResetCommanderForAttackState = function(self)
		-- Set the build manipulators to be disabled
        self:BuildManipulatorsSetEnabled(false)

		-- Enable weapons appropriately
        self:SetWeaponEnabledByLabel('MainGun', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)		
	
		-- Set the main gun to the desired direction
		local h,p = self:GetBuildArmManipulator(0):GetHeadingPitch()
		self:GetWeaponManipulatorByLabel('MainGun'):SetHeadingPitch( h,0 ) 
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
    
    OnRogueNaniteActivate = function(self, abilityBP, state )
        --Spawn nanites
        if state == 'activate' then
            local pos = self:GetPosition()
            CreateUnitHPR('uim0002', self:GetArmy(), pos[1], pos[2], pos[3],  0, 0, 0)
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

	GetMainWeaponLabel = function(self)
		return 'MainGun'
	end,
}
TypeClass = UIL0001
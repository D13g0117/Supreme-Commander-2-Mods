-----------------------------------------------------------------------------
--  File     : /units/uef/uux0114/uux0114_script.lua
--  Author(s): Gordon Duclos, Mike Robbins
--  Summary  : SC2 UEF Experimental Unit Cannon: UUX0114
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalFactoryUnit = import('/lua/sim/ExperimentalFactoryUnit.lua').ExperimentalFactoryUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

local MAX_NUM_UNITS = 21

UUX0114 = Class(ExperimentalFactoryUnit) {

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {
			
			OnCreate = function( self )
				DefaultProjectileWeapon.OnCreate(self)
				self:SetEnabled(false)
			end,

			CreateProjectileAtMuzzle = function(self, muzzle)
				local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
				if proj and self.unit:HasUnitAmmo() then
					local unitAmmo = self.unit:GetUnitAmmo()
					IssueClearCommands({unitAmmo})
					unitAmmo:AttachBoneTo(-2, proj, -1 )
					proj:AddAmmo(unitAmmo)
				end
				
				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 18, 4, 0.0, 0.0, 0.35 )
		        
				-- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Experimental.UUX0114.UnitLaunch01 )
			end,

			PlayRackRecoil = function(self)
				if not self.RecoilAnim then
					self.RecoilAnim = CreateAnimator(self.unit)
					self.RecoilAnim:SetPrecedence(0)
					self.unit.Trash:Add(self.RecoilAnim)
				end
				self.RecoilAnim:PlayAnim('/units/uef/uux0114/uux0114_afire001.sca')
			end,
            
            -- We need to unpause building if the player manually stops firing - Sorian
            OnLostTarget = function(self)
                self.unit:SetPaused(false)
            end,
        },
    },

	OnCreate = function(self, createArgs)
		ExperimentalFactoryUnit.OnCreate(self, createArgs)
		self.UnitAmmo = {
			Loaded = 0,
			Shell01 = {},
			Shell02 = {},
			Shell03 = {},
			Shell04 = {},
			NumUnits = 0,
		}
		self.Sliders = {}
		self.Sliders.Shell01 = CreateSlider( self, 'Shell01', 0, 0, -50, 10, false )
		self.Sliders.Shell02 = CreateSlider( self, 'Shell02', 0, 0, -50, 10, false )
		self.Sliders.Shell03 = CreateSlider( self, 'Shell03', 0, 0, -50, 10, false )
		self.Sliders.Shell04 = CreateSlider( self, 'Shell04', 0, 0, -50, 10, false )

		for k, v in self.Sliders do
			self.Trash:Add(v)
		end
	end,

	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalFactoryUnit.OnStopBeingBuilt(self,builder,layer)
		self.BuildEffects = {}
	end,
	
	AddUnitAmmo = function( self, unit )
		local shellSlot = nil
		local currentSlotIndex = 0

		-- Find the best slot to stuff this sucker into or
		-- add it to the firing position
		if self.UnitAmmo.NumUnits == 0 then
			self.UnitAmmo.Loaded = unit
			unit:AttachBoneTo( 0, self, 'turret01' )
	    elseif table.getn( self.UnitAmmo.Shell01 ) < 5 then
			shellSlot = 'Shell01'
			currentSlotIndex = 1
		elseif table.getn( self.UnitAmmo.Shell02 ) < 5 then
			shellSlot = 'Shell02'
			currentSlotIndex = 2
		elseif table.getn( self.UnitAmmo.Shell03 ) < 5 then
			shellSlot = 'Shell03'
			currentSlotIndex = 3
		elseif table.getn( self.UnitAmmo.Shell04 ) < 5 then
			shellSlot = 'Shell04'
			currentSlotIndex = 4
		end
        
        unit:HideMesh()
        unit:DisableShield()
		unit:SetAttackerEnableState(false)
        unit:SetDoNotTarget(true)
        unit:SetCanTakeDamage(false)			
		unit:SetCapturable(false)
	
		if shellSlot then
			table.insert( self.UnitAmmo[shellSlot], unit )
			local slotBoneName = 'S0' ..  currentSlotIndex .. '_Ref0' .. table.getn( self.UnitAmmo[shellSlot] )
			unit:AttachBoneTo( 0, self, slotBoneName )
			self.Sliders[shellSlot]:SetGoal(0,0, -50 + (table.getn( self.UnitAmmo[shellSlot] ) * 10) )
			self.Sliders[shellSlot]:SetSpeed(20)
		end

		self.UnitAmmo.NumUnits = self.UnitAmmo.NumUnits + 1
	end,

	HasUnitAmmo = function(self)
		return ( self.UnitAmmo.NumUnits != 0 )
	end,

	GetUnitAmmo = function(self)
		-- Get currently loaded unit ammo
		local unitAmmo = self.UnitAmmo.Loaded
		local shellSlot = nil
		self.UnitAmmo.NumUnits = self.UnitAmmo.NumUnits - 1
        self:SetPaused(true)
        
		-- Find next ammo to load
		if table.getn( self.UnitAmmo.Shell04 ) > 0 then
			shellSlot = 'Shell04'
		elseif table.getn( self.UnitAmmo.Shell03 ) > 0 then
			shellSlot = 'Shell03'
		elseif table.getn( self.UnitAmmo.Shell02 ) > 0 then
			shellSlot = 'Shell02'
		elseif table.getn( self.UnitAmmo.Shell01 ) > 0 then
			shellSlot = 'Shell01'
		end

		-- If we have found ammo to load, then load up the cannon with the new ammo
		-- and adjust our sliders to shift units in that slot down.
		if shellSlot then
			self.UnitAmmo.Loaded = self.UnitAmmo[shellSlot][1]
			table.remove( self.UnitAmmo[shellSlot], 1 )
			self.Sliders[shellSlot]:SetGoal(0,0, -50 + (table.getn( self.UnitAmmo[shellSlot] ) * 10) )
			self.Sliders[shellSlot]:SetSpeed(20)
		end

		-- Attach loaded unit to root, for now
		self.UnitAmmo.Loaded:DetachFrom()
		self.UnitAmmo.Loaded:AttachBoneTo( 0, self, 'turret01' )

		-- If we don't have any more ammo, disable the weapon to
		-- make sure firing doesn't interfere with building.
		if not self:HasUnitAmmo() then
			--self:SetWeaponEnabledByLabel( 'MainGun', false )

			local wep = self:GetWeapon('MainGun')
			wep:OnLostTarget()
			wep:OnStopTracking('MainGun')
			wep:SetEnabled(false)

			self:RemoveCommandCap('RULEUCC_Attack')
            IssueClearCommands({self})
            self:SetPaused(false)
        end

        if self:IsBuildDisabled() and self.UnitAmmo.NumUnits < MAX_NUM_UNITS then
            self:SetBuildDisabled(false)
        end

		unitAmmo:DetachFrom()
		return unitAmmo
	end,
    
    OnUnpaused = function(self)
        if self:IsUnitState('Attacking') then
            self:SetPaused(true)
        else
            ExperimentalFactoryUnit.OnUnpaused(self)
        end
    end,
    
	StartBuildFx = function(self, unitBeingBuilt)
	    for k, v in EffectTemplates.Units.UEF.Experimental.UUX0114.UnitBuild01 do
            table.insert( self.BuildEffects, CreateAttachedEmitter( self, 'turret01', self:GetArmy(), v ))
        end
    end,

    StopBuildFx = function(self)
    	for k, v in self.BuildEffects do
			v:Destroy()
		end
		self.BuildEffects = {}
    end,

    OnStopBuild = function(self, unitBeingBuilt, order )
        if self.FactoryBuildFailed or not unitBeingBuilt or unitBeingBuilt:IsDead() then
            return
        end    
        
		-- Callbacks
		ExperimentalFactoryUnit.ClassCallbacks.OnStopBuild:Call( self, unitBeingBuilt )
		self.Callbacks.OnStopBuild:Call( self, unitBeingBuilt )               
        
        if not self:HasUnitAmmo() then
			local wep = self:GetWeapon('MainGun')
			wep:SetEnabled(true)
			self:AddCommandCap('RULEUCC_Attack')
		end

		if not self.FactoryBuildFailed then 
			unitBeingBuilt:DetachFrom()
			self:AddUnitAmmo( unitBeingBuilt )
		end

		self:StopUnitAmbientSound( 'ConstructLoop' )
		self.BuildingUnit = false
        self.unitBeingBuilt = nil
        self:StopBuildFx()
        
        if self.UnitAmmo.NumUnits >= MAX_NUM_UNITS then
            self:SetBuildDisabled(true)
            self:SetPaused(true)
        end
    end,
    
    OnFailedToBuild = function(self)
		ExperimentalFactoryUnit.OnFailedToBuild(self)
		-- If we don't have any more ammo, disable the weapon to
		-- make sure firing doesn't interfere with building.
		if not self:HasUnitAmmo() then
			local wep = self:GetWeapon('MainGun')
			wep:OnLostTarget()
			wep:OnStopTracking('MainGun')
			wep:SetEnabled(false)

			self:RemoveCommandCap('RULEUCC_Attack')
            IssueClearCommands({self})
            self:SetPaused(false)
        end
    end,    

	ClearUnitAmmo = function(self)
        --Destroy all units when the NUC is destroyed (alt-delete) - Sorian
        if self:HasUnitAmmo() then
             if self.UnitAmmo.Loaded and not self.UnitAmmo.Loaded:IsDead() then
                self.UnitAmmo.Loaded:Destroy()
				self.UnitAmmo.Loaded = nil
            end
            local shellSlots = {'Shell01','Shell02','Shell03','Shell04'}
            for _,shellSlot in shellSlots do
                for _,unit in self.UnitAmmo[shellSlot] do
					if unit then
						unit:Destroy()
						unit = nil
					end
                end
            end
        end
		self.UnitAmmo.NumUnits = 0
	end,
    
    OnDestroy = function(self)
		self:ClearUnitAmmo()
        ExperimentalFactoryUnit.OnDestroy(self)
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
        self:ClearUnitAmmo()
        ExperimentalFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}
TypeClass = UUX0114

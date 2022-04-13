-----------------------------------------------------------------------------
--  File     : /units/uef/uux0115/uux0115_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Experimental Disruptor Station: UUX0115
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUX0115 = Class(StructureUnit) {

    ExhaustEffects = {
		'/effects/emitters/units/uef/uux0115/ambient/uux0115_amb_03_steam_emit.bp',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.AmbientEffectsBag = {}
        
        -- Exhaust smoke effects
        for k, v in self.ExhaustEffects do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Turret01', self:GetArmy(), v ) )
        end
    end,
    
    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) { 
            OnCreate = function(self)            
                self.Spinner01 = CreateRotator(self.unit, 'Disk01', 'y', nil)
                self.Spinner02 = CreateRotator(self.unit, 'Disk02', '-y', nil)
                self.Spinner03 = CreateRotator(self.unit, 'Disk03', 'y', nil)
                self.Spinner04 = CreateRotator(self.unit, 'Disk04', '-y', nil)
                
                self.unit.Trash:Add(self.Spinner01)  
                self.unit.Trash:Add(self.Spinner02)   
                self.unit.Trash:Add(self.Spinner03)   
                self.unit.Trash:Add(self.Spinner04)   
                
                self.SpinnerGoal = 180
                      
                DefaultProjectileWeapon.OnCreate(self)
            end,
              
            PlayFxRackReloadSequence = function(self)
                local army = self.unit:GetArmy()
                
                -- Reload effects
                CreateBoneEffects( self.unit, 'Disk01', army, EffectTemplates.Units.UEF.Experimental.UUX0115.Reload01 )
                CreateBoneEffects( self.unit, 'Disk02', army, EffectTemplates.Units.UEF.Experimental.UUX0115.Reload01 )
                CreateBoneEffects( self.unit, 'Disk03', army, EffectTemplates.Units.UEF.Experimental.UUX0115.Reload01 )
                CreateBoneEffects( self.unit, 'Disk04', army, EffectTemplates.Units.UEF.Experimental.UUX0115.Reload01 )

                -- Rotate spinners during reload
		        if self.SpinnerGoal == 180 then
		            self.Spinner01:SetCurrentAngle(0)
		            self.Spinner02:SetCurrentAngle(0)
		            self.Spinner03:SetCurrentAngle(0)
		            self.Spinner04:SetCurrentAngle(0)
                    self.Spinner01:SetGoal(self.SpinnerGoal)
                    self.Spinner02:SetGoal(self.SpinnerGoal)
                    self.Spinner03:SetGoal(self.SpinnerGoal)
                    self.Spinner04:SetGoal(self.SpinnerGoal)
                    self.Spinner01:SetSpeed(100)
                    self.Spinner01:SetAccel(10)
                    self.Spinner02:SetSpeed(100)
                    self.Spinner02:SetAccel(10)
                    self.Spinner03:SetSpeed(100)
                    self.Spinner03:SetAccel(10)
                    self.Spinner04:SetSpeed(100)
                    self.Spinner04:SetAccel(10)
                    self.SpinnerGoal = 360
                elseif self.SpinnerGoal == 360 then
		            self.Spinner01:SetCurrentAngle(180)
		            self.Spinner02:SetCurrentAngle(180)
		            self.Spinner03:SetCurrentAngle(180)
		            self.Spinner04:SetCurrentAngle(180)
                    self.Spinner01:SetGoal(self.SpinnerGoal)
                    self.Spinner02:SetGoal(self.SpinnerGoal)
                    self.Spinner03:SetGoal(self.SpinnerGoal)
                    self.Spinner04:SetGoal(self.SpinnerGoal)
                    self.Spinner01:SetSpeed(100)
                    self.Spinner01:SetAccel(10)
                    self.Spinner02:SetSpeed(100)
                    self.Spinner02:SetAccel(10)
                    self.Spinner03:SetSpeed(100)
                    self.Spinner03:SetAccel(10)
                    self.Spinner04:SetSpeed(100)
                    self.Spinner04:SetAccel(10)
                    self.SpinnerGoal = 180
                else
                    self.Spinner01:SetCurrentAngle(0)
		            self.Spinner02:SetCurrentAngle(0)
		            self.Spinner03:SetCurrentAngle(0)
		            self.Spinner04:SetCurrentAngle(0)
                    self.Spinner01:SetGoal(self.SpinnerGoal)
                    self.Spinner02:SetGoal(self.SpinnerGoal)
                    self.Spinner03:SetGoal(self.SpinnerGoal)
                    self.Spinner04:SetGoal(self.SpinnerGoal)
                    self.Spinner01:SetSpeed(100)
                    self.Spinner01:SetAccel(10)
                    self.Spinner02:SetSpeed(100)
                    self.Spinner02:SetAccel(10)
                    self.Spinner03:SetSpeed(100)
                    self.Spinner03:SetAccel(10)
                    self.Spinner04:SetSpeed(100)
                    self.Spinner04:SetAccel(10)
                    self.SpinnerGoal = 360
                end 
                
                DefaultProjectileWeapon.PlayFxRackReloadSequence(self)
	        end,

            OnWeaponFired = function(self)
                local army = self.unit:GetArmy()
            
                -- Base dust effects when unit fires
	            CreateBoneEffects( self.unit, -2, army, EffectTemplates.Units.UEF.Experimental.UUX0115.BaseLaunch01 )
	            
	            -- Rearward steam on launch
	            CreateBoneEffects( self.unit, 'Turret01', army, EffectTemplates.Units.UEF.Experimental.UUX0115.BaseLaunch02 )
	            
	            -- Single muzzle flash effects, supplements the 4 individual muzzle flashes
	            CreateBoneEffects( self.unit, 'T01_Barrel01', army, EffectTemplates.Units.UEF.Experimental.UUX0115.MuzzleFlashSingle01 )
		        
		        DefaultProjectileWeapon.OnWeaponFired(self)
	        end,
        },
    },
    
	OnActivateDisrutorStation = function(self, abilityBP, state )  
		if state == 'activate' then		
			self:PlayUnitSound('ActivateDisruptor')
			for k, v in EffectTemplates.Units.UEF.Experimental.UUX0115.Activate01 do
                CreateAttachedEmitter( self, 'Turret01', self:GetArmy(), v ) 
            end		
		end
    end,
}
TypeClass = UUX0115
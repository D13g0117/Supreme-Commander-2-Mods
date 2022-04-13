-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucl0104/ucl0104_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Mobile Missile Launcher: UCL0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCL0104 = Class(MobileUnit) {
	DestructionExplosionWaitDelayMin = 0.8,
	DestructionExplosionWaitDelayMax = 0.8,

    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {

            PlayFxWeaponUnpackSequence = function(self)
                local bp = self:GetBlueprint()
                local unitBP = self.unit:GetBlueprint()
                if unitBP.Audio.Activate then
                    self:PlaySound(unitBP.Audio.Activate)
                end
                if unitBP.Audio.Open then
                    self:PlaySound(unitBP.Audio.Open)
                end
                if bp.Audio.Unpack then
                    self:PlaySound(bp.Audio.Unpack)
                end
                self.unit:CustomUnpack(true)
                WaitSeconds(2)
            end,

            PlayFxWeaponPackSequence = function(self)
                local bp = self:GetBlueprint()
                local unitBP = self.unit:GetBlueprint()
                if unitBP.Audio.Close then
                    self:PlaySound(unitBP.Audio.Close)
                end
                self.unit:CustomUnpack(false)
                WaitSeconds(2)
            end,
    
        	IdleState = State {
				OnGotTarget = function(self)
					self.unit.SpinnerTarget = true
					DefaultProjectileWeapon.IdleState.OnGotTarget(self)
				end,
			},
		},
    },
    
    CustomUnpack = function(self, unpackBool)
        if unpackBool then
            self.CustomUnpackSpinners.Spinner1:SetGoal(90)
            self.CustomUnpackSpinners.Spinner2:SetGoal(155)
            self.CustomUnpackSpinners.Spinner3:SetGoal(13.250)
            self.CustomUnpackSpinners.Spinner4:SetGoal(13.250)
        else
            self.CustomUnpackSpinners.Spinner1:SetGoal(0)
            self.CustomUnpackSpinners.Spinner2:SetGoal(0)
            self.CustomUnpackSpinners.Spinner3:SetGoal(0)
            self.CustomUnpackSpinners.Spinner4:SetGoal(0)
        end
    end,

	OnStopBeingBuilt = function(self,builder,layer)
		MobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.Spinners = {
            Spinner1 = CreateRotator(self, 'T01_Barrel01', 'z', nil, 0, 60, 360):SetTargetSpeed(105),
            Spinner2 = CreateRotator(self, 'T01_Barrel02', '-z', nil, 0, 30, 360):SetTargetSpeed(105),
        }
        self.CustomUnpackSpinners = {
            -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
            Spinner1 = CreateRotator(self, 'UCL0104_Body', '-y', 0, 100, 50),
            Spinner2 = CreateRotator(self, 'Turret01', 'y', 0, 100, 50),
            Spinner3 = CreateRotator(self, 'T01_Arm01', '-y', 0, 100, 50),
            Spinner4 = CreateRotator(self, 'T01_Arm02', 'y', 0, 100, 50),
        }
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )
	end,

    SpinnerThread = function(self)
		while not self:IsDead() do
			if self.SpinnerTarget then
				self.Spinners.Spinner1:SetTargetSpeed(105)
				self.Spinners.Spinner2:SetTargetSpeed(105)
				self.SpinnerTarget = false
				WaitSeconds(5)
				self.Spinners.Spinner1:SetTargetSpeed(10)
				self.Spinners.Spinner2:SetTargetSpeed(10)
			else
				WaitSeconds(1)
			end
		end
	end,
}
TypeClass = UCL0104
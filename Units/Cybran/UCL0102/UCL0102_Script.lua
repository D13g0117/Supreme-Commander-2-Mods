-----------------------------------------------------------------------------
--  File     : /units/cybran/ucl0102/ucl0102_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Cybran Artillery Bot: UCL0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local GetRandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Entity = import('/lua/sim/Entity.lua').Entity

UCL0102 = Class(MobileUnit) {
	DestructionExplosionWaitDelayMin = 0.6,
	DestructionExplosionWaitDelayMax = 0.6,

    Weapons = {
		Artillery01 = Class(DefaultProjectileWeapon) {
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
		},
    },
    
    CustomUnpack = function(self, unpackBool)
        if unpackBool then
            self.CustomUnpackSpinners.Spinner1:SetGoal(180)
            self.CustomUnpackSpinners.Spinner2:SetGoal(180)
            self.CustomUnpackSpinners.Spinner3:SetGoal(65)
        else
			for k, v in self.CustomUnpackSpinners do
				v:SetGoal(0)
			end
        end
    end,
    
	OnStopBeingBuilt = function(self,builder,layer)
		MobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.CustomUnpackSpinners = {
            -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
            Spinner1 = CreateRotator(self, 'UCL0102_Body', '-x', 0, 100, 50),
            Spinner2 = CreateRotator(self, 'UCL0102_Turret01', 'y', 0, 100, 50),
            Spinner3 = CreateRotator(self, 'UCL0102_T01_Barrel01', '-x', 0, 100, 50),
        }

		for k, v in self.CustomUnpackSpinners do
			self.Trash:Add(v)
		end
	end,
}
TypeClass = UCL0102
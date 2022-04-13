-----------------------------------------------------------------------------
--  File     : /units/uef/uub0107/uub0107_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF ICBM Launch Facility: UUB0107
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local NukeWeapon = import('/lua/sim/DefaultWeapons.lua').NukeWeapon

UUB0107 = Class(StructureUnit) {
    Weapons = {
        NukeMissiles = Class(NukeWeapon) {},
        TacticalMissile01 = Class(DefaultProjectileWeapon) {

			OnCreate = function(self)
				DefaultProjectileWeapon.OnCreate(self)
				
				self.HatchRotators = {
					-- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
					{	Rotator = CreateRotator(self.unit, 'T01_Hatch01', 'z', 0, 100, 60 ), Goal = -90, },
					{	Rotator = CreateRotator(self.unit, 'T01_Hatch02', 'z', 0, 100, 60 ), Goal = 90, },
					{	Rotator = CreateRotator(self.unit, 'T01_Hatch03', 'z', 0, 100, 60 ), Goal = -90, },
					{	Rotator = CreateRotator(self.unit, 'T01_Hatch04', 'z', 0, 100, 60 ), Goal = 90, },
				}

				for k, v in self.HatchRotators do
					self.unit.Trash:Add( v.Rotator )
				end
			end,

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
                for k, v in self.HatchRotators do
					v.Rotator:SetGoal(v.Goal)
				end
                WaitSeconds(2)
            end,

            PlayFxWeaponPackSequence = function(self)
                local bp = self:GetBlueprint()
                local unitBP = self.unit:GetBlueprint()
                if unitBP.Audio.Close then
                    self:PlaySound(unitBP.Audio.Close)
                end
                for k, v in self.HatchRotators do
					v.Rotator:SetGoal(0)
				end
                WaitSeconds(2)
            end,			
		},
    },

    OnStopBeingBuilt = function(self,builder,layer)
		StructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.Trash:Add( CreateRotator(self, 'Radar01', 'y', nil, 0, 60, 360):SetTargetSpeed(-30) )
		self.Trash:Add( CreateRotator(self, 'Radar02', 'y', nil, 0, 60, 360):SetTargetSpeed(36) )
	end,
}
TypeClass = UUB0107
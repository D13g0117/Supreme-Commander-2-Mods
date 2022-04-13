-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0107/uib0107_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate ICBM Launch Facility: UIB0107
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local NukeWeapon = import('/lua/sim/DefaultWeapons.lua').NukeWeapon

UIB0107 = Class(StructureUnit) {
    Weapons = {
        StrategicMissile01 = Class(NukeWeapon) {
			BoneSet01 = {
				{ Bone = 'Leg01', Axis = 'x', Angle = -80 },
				{ Bone = 'Leg02', Axis = 'x', Angle = -80 },
				{ Bone = 'Leg03', Axis = 'x', Angle = -80 },
				{ Bone = 'Leg04', Axis = 'x', Angle = 80 },
				{ Bone = 'Leg05', Axis = 'x', Angle = -80 },
				{ Bone = 'Leg06', Axis = 'x', Angle = -80 },
				{ Bone = 'Leg07', Axis = 'x', Angle = -80 },
				{ Bone = 'Leg08', Axis = 'x', Angle = -80 },
				{ Bone = 'Door01', Axis = 'x', Angle = 70 },
				{ Bone = 'Door02', Axis = 'x', Angle = 70 },
				{ Bone = 'Door03', Axis = 'x', Angle = 70 },
				{ Bone = 'Door04', Axis = 'x', Angle = 70 },
				{ Bone = 'Door05', Axis = 'x', Angle = 70 },
				{ Bone = 'Door06', Axis = 'x', Angle = 70 },
				{ Bone = 'Door07', Axis = 'z', Angle = 70 },
				{ Bone = 'Door08', Axis = 'x', Angle = 70 },
			},

			OnCreate = function(self)
				NukeWeapon.OnCreate(self)

				self.Rotators01 = {}
	
				for k, v in self.BoneSet01 do
					local rotator = CreateRotator(self.unit, v.Bone, v.Axis, 0, 60, 20 )
					table.insert( self.Rotators01, { Rotator = rotator, Goal = v.Angle } )
					self.unit.Trash:Add( rotator )
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
                for k, v in self.Rotators01 do
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
                for k, v in self.Rotators01 do
					v.Rotator:SetGoal(0)
				end
                WaitSeconds(2)
            end,
        },
    },
}
TypeClass = UIB0107
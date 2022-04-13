-----------------------------------------------------------------------------
--  File     : /units/uef/uub0203/uub0203_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Tactical/ICBM Combo Defense: UUB0203
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUB0203 = Class(StructureUnit) {
    Weapons = {
        AntiTacticalMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam,
		},
        AntiStrategicMissile01 = Class(DefaultProjectileWeapon) {
			BoneSet01 = {
				{ Bone = 'UUB0203_silodoor_09', Axis = 'y', Angle = 60 },
				{ Bone = 'UUB0203_silodoor_10', Axis = 'x', Angle = 60 },
				{ Bone = 'UUB0203_silodoor_11', Axis = 'y', Angle = -60 },
				{ Bone = 'UUB0203_silodoor_12', Axis = 'x', Angle = -60 },
			},

			OnCreate = function(self)
				DefaultProjectileWeapon.OnCreate(self)
	
				for k, v in self.BoneSet01 do
					local rotator = CreateRotator(self.unit, v.Bone, v.Axis, 0, 160, 120 ):SetGoal(v.Angle)
					self.unit.Trash:Add( rotator )
				end
			end,
			
            
			CreateProjectileForWeapon = function(self, bone)
				DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
				self:ResetTarget()
			end,              
        },		
    },
}
TypeClass = UUB0203
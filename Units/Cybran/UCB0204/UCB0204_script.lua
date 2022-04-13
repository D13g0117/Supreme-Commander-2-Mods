-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0204/ucb0204_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Missile Launch/Defense Combo: UCB0204
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

CustomHatchSiloWeapon = Class(DefaultProjectileWeapon) {

	HatchBones = {},
	PackTime = 2,
	PackingSetBusy = false,

	OnCreate = function(self)
		DefaultProjectileWeapon.OnCreate(self)
		self.HatchRotators = {}
		for k, v in self.HatchBones do
			local rotator = CreateRotator(self.unit, v, 'x', 0, 100, 60 )
			table.insert( self.HatchRotators, rotator )
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
		for k, v in self.HatchRotators do
			v:SetGoal(-60)
		end
		WaitSeconds(self.PackTime)
    end,

    PlayFxWeaponPackSequence = function(self)
		local bp = self:GetBlueprint()
		local unitBP = self.unit:GetBlueprint()
		if unitBP.Audio.Close then
			self:PlaySound(unitBP.Audio.Close)
		end
		for k, v in self.HatchRotators do
			v:SetGoal(0)
		end
		WaitSeconds(self.PackTime)
    end,
}

UCB0204 = Class(StructureUnit) {
    Weapons = {
        StrategicMissile01 = Class(CustomHatchSiloWeapon) {
			HatchBones = {
				'Bay01_Door01',
				'Bay01_Door02',
				'Bay01_Door03',
				'Bay01_Door04',
				'Bay01_Door05',
				'Bay01_Door06',
			},
			
			CreateProjectileForWeapon = function(self, bone)
				local proj = DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
				if proj and not proj:BeenDestroyed() then
					local bp = self:GetBlueprint()
					if bp.NukeData then
						proj:PassData(bp.NukeData)
					end
				end
				return proj
			end,			
		},
        TacticalMissile01 = Class(CustomHatchSiloWeapon) {
			HatchBones = {
				'Bay02_Door01',
				'Bay02_Door02',
				'Bay02_Door03',
				'Bay02_Door04',
				'Bay02_Door05',
				'Bay02_Door06',
			},	
		},
        AntiStrategicMissile01 = Class(DefaultProjectileWeapon) {
			HatchBones = {
				'Bay03_Door01',
				'Bay03_Door02',
				'Bay03_Door03',
				'Bay03_Door04',
				'Bay03_Door05',
				'Bay03_Door06',
			},	
		
			OnEnableWeapon = function(self, enable)
				DefaultProjectileWeapon.OnEnableWeapon(self, enable)
				if enable then
					for k, v in self.HatchBones do
						local rotator = CreateRotator(self.unit, v, 'x', 0, 100, 60 ):SetGoal(-60)
						self.unit.Trash:Add( rotator )
					end
				end
			end,	
					
			CreateProjectileForWeapon = function(self, bone)
				DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
				self:ResetTarget()
			end,  			
		},
    },
}
TypeClass = UCB0204
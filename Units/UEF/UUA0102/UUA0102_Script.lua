-----------------------------------------------------------------------------
--  File     : /units/uef/uua0102/uua0102_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Bomber: UUA0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local BOMBCAMERADURATION = 20
local BOMBCAMERADURATIONUPGRADE = 40 -- If you modify this value, make sure to modify RB_UAB_BOMBCAMERADURATIONDUMMYBUFF
									 -- in ResearchBuffDefinitions.lua otherwise the research tooltip will be out of sync!!!!!

local BombWeapon = Class(DefaultProjectileWeapon) {

	OnCreate = function(self, inWater)
		DefaultProjectileWeapon.OnCreate(self, inWater)
		self.BombCounter = 0
	end,

    CreateProjectileForWeapon = function(self, bone)
        local blueprint = self:GetBlueprint()
        local projectile = self:CreateProjectile(bone)
        local damageTable = self:GetDamageTable()

		if self.unit.BombCamera then
			self.BombCounter = self.BombCounter + 1

			if self.BombCounter <= 1 then
				projectile:SetBombCamera( true, self.unit.BombCameraDuration )
			end

			if self.BombCounter == blueprint.MuzzleSalvoSize then
				self.BombCounter = 0
			end
		end

        local data = {
            Instigator = self.unit,
            Damage = blueprint.DoTDamage,
            Duration = blueprint.DoTDuration,
            Frequency = blueprint.DoTFrequency,
            Radius = blueprint.DamageRadius,
            Type = 'Normal',
            DamageFriendly = blueprint.DamageFriendly,
        }
        if projectile and not projectile:BeenDestroyed() then
            projectile:PassData(data)
            projectile:PassDamageData(damageTable)
        end
        return projectile
    end,
}

UUA0102 = Class(AirUnit) {

    BeamExhaustCruise = {'/effects/emitters/units/uef/general/gunship_thruster_beam_01_emit.bp'},
    BeamExhaustIdle = {'/effects/emitters/units/uef/general/gunship_thruster_beam_02_emit.bp'},

    Weapons = {
        Bomb01 = Class(BombWeapon) {},
        Bomb02 = Class(BombWeapon) {},
        Torpedo01 = Class(DefaultProjectileWeapon) {},
    },

	OnCreate = function(self, createArgs)
		AirUnit.OnCreate(self, createArgs)
		self.BombCamera = false
		self.BombCameraDuration = BOMBCAMERADURATION
	end,

	OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
		AirUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
		if upgradeName == 'UAB_BOMBCAMERADURATION' then
			self.BombCameraDuration = BOMBCAMERADURATIONUPGRADE
		end
	end,
}
TypeClass = UUA0102
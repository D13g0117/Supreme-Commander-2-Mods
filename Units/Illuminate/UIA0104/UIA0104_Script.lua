-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uia0104/uia0104_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Fighter/Bomber: UIA0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TargetCategory = categories.MOBILE - categories.COMMAND - categories.EXPERIMENTAL - categories.TRANSPORTATION

UIA0104 = Class(AirUnit) {
	ContrailEffects = {
	},

	BeamExhaustCruise = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_05_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_06_emit.bp',
	},
	BeamExhaustIdle = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_07_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_08_emit.bp',
	},

    OnStopBeingBuilt = function(self, creator, layer)
    	AirUnit.OnStopBeingBuilt(self, creator, layer)
        local bp = self:GetBlueprint()
        self.BomberSpeedMult = bp.Air.BomberSpeedMult or 0.67
    end,

	OnAttackerSetDesiredTarget = function(self, target)
		if EntityCategoryContains( categories.AIR - categories.STRUCTURE, target ) then
			--LOG('Entered Fighter mode')
            self:SetBreakOffTriggerMult(0.5)
            self:SetBreakOffDistanceMult(0.15)
            self:SetSpeedMult(1.0)
            self:SetTurnMult(0.33)
            self:SetTurnDampingMult(0.21)
		else
			--LOG('Entered Bomber mode')
            self:SetBreakOffTriggerMult(1.0)
            self:SetBreakOffDistanceMult(1.0)
            self:SetSpeedMult(self.BomberSpeedMult)
            self:SetTurnMult(1)
            self:SetTurnDampingMult(1)
		end
	end,

    Weapons = {
        AAGun01 = Class(DefaultProjectileWeapon) {},
        Bomb01 = Class(DefaultProjectileWeapon) {},
        Bomb02 = Class(DefaultProjectileWeapon) {
            CreateProjectileForWeapon = function(self, bone)
                local projectile = self:CreateProjectile(bone)
                local damageTable = self:GetDamageTable()
                local blueprint = self:GetBlueprint()
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
        },
        AntiMissile = Class(DefaultProjectileWeapon) {
			CreateProjectileAtMuzzle = function(self, muzzle)
				local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
				if proj then
					local bp = self:GetBlueprint()
					if bp.Flare then
						proj:AddFlare(bp.Flare)
					end
				end
			end,
        },
    },
}
TypeClass = UIA0104
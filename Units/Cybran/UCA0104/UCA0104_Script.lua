-----------------------------------------------------------------------------
--  File     : /units/cybran/uca0104/uca0104_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Fighter/Bomber: UCA0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCA0104 = Class(AirUnit) {

	BeamExhaustCruise = {'/effects/emitters/units/cybran/general/cybran_gunship_thruster_beam_02_emit.bp',},
	BeamExhaustIdle = {'/effects/emitters/units/cybran/general/cybran_gunship_thruster_beam_01_emit.bp',},

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
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        Bomb01 = Class(DefaultProjectileWeapon) {},
    },
}
TypeClass = UCA0104
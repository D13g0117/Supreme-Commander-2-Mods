-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb9001/scb9001.lua
--  Author(s):	Chris Daroza
--  Summary  :  Tech Cache: SCB9001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB9001 = Class(StructureUnit) {

	RewardValue = 3,

    AmbientEffects = {
		'/effects/emitters/units/scenario/scb9001/ambient/scb9001_amb_01_glow_emit.bp',
		'/effects/emitters/units/scenario/scb9001/ambient/scb9001_amb_02_lines_emit.bp',
		'/effects/emitters/units/scenario/scb9001/ambient/scb9001_amb_03_flatglow_emit.bp',
    },

    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}

		self:SetReclaimable(false)
		self:SetCapturable(false)

        -- Ambient effects
		for kEffect, vEffect in self.AmbientEffects do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), vEffect ) )
		end

    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio)
		if instigator and IsUnit(instigator) then
			---NOTE: instead of setting the army index to the killing unit army - assume we want the player - bfricks 1/4/10
			--local armyIndex = instigator:GetArmy()
			local armyIndex = 1
			import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').AwardBonusResearchPoints(self.RewardValue, armyIndex, 1.0, true)
		end
    end,
}
TypeClass = SCB9001
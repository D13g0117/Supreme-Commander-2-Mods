-----------------------------------------------------------------------------
--  File     : /units/illuminate/uil0202/uil0202_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Armor Booster: UIL0202
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local HoverUnit = import('/lua/sim/HoverUnit.lua').HoverUnit
local AURA_PULSE_TIME = 6

UIL0202 = Class(HoverUnit) {

    OnCreate = function(self, createArgs)
		HoverUnit.OnCreate(self, createArgs)

        self.Spinners = {
            Spinner1 = CreateRotator(self, 'ArmorBooster01', 'y', nil, -20, 60, -20),
            Spinner2 = CreateRotator(self, 'ArmorBooster02', 'y', nil, -20, 30, -20),
            Spinner3 = CreateRotator(self, 'ArmorBooster03', 'y', nil, 20, 60, 20),
        }
        for k, v in self.Spinners do
            self.Trash:Add(v)
        end
        local bp = self:GetBlueprint()
        self.IsSkirmish = bp.General.IsSkirmish or false
        self.AuraRadius = bp.General.AuraRadius or 20
	end,

    OnStopBeingBuilt = function(self,builder,layer)
        HoverUnit.OnStopBeingBuilt(self,builder,layer)
		self:ForkThread( self.AuraThread )
    end,

	AuraThread = function(self)
		local targets
		while not self:IsDead() do
			local aiBrain = self:GetAIBrain()
			targets = {}
			targets = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS - categories.EXPERIMENTAL - categories.COMMAND, self:GetPosition(), self.AuraRadius, 'Ally' )
			for k, v in targets do
				if v != self and not v:IsBeingBuilt() then
					if self.IsSkirmish then
						ApplyBuff( v, 'ArmorEnhancementSkirmish', self )
					else
						ApplyBuff( v, 'ArmorEnhancement', self )
					end

					-- Removed for perf
					--for kEffect, vEffect in EffectTemplates.Units.Illuminate.Land.UIL0202.UIL0202BuffEffectsMed01 do
					--	CreateEmitterAtEntity( v, v:GetArmy(), vEffect )
					--end

				end
			end
			WaitSeconds(AURA_PULSE_TIME)
		end
	end,
}
TypeClass = UIL0202
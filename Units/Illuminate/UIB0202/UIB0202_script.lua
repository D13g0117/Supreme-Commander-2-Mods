-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uib0202/uib0202_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 UIB0202: Illuminate Shield Structure
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local ABSORB_ENERGY_SPONGE_PERCENT = 0.0125

UIB0202 = Class(StructureUnit) {

    ShieldEffects = {
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_05_glow_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_06_upwardwisps_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_07_plasmacore_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_08_corewisps_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_09_ring_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_10_groundring_emit.bp',
    },

    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
	end,

	OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
		StructureUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
		if upgradeName == 'IBP_SHIELDENERGYSPONGE' then
			local shield = self:GetShield()
			if shield then
				shield:SetAbsorbEnergySpongePercent( ABSORB_ENERGY_SPONGE_PERCENT )
			end
		end
	end,

    OnShieldEnabled = function(self)
        StructureUnit.OnShieldEnabled(self)
		if self.AnimationManipulator then
			self.AnimationManipulator:SetRate(1)
		end

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end

		self.Spinner = CreateRotator(self, 'UIB0202_Ring02', 'y', nil, 0, 60, 360):SetTargetSpeed(-10)
		self.Trash:Add(self.Spinner)
    end,

    OnShieldDisabled = function(self)
        StructureUnit.OnShieldDisabled(self)
		if self.AnimationManipulator then
			self.AnimationManipulator:SetRate(-1)
		end

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio)
        if self.ShieldEffctsBag then
            for k,v in self.ShieldEffectsBag do
                v:Destroy()
            end
        end
    end,
}
TypeClass = UIB0202
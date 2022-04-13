-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucb0202/ucb0202_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Shield Generator: UCB0202
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UCB0202 = Class(StructureUnit) {

    ShieldEffects = {
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_01_emit.bp', -- glow
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_02_emit.bp', -- core
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_03_emit.bp', -- wisps
		'/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_02_ring_emit.bp',
		'/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_03_groundring_emit.bp',
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_04_wisps_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
	end,
	
    OnShieldEnabled = function(self)
        self:PlayUnitSound('ShieldOn')
        StructureUnit.OnShieldEnabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end
        
    end,
    
    OnShieldDisabled = function(self)
        self:PlayUnitSound('ShieldOff')
        StructureUnit.OnShieldDisabled(self)
    
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
}
TypeClass = UCB0202
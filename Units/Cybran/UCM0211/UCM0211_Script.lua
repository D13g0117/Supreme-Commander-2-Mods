-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucm0211/ucm0211_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Shield Upgrade: UCM0211
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UCM0211 = Class(StructureUnit) {

	ShieldEffects = {
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_01_emit.bp', -- glow
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_02_emit.bp', -- core
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_03_emit.bp', -- wisps
		'/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_02_ring_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
		self:SetCapturable(false)
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)
		StructureUnit.OnStopBeingBuilt(self,builder,layer)
		if self.UpgradeParent then
			self.UpgradeParent:CreateShield()
		end
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
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ):OffsetEmitter(0, -4, 0) )
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
TypeClass = UCM0211
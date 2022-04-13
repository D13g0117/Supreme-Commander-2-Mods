-----------------------------------------------------------------------------
--  File     : /units/uef/uub0202/uub0202_script.lua
--  Author(s):
--  Summary  : SC2 UEF Shield Generator: UUB0202
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UUB0202 = Class(StructureUnit) {

    ShieldEffects = {
		'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_01_glow_emit.bp',
		'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_03_rings_emit.bp',
		'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_04_core_emit.bp',
		'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_05_wisps_emit.bp',
		'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_06_ring_emit.bp',
		'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_07_groundring_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
	end,
	
    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.Trash:Add( CreateRotator(self, 'tower', 'z', nil, 0, 50, 10) )
		self.Trash:Add( CreateRotator(self, 'ring', 'z', nil, 0, 40, -70) )
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
TypeClass = UUB0202
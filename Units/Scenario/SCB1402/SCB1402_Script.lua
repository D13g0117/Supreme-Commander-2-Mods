-----------------------------------------------------------------------------
--  File     : /units/uef/scb1402/scb1402_script.lua
--  Author(s): Gordon Duclos
--  Summary  : U04 Custom UEF Gantry
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalGantryUnit = import('/lua/sim/ExperimentalGantryUnit.lua').ExperimentalGantryUnit
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates


SCB1402 = Class(ExperimentalGantryUnit) {

	StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0011/event/build/uef_expfactory_02_smoke_emit.bp' ))
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0011/event/build/uef_expfactory_03_sparks_emit.bp' ))
		self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0011/event/build/uef_expfactory_04_flash_emit.bp' ))
		self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0011/event/build/uef_expfactory_05_line_emit.bp' ))
    end,	
    
	OnAnimEndTrigger = function( self, event )
		ExperimentalGantryUnit.OnAnimEndTrigger( self, event )

		if event == 'FinishBuild' then
			for k, v in EffectTemplate.UEFExperimentalFactoryBuildEffects01 do
			   CreateAttachedEmitter( self, 'UUB0011', self:GetArmy(), v )
			end
		end
	end,

}
TypeClass = SCB1402

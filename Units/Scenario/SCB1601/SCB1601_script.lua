-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb1601/scb1601_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Reactor Core: SCB1601
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB1601 = Class(StructureUnit) {

    AmbientEffects = {
		'/effects/emitters/units/scenario/scb1601/ambient/scb1601_a_01_steam_emit.bp',
		'/effects/emitters/units/scenario/scb1601/ambient/scb1601_a_02_glow_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- Ambient effects
        for k, v in self.AmbientEffects do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), v ) )
        end
    end,
    
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(5.0)
		end
     
        self:CreateWreckage(0.1)
        		
		WaitSeconds(1.0)
        
        self:Destroy()
    end,
}
TypeClass = SCB1601
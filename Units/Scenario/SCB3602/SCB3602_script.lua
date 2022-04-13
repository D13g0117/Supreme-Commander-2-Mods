-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb3602/scb3602.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Drone Spawner: SCB3602
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB3602 = Class(StructureUnit) {

	AmbientEffects = {
		'/effects/emitters/units/scenario/scb3602/ambient/scb3602_a_01_ring_emit.bp',
		'/effects/emitters/units/scenario/scb3602/ambient/scb3602_a_02_glow_emit.bp',
		'/effects/emitters/units/scenario/scb3602/ambient/scb3602_a_03_fastlines_emit.bp',
		'/effects/emitters/units/scenario/scb3602/ambient/scb3602_a_04_line_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- Core effects
		for k, v in self.AmbientEffects do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Platform01', self:GetArmy(), v ) )
		end
    end,
    
    DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects		
        		for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(1.2)
		end
				
        self:CreateWreckage(0.1)
                 		
		WaitSeconds(0.5)
        
        self:Destroy()
    end,
}
TypeClass = SCB3602
-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb3101/scb3101_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  Brackman Teleporter: SCB3101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB3101 = Class(StructureUnit) {

    AmbientEffectBones = {
		'Prong01',
		'Prong02',
		'Prong03',
		'Prong04',
		'Prong05',
		'Prong06',
		'Prong07',
		'Prong08',
    },
    
    AmbientEffects = {
		'/effects/emitters/units/scenario/scb3101/ambient/scb3101_amb_01_glow_emit.bp',
		'/effects/emitters/units/scenario/scb3101/ambient/scb3101_amb_02_flatglow_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- Ambient effects
        for k, v in self.AmbientEffectBones do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, v, self:GetArmy(), '/effects/emitters/units/scenario/scb3101/ambient/scb3101_amb_03_lines_emit.bp' ) )
        end
        
		for k, v in self.AmbientEffects do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), v ) )
        end
    end,
    
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(1.5)
		end
     
        self:CreateWreckage(0.1)
        		
		WaitSeconds(0.5)
        
        self:Destroy()
    end,
    
}
TypeClass = SCB3101
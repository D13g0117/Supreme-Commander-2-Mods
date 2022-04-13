-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb1101/scb1101_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Communications Array: SCB1101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB1101 = Class(StructureUnit) {

	LightAttachBones = {
		'EffectPoint01',
		'EffectPoint02',
		'EffectPoint03',
		'EffectPoint04',
	},
	
    AmbientEffects = {
		'/effects/emitters/units/scenario/scb1101/ambient/scb1101_a_01_electricity_emit.bp',
		'/effects/emitters/units/scenario/scb1101/ambient/scb1101_a_02_glow_emit.bp',
		'/effects/emitters/units/scenario/scb1101/ambient/scb1101_a_03_ring_emit.bp',
    },
    
	BlinkingLights = {
		'/effects/emitters/units/scenario/scb1101/ambient/scb1101_a_04_blinkinglight_emit.bp',
		'/effects/emitters/units/scenario/scb1101/ambient/scb1101_a_05_streak_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- Ambient effects
        for k, v in self.AmbientEffects do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Commarray01', self:GetArmy(), v ) )
        end
        -- Blinking lights
        for kBone, vBone in self.LightAttachBones do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, vBone, self:GetArmy(), '/effects/emitters/units/scenario/scb1101/ambient/scb1101_a_04_blinkinglight_emit.bp' ) )
        end
        
    end,
    
}
TypeClass = SCB1101
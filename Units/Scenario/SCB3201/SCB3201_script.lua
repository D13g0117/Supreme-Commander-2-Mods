-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb3201/scb3201_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Research Station: SCB3201
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB3201 = Class(StructureUnit) {

    AmbientEffectBones = {
		'Effect02',
		'Effect03',
		'Effect04',
		'Effect05',
		'Effect06',
		'Effect07',
		'Effect08',
		'Effect09',
    },
    
    AmbientEffects = {
		'/effects/emitters/units/scenario/scb3201/ambient/scb3201_amb_01_ring_emit.bp',
		'/effects/emitters/units/scenario/scb3201/ambient/scb3201_amb_03_ring_emit.bp',
		'/effects/emitters/units/scenario/scb3201/ambient/scb3201_amb_04_hologram_emit.bp',
		'/effects/emitters/units/scenario/scb3201/ambient/scb3201_amb_06_light_emit.bp',
		'/effects/emitters/units/scenario/scb3201/ambient/scb3201_amb_07_glow_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- Ambient effects
        for k, v in self.AmbientEffectBones do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, v, self:GetArmy(), '/effects/emitters/units/scenario/scb3201/ambient/scb3201_amb_05_steam_emit.bp' ) )
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
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v )
		end
     
        self:CreateWreckage(0.1)
        		
		WaitSeconds(0.5)
        
        self:Destroy()
    end,
    
}
TypeClass = SCB3201
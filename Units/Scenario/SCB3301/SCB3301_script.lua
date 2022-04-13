-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb3301/scb3301_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Quantum Research Laboratories: SCB3301
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB3301 = Class(StructureUnit) {

    AmbientEffectBones = {
		'Effect07',
		'Effect08',
		'Effect09',
		'Effect10',
    },
    
    AmbientEffects = {
		'/effects/emitters/units/scenario/scb3301/ambient/scb3301_amb_03_glow_emit.bp',
		'/effects/emitters/units/scenario/scb3301/ambient/scb3301_amb_04_electricity_emit.bp',
    },
    
    AmbientEffects02 = {
		'/effects/emitters/units/scenario/scb3301/ambient/scb3301_amb_01_glow_emit.bp',
		'/effects/emitters/units/scenario/scb3301/ambient/scb3301_amb_02_light_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- Ambient effects
        for kBone, vBone in self.AmbientEffectBones do
            for k, v in self.AmbientEffects do
				table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, vBone, self:GetArmy(), v ) )
			end
        end
        
		for kEffect, vEffect in self.AmbientEffects02 do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect02', self:GetArmy(), vEffect ) )
        end
    end,
    
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()
        
        self:CreateUnitDestructionDebris()

        -- Create explosion effects
        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect01', self:GetArmy(), v ):ScaleEmitter(2)
		end
		
        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect03', self:GetArmy(), v )
		end

		WaitSeconds(0.25)

        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect05', self:GetArmy(), v )
		end

		WaitSeconds(0.5)

        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect04', self:GetArmy(), v )
		end

        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect06', self:GetArmy(), v )
		end
		
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect02', self:GetArmy(), v ):ScaleEmitter(1)
		end
		
        self:CreateWreckage(0.1)
        		
		WaitSeconds(0.5)
        
        self:Destroy()
    end,
    
}
TypeClass = SCB3301
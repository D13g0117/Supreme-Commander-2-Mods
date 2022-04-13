-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb3601/scb3601_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  Artifact Power Coil: SCB3601
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB3601 = Class(StructureUnit) {

	CoilAttachBones = {
		'Effect05',
		'Effect06',
		'Effect07',
		'Effect08',
		'Effect09',
	},
	
    AmbientEffects = {
		'/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_01_electricity_emit.bp',
    },
    
	CoreEffects = {
		'/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_03_electricity_emit.bp',
		'/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_05_glow_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
        self.AmbientEffectsBag = {}
        
        -- 5 coil effects
        for kBone, vBone in self.CoilAttachBones do
			for kEffect, vEffect in self.AmbientEffects do
				table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, vBone, self:GetArmy(), vEffect ) )
			end
        end
        
        -- Secondary coil effects
        table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect11', self:GetArmy(), '/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_02_electricity_emit.bp' ) )
        
        -- Core effects
		for k, v in self.CoreEffects do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect04', self:GetArmy(), v ) )
		end
        
        -- Steam
        table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect10', self:GetArmy(), '/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_06_steam_emit.bp' ) )
        
        -- Blinking lights
        table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), '/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_04_blinkinglight_emit.bp' ) )

        -- Flat glow
        table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect04', self:GetArmy(), '/effects/emitters/units/scenario/scb3601/ambient/scb3601_a_07_flatglow_emit.bp' ) )
        
		self.Spinners = {
            Spinner1 = CreateRotator(self, 'ring01', 'y', nil, 0, 60, 360):SetTargetSpeed(-15),
            Spinner2 = CreateRotator(self, 'ring02', 'y', nil, 0, 60, 360):SetTargetSpeed(30),
            Spinner3 = CreateRotator(self, 'ring03', 'y', nil, 0, 60, 360):SetTargetSpeed(15),
        }
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )

    end,
    
	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects		
        for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect11', self:GetArmy(), v )
		end
		
		self:CreateUnitDestructionDebris()
		
		WaitSeconds(0.1)
		
        for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect02', self:GetArmy(), v ):ScaleEmitter(2.0)
		end
		
		WaitSeconds(0.2)
		
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect03', self:GetArmy(), v ):ScaleEmitter(2.5)
		end
		
		WaitSeconds(0.3)
		
		for k, v in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.0)
		end
		
		for k, v in EffectTemplates.Explosions.Land.CybranSCB3601DestroyEffects01 do
			CreateAttachedEmitter ( self, 'Power_Coil', self:GetArmy(), v )
		end
		
        self:CreateWreckage(0.1)
        
        self:ShakeCamera(20, 4, 1, 2.0)
         		
		WaitSeconds(0.9)
        
        self:Destroy()
    end,
    
}
TypeClass = SCB3601
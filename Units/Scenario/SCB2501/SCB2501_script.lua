-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb2501/scb2501_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Illuminate Command Center: SCB2501
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB2501 = Class(StructureUnit) {

	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect03', self:GetArmy(), v ):ScaleEmitter(2.0)
		end
		WaitSeconds(0.5)
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect02', self:GetArmy(), v ):ScaleEmitter(1.0)
		end
		WaitSeconds(0.2)
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect05', self:GetArmy(), v ):ScaleEmitter(1.0)
		end
		WaitSeconds(0.1)
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect07', self:GetArmy(), v ):ScaleEmitter(2.0)
		end
		WaitSeconds(0.3)
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect04', self:GetArmy(), v ):ScaleEmitter(1.0)
		end
		WaitSeconds(0.5)
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect08', self:GetArmy(), v ):ScaleEmitter(2.0)
		end
		WaitSeconds(0.3)
		for k, v in EffectTemplates.Explosions.Air.CybranDefaultDestroyEffectsAirLarge01 do
			CreateAttachedEmitter ( self, 'Effect06', self:GetArmy(), v ):ScaleEmitter(2.0)
		end
		WaitSeconds(0.2)
        for k, v in EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect01', self:GetArmy(), v ):ScaleEmitter(3.0):OffsetEmitter( 0, 8.5, 0 )
		end
		
     	self:CreateUnitDestructionDebris()
        self:CreateWreckage(0.1)
        
        WaitSeconds(0.5)
        		
        -- Create explosion effects
        for k, v in EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, 'Effect01', self:GetArmy(), v ):ScaleEmitter(3.8)
		end
				
		WaitSeconds(0.6)
        
        self:Destroy()
    end,
    
}
TypeClass = SCB2501
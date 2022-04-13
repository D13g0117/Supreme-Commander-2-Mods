-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb2101/scb2101_script.lua
--  Author(s):  Chris Daroza
--  Summary  :  SC2 Naval Barricade: SCB2101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB2101 = Class(StructureUnit) {

	AllowCustomEffects = true,

	ExplosionThread = function(self)
        local army = self:GetArmy()
		local effectIndex = 0

		while self and self.AllowCustomEffects and effectIndex < 10 do
			self:PlayUnitSound('Killed')
			effectIndex = effectIndex + 1

			if effectIndex == 1 then
		        for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(3):OffsetEmitter( 0, 6, 10 )
				end
				WaitSeconds(0.6)
			elseif effectIndex == 2 then
				for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.3):OffsetEmitter( 0, 5.5, -8 )
				end
				WaitSeconds(0.4)
			elseif effectIndex == 3 then
				for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.0):OffsetEmitter( 0, 5, 0 )
				end
				WaitSeconds(0.3)
			elseif effectIndex == 4 then
		        for k, v in EffectTemplates.Explosions.Water.CybranDefaultDestroyEffectsWater01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.0):OffsetEmitter( 0, 0, 9 )
				end
				WaitSeconds(1.0)
			elseif effectIndex == 5 then
				for k, v in EffectTemplates.Explosions.Water.CybranDefaultDestroyEffectsWater01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(1.5):OffsetEmitter( 0, 0, -9 )
				end
				WaitSeconds(1.2)
			elseif effectIndex == 6 then
		        for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(3):OffsetEmitter( 0, 6, 10 )
				end
				WaitSeconds(0.6)
			elseif effectIndex == 7 then
				for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.3):OffsetEmitter( 0, 5.5, -8 )
				end
				WaitSeconds(0.4)
			elseif effectIndex == 8 then
				for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.0):OffsetEmitter( 0, 5, 0 )
				end
				WaitSeconds(0.3)
			elseif effectIndex == 9 then
				for k, v in EffectTemplates.Explosions.Air.UEFDefaultDestroyEffectsAir01 do
					CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(2.3):OffsetEmitter( 0, 5.5, -8 )
				end
				WaitSeconds(0.4)
			end
		end

		self:CreateWreckageProp()
		WaitSeconds(0.5)
		self:Destroy()
	end,

	DeathThread = function(self)
		self:PlayUnitSound('Killed')
		for k, v in EffectTemplates.Explosions.Water.CybranDefaultDestroyEffectsWater01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(3.0):OffsetEmitter( 0, 0, 9 )
		end

		self:CreateUnitDestructionDebris()

		-- Destroy any ambient damage effects on unit
		self:DestroyAllDamageEffects()

		-- setup for sinking
		self:SetImmobile(false)
		self:OccupyGround(false)
		self:SetMotionType('RULEUMT_Water')
		self:CreateNavigator()

		-- start a series of explosions
		self:ForkThread(self.ExplosionThread)
    end,

}
TypeClass = SCB2101
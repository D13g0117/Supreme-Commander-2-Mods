-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0114/ucx0114_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Cybran Unit Magnet
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local MAGNETPULSETIME = 0.1
local MAGNET_DISTANCE = 250
local MAGNET_CRUSH_TO_MASS_DISTANCE = 10
local MASS_PERCENT = 0.2
local MAGNET_DAMAGE_PER_TICK = 400

UCX0114 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.MagnetEffects = {}
		self.Pushing = false
		self.Pulling = false
		self.Trash:Add(CreateRotator(self, 'Gear01', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear02', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear03', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear04', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear05', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear06', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear07', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear08', 'z', nil, 0, 60, 360):SetTargetSpeed(105))
		self.Trash:Add(CreateRotator(self, 'Gear09', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
		self.Trash:Add(CreateRotator(self, 'Gear10', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
		self.Trash:Add(CreateRotator(self, 'Gear11', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
		self.Trash:Add(CreateRotator(self, 'Gear12', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
    end,

	OnMagnetActivate = function(self, abilityBP, state)
		if state == 'activate' then
			self.Pulling = true
			self:PlayUnitAmbientSound('MagnetPull')
			self.tt1 = self:ForkThread( self.MagnetPulseThread )
		else
			self.Pulling = false
			self:StopUnitAmbientSound('MagnetPull')
			KillThread( self.tt1 )
			self.tt1 = nil
			self:DestroyMagnetEffects()
		end
	end,

	OnMagnetPushActivate = function(self, abilityBP, state)
		if state == 'activate' then
			self.Pushing = true
			self:PlayUnitAmbientSound('MagnetPush')
			self.tt1 = self:ForkThread( self.MagnetPushPulseThread )
		else
			self.Pushing = false
			self:StopUnitAmbientSound('MagnetPush')
			KillThread( self.tt1 )
			self.tt1 = nil
			self:DestroyMagnetEffects()
		end
	end,

	MagnetPulseThread = function(self)
		self:CreatePullEffects()
		local pos = table.copy(self:GetPosition('UCX0114'))
		local aiBrain = self:GetAIBrain()
		targets = {}

		while not self:IsDead() do
			if not self:IsStunned() then
				self:AddAgentFalloffForce( MAGNET_DISTANCE, -7, 'Enemy' )
				targets = aiBrain:GetUnitsAroundPoint( categories.MOBILE - categories.AIR, pos, MAGNET_CRUSH_TO_MASS_DISTANCE, 'Enemy' )

				for k, v in targets do
					local mass = v:GetBlueprint().Economy.MassValue
					aiBrain:GiveResource( 'MASS', mass * MASS_PERCENT )

					-- Destroy effects on targets being pulled in
					for kEffect, vEffect in EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsSmall01 do
						CreateEmitterAtEntity( v, v:GetArmy(), vEffect )
					end

					for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0114.OnUnitDestroy01 do
						table.insert( self.MagnetEffects, CreateAttachedEmitter( self, -2, self:GetArmy(), v ))
					end

					-- Cant kill the unit outright. The magnet needs to deal damage
					-- so the unit gets experience for the kill - Sorian 10/8/2009
					if v:GetHealth() > MAGNET_DAMAGE_PER_TICK then
						Damage( self, pos, v, MAGNET_DAMAGE_PER_TICK, 'Normal' )
					else
						v.ForceNoWreckage = true
						Damage( self, pos, v, MAGNET_DAMAGE_PER_TICK, 'Normal' )
					end
				end
			end
			WaitSeconds(MAGNETPULSETIME)
		end
	end,

	MagnetPushPulseThread = function(self)
		self:CreatePushEffects()
		while not self:IsDead() do
			if not self:IsStunned() then
				self:AddAgentFalloffForce( MAGNET_DISTANCE, 6, 'Enemy' )
			end
			WaitSeconds(MAGNETPULSETIME)
		end
	end,
	
	OnStunned = function(self,stunned)
		if stunned then
			self:DestroyMagnetEffects()
		else
			if self.Pushing then 
				self:CreatePushEffects()
			end
			
			if self.Pulling then
				self:CreatePullEffects()
			end
		end
	end,

	CreatePullEffects = function(self)
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0114.Pull01 do
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, -2, self:GetArmy(), v ))
        end

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0114.Pull02 do
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), v ))
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, 'Effect02', self:GetArmy(), v ))
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, 'Effect03', self:GetArmy(), v ))
        end
	end,	
	
	CreatePushEffects = function(self)
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0114.Push01 do
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), v ))
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, 'Effect02', self:GetArmy(), v ))
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, 'Effect03', self:GetArmy(), v ))
        end

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0114.Push02 do
            table.insert( self.MagnetEffects, CreateAttachedEmitter( self, -2, self:GetArmy(), v ))
        end	
	end,	
	
	DestroyMagnetEffects = function(self)
		if self.MagnetEffects then
			for k, v in self.MagnetEffects do
				v:Destroy()
			end
			self.MagnetEffects = {}	
		end
	end,
}
TypeClass = UCX0114
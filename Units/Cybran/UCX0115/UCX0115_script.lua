-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0115/ucx0115_script.lua
--  Author(s): Gordon Duclos
--  Summary  : Cybran Proto-Brain Complex
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

local PROTOBRAIN_REBUILDTIME = 25
local PROTOBRAIN_BUILDTIME = 1.5

UCX0115 = Class(StructureUnit) {

	OnStopBeingBuilt = function(self, builder, layer)
		StructureUnit.OnStopBeingBuilt(self, builder, layer)
		self.BrainGood = false
		self.BrainAttached = false
		self.protoBrain = nil
		self.TT1 = self:ForkThread( self.CreateProtoBrain )
	end,

	ReCreateProtoBrain = function(self)
		WaitSeconds(PROTOBRAIN_REBUILDTIME)
		self:CreateProtoBrain()
	end,

	CreateProtoBrain = function(self)
		local location = self:GetPosition('AttachSpecial01')
        --self.protoBrain = CreateUnitHPR('UCX0116', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
        local qx, qy, qz, qw = unpack(self:GetOrientation())
		self.protoBrain = CreateUnit('UCX0116', self:GetArmy(), location[1], location[2], location[3], qx, qy, qz, qw, 'Land')
        self.protoBrain:SetAttackerEnableState(false)
		self.protoBrain:SetUnSelectable(true)
		self.protoBrain:SetDoNotTarget(true)
		self.protoBrain.IgnoreDamage = true
		self.protoBrain:SetParent(self)
        self.protoBrain:SetCreator(self)
		IssuePodDock({self.protoBrain},self)
		self.BrainAttached = true

		local baseScale = self.protoBrain:GetBlueprint().Display.UniformScale
		local cMul = 0.1

		while cMul < 1.0 do
			self.protoBrain:SetScale( baseScale * cMul )
			cMul = cMul + 0.1
			WaitSeconds( PROTOBRAIN_BUILDTIME )

			for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0115.Ambient01 do
				CreateEmitterAtEntity( self, self:GetArmy(), v )
			end
		end

		self.protoBrain:SetUnSelectable(false)

		for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0116.Ambient01 do
			CreateAttachedEmitter( self.protoBrain, 0, self:GetArmy(), v )
		end

		self.BrainGood = true
		ApplyBuff( self, 'ProtoBrainSuperSmart01' )
		self.TT1 = nil
	end,

	NotifyOfBrainDeath = function( self, protoBrain )
		if self.TT1 then
			KillThread(self.TT1)
		end

		self.BrainGood = false
		self.protoBrain = nil
		self.BrainAttached = false

		if not self:IsDead() then
			self.TT1 = self:ForkThread( self.ReCreateProtoBrain )
		end
    end,

    OnCaptured = function(self, captor)
		self:CleanupBrain(self.BrainAttached)
		StructureUnit.OnCaptured(self, captor)
    end,

	OnTransportAttach = function(self, attachBone, unit)
		StructureUnit.OnTransportAttach(self, attachBone, unit)

		-- Begin Protobrain structure passive research bonuses.
		-- TBD, with finalization of research trees.
		unit:OnAttachToProtoBrainStructure()

		if self.protoBrain then
		    self.protoBrain:SetAttackerEnableState(false)
			self.protoBrain:SetDoNotTarget(true)
			self.protoBrain.IgnoreDamage = true
		end

		if self.BrainGood and not HasBuff(self, 'ProtoBrainSuperSmart01' ) then
			ApplyBuff( self, 'ProtoBrainSuperSmart01' )
		end
	end,

	OnTransportDetach = function(self, attachBone, unit)
		StructureUnit.OnTransportDetach(self, attachBone, unit)

		if self.protoBrain then
			-- Begin Protobrain
			self.protoBrain:OnDetachFromProtoBrainStructure()
			self.protoBrain:SetAttackerEnableState(true)
			self.protoBrain:SetDoNotTarget(false)
			self.protoBrain.IgnoreDamage = false
			self.BrainAttached = false
		end

		if HasBuff(self, 'ProtoBrainSuperSmart01' ) then
			RemoveBuff(self, 'ProtoBrainSuperSmart01' )
		end
	end,

	CleanupBrain = function(self, destroyed )
		if self.TT1 then
			KillThread(self.TT1)
		end

		if self.protoBrain then
			if destroyed then
				self.protoBrain:Destroy()
			else
				self.protoBrain:Kill()
			end
			self.protoBrain = nil
		end
	end,

	OnKilled = function(self, instigator, type, overkillRatio)
		self:CleanupBrain(false)
		StructureUnit.OnKilled(self, instigator, type, overkillRatio)
	end,

    OnDestroy = function(self)
		self:CleanupBrain(true)
		StructureUnit.OnDestroy(self)
	end,
}
TypeClass = UCX0115

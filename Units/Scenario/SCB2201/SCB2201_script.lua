-----------------------------------------------------------------------------
--  File     : /units/scenario/scb2201/scb2201_script.lua
--  Author(s): Gordon Duclos, Chris Daroza
--  Summary  : SC2 Custom Factory: SCB2201
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local Entity = import('/lua/sim/Entity.lua').Entity
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates

SCB2201 = Class(StructureUnit) {

	OnCreate = function(self)
		StructureUnit.OnCreate(self)
		local animset = self:GetBlueprint().AnimSet
		self:PushAnimSet(animset, "Base")
		self:AddSparseBone('Light01')
		self:AddSparseBone('Light02')
		self.BuildEffects = {}
	end,

	OnStopBeingBuilt = function(self, builder, layer)
		StructureUnit.OnStopBeingBuilt(self, builder, layer)
		self.Light01 = nil
		self.Light02 = nil
		self.Spinner01 = nil
		self.Spinner02 = nil
		--self:TurnOnWarningLights()
	end,

	TurnOnWarningLights = function(self)
		self.Light01 = CreateAttachLight( self, 'Light01', 30, 2, 0.5, -1, 0 )
		self.Light02 = CreateAttachLight( self, 'Light02', 30, 2, 0.5, -1, 0 )
		self.Spinner01 = CreateRotator( self, 'Light01', 'y', nil, -200 )
		self.Spinner02 = CreateRotator( self, 'Light02', 'y', nil, 250 )
		for k, v in EffectTemplates.SCB2201Lights01 do
            table.insert( self.BuildEffects, CreateAttachedEmitter( self, 'Light01', self:GetArmy(), v ) )
            table.insert( self.BuildEffects, CreateAttachedEmitter( self, 'Light02', self:GetArmy(), v ) )
        end
	end,

	TurnOffWarningLights = function(self)
		if self.Light01 then
			DestroyAttachLight(self, self.Light01 )
			self.Light01 = nil
		end
		if self.Light02 then
			DestroyAttachLight(self, self.Light02 )
			self.Light02 = nil
		end
		if self.Spinner01 then
			self.Spinner01:Destroy()
			self.Spinner01 = nil
		end
		if self.Spinner02 then
			self.Spinner02:Destroy()
			self.Spinner02 = nil
		end
	end,

	FakeBuildStart = function(self, unitBeingBuilt)
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
		self:SendAnimEvent( 'BuildIdle' )

		local bp = self:GetBlueprint()
		local bone = bp.Display.BuildAttachBone or 0

		unitBeingBuilt:PlayOnStartBuildAnimation()

		unitBeingBuilt:AttachBoneTo(-2, self, bone)

        if not self.BuildBoneRotator then
            self.BuildBoneRotator = CreateRotator(self, bone, 'y', 0, 10000)
            self.Trash:Add(self.BuildBoneRotator)
        end

        -- Destroy effects
		for k, v in self.BuildEffects do
			v:Destroy()
		end
		self.BuildEffects = {}
	end,

	RaisePlatform = function(self, unitBeingBuilt)
		self:SendAnimEvent( 'FinishBuild' )
		unitBeingBuilt:PlayDeployAnimation()
	end,

	FakeBuildComplete = function(self, unitBeingBuilt)
		local bp = self:GetBlueprint()
		local bone = bp.Display.BuildAttachBone or 0
		self:DetachAll(bone)

		if self.BuildBoneRotator then
		    self.BuildBoneRotator:Destroy()
		    self.BuildBoneRotator = nil
		end

        self:StopUnitAmbientSound('ConstructLoop')
        self:PlayUnitSound('ConstructStop')
	end,


-- TODO:: Commenting this out for now - leading to errors - bfricks 11/6/09
--    CreateExplosionDebris01 = function( self, army, bone )
--        for k, v in EffectTemplates.Units.Illuminate.Land.General.IlluminateStructureDestroyEffectsSecondary01 do
--            CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 2, 3 )
--        end
--    end,
--
-- TODO:: Commenting this out for now - leading to errors - bfricks 11/6/09
--    CreateExplosionDebris02 = function( self, army, bone )
--        for k, v in EffectTemplates.Units.Illuminate.Land.General.IlluminateStructureDestroyEffectsExtraLarge02 do
--            CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 0, 2 )
--        end
--    end,
--
-- TODO:: Commenting this out for now - leading to errors - bfricks 11/6/09
--    DeathThread = function(self)
--        local army = self:GetArmy()
--		local bp = self:GetBlueprint()
--		local utilities = import('/lua/system/utilities.lua')
--		local GetRandomFloat = utilities.GetRandomFloat
--
--        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_3' )
--        WaitSeconds(0.3)
--        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_2' )
--        WaitSeconds(0.4)
--        self:ExplosionTendrils( self )
--        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_1' )
--        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_4' )
--
--        WaitSeconds(0.2)
--        -- Create destruction debris fragments.
--		self:CreateUnitDestructionDebris()
--
--		WaitSeconds(0.3)
--
--		self:CreateExplosionDebris02( army, 'Addon01' )
--
--		WaitSeconds(0.6)
--
--		if self.DeathAnimManip then
--            WaitFor(self.DeathAnimManip)
--        end
--
--        self:CreateWreckage(0.1)
--
--		local scale = bp.Physics.SkirtSizeX + bp.Physics.SkirtSizeZ
--		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy())
--
--        self:Destroy()
--    end,
}
TypeClass = SCB2201
-----------------------------------------------------------------------------
--  File     :  /units/scenario/scb3302/scb3302_script.lua
--  Author(s):	Chris Daroza
--  Summary  :  SC2 Custom Cybran Gantry: SCB3302
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates


SCB3302 = Class(StructureUnit) {

	OnCreate = function(self)
		StructureUnit.OnCreate(self)
		local animset = self:GetBlueprint().AnimSet
		self:PushAnimSet(animset, "Base")
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

-- TODO:: Commented this out becuase it is an illuminate effect and we copied it for SCB2201 ~cdaroza 9.02.09
--    CreateExplosionDebris01 = function( self, army, bone )
--        for k, v in EffectTemplates.Units.Illuminate.Land.General.IlluminateStructureDestroyEffectsSecondary01 do
--           CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 2, 3 )
--        end
--    end,

-- TODO:: Commented this out becuase it is an illuminate effect and we copied it for SCB2201 ~cdaroza 9.02.09
--    CreateExplosionDebris02 = function( self, army, bone )
--        for k, v in EffectTemplates.Units.Illuminate.Land.General.IlluminateStructureDestroyEffectsExtraLarge02 do
--           CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 0, 2 )
--        end
--    end,

-- TODO:: Commented this out becuase it is an illuminate effect and we copied it for SCB2201 ~cdaroza 9.02.09
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
TypeClass = SCB3302

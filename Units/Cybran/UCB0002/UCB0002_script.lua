-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucb0002/ucb0002_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Air Factory: UCB0002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit

UCB0002 = Class(FactoryUnit) {

    PlatformBone = 'B01',
    LandUnitBuilt = false,
    UpgradeRevealArm1 = 'Arm01',
    UpgradeRevealArm2 = 'Arm04',
    UpgradeBuilderArm1 = 'Arm01_B02',
    UpgradeBuilderArm2 = 'Arm02_B02',
    
    BuildEffectsEmitters = {
		'/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_01_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_02_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_03_smoke_emit.bp',
		
		'/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_04_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_05_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_06_smoke_emit.bp',
	},

	OnStopBeingBuilt = function(self,builder,layer)
        FactoryUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
	    for k, v in self.BuildEffectsEmitters do
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'Pillar01', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'Pillar02', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'Pillar03', self:GetArmy(), v ) )
		end
	    
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_07_spinlight_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_08_glowlight_emit.bp' ))
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0002/event/build/ucb0002_build_09_centerglow_emit.bp' ))
    end,

    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 )
    end,
    
    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge01 )
    end,
    
    CreateExplosionDebris03 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsFlash01, false, 1, { 0, 8, 0 } )
    end,
    
    DeathThread = function(self)
        local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local utilities = import('/lua/system/utilities.lua')
		local GetRandomFloat = utilities.GetRandomFloat

		self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris01( army, 'Attachpoint04' )
        WaitSeconds(0.5)
        self:CreateExplosionDebris01( army, 'RRing02' )
        self:ExplosionTendrils( self )

        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

		WaitSeconds(0.1)

		self:CreateExplosionDebris02( army )
		self:CreateExplosionDebris03( army, -2 )

		WaitSeconds(0.2)
		
		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end

        self:CreateWreckage(0.1)

		local scale = bp.Physics.SkirtSizeX + bp.Physics.SkirtSizeZ
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 3 )

        self:Destroy()
    end,
}
TypeClass = UCB0002
-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0011/ucb0011_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Cybran Mobile Land Gantry: UCB0011
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalGantryUnit = import('/lua/sim/ExperimentalGantryUnit.lua').ExperimentalGantryUnit

UCB0011 = Class(ExperimentalGantryUnit) {
	BuildEffectsEmitters01 = {
		'/effects/emitters/units/cybran/ucb0011/event/build/ucb0011_build_01_glow_emit.bp',
	},
	BuildEffectsEmitters02 = {
		'/effects/emitters/units/cybran/ucb0011/event/build/ucb0011_build_02_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0011/event/build/ucb0011_build_04_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0011/event/build/ucb0011_build_03_smoke_emit.bp',
	},
	OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalGantryUnit.OnStopBeingBuilt(self,builder,layer)
		self.EffectsBag = {}
    end,
    
    StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
        
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0011/event/build/ucb0011_build_05_smallsmoke_emit.bp' )) --  door smoke
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0011/event/build/ucb0011_build_06_smallsmoke_emit.bp' )) --  door smoke
			
			for k, v in self.BuildEffectsEmitters01 do
				self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Girder_L', self:GetArmy(), v ) )
				self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Girder_R', self:GetArmy(), v ) )
			end
			for k, v in self.BuildEffectsEmitters02 do
				self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Cam_L', self:GetArmy(), v ) )
				self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Cam_R', self:GetArmy(), v ) )
			end
    end,
    
    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02, false, 1.5 )
    end,
    
    CreateExplosionDebris02 = function( self, army, bone )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 )
    end,
    
    CreateExplosionDebris03 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsFlash01, false, 1.4, { 0, 12, 0 } )
    end,
    
    DeathThread = function(self)
        local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local utilities = import('/lua/system/utilities.lua')
		local GetRandomFloat = utilities.GetRandomFloat

		self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris01( army, 'Girder_L' )
        WaitSeconds(0.5)
        self:CreateExplosionDebris02( army )
        self:CreateExplosionDebris01( army, 'Cam_R' )
        self:ExplosionTendrils( self )

        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

		WaitSeconds(0.2)

		self:CreateExplosionDebris01( army, 'Cam_R' )
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
TypeClass = UCB0011

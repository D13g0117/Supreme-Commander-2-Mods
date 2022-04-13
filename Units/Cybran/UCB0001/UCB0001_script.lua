-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0001/ucb0001_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Land Factory: UCB0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit

UCB0001 = Class(FactoryUnit) {
	BuildEffectsEmitters = {
		'/effects/emitters/units/cybran/ucb0001/event/build/cybran_build_01_glow_emit.bp',
		'/effects/emitters/units/cybran/ucb0001/event/build/cybran_build_02_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0001/event/build/cybran_build_03_smoke_emit.bp',
	},

	OnStopBeingBuilt = function(self,builder,layer)
        FactoryUnit.OnStopBeingBuilt(self,builder,layer)
		self.EffectsBag = {}
    end,

	StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0001/event/build/cybran_build_05_flash_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0001/event/build/cybran_build_04_light_emit.bp' ))
        
        for k, v in self.BuildEffectsEmitters do
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Effect01', army, v ) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Effect02', army, v ) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Effect03', army, v ) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Effect04', army, v ) )
		end
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

        self:CreateExplosionDebris01( army, 'Addon06' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'Door_01' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'Addon08' )
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

        self:CreateWreckage(0.2)

		local scale = bp.Physics.SkirtSizeX + bp.Physics.SkirtSizeZ
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 3 )

        self:Destroy()
    end,
}
TypeClass = UCB0001
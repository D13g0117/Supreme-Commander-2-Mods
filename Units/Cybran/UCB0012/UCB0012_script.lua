-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0012/ucb0012_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Cybran Mobile Air Gantry: UCB0012
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalGantryUnit = import('/lua/sim/ExperimentalGantryUnit.lua').ExperimentalGantryUnit

UCB0012 = Class(ExperimentalGantryUnit) {

    BuildEffectsEmitters01 = {
		'/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_01_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_02_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_03_smoke_emit.bp',
	},

    BuildEffectsEmitters02 = {
		'/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_04_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_05_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_06_smoke_emit.bp',
	},
	
	OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalGantryUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
	    for k, v in self.BuildEffectsEmitters01 do
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'RPillar01', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'RPillar02', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'RPillar03', self:GetArmy(), v ) )
		end
	    
	    for k, v in self.BuildEffectsEmitters02 do
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'LPillar01', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'LPillar02', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add(CreateAttachedEmitter( self, 'LPillar03', self:GetArmy(), v ) )
		end
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_07_spinlight_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_08_glowlight_emit.bp' ))
        
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_10_smoke_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_11_sparks_emit.bp' ))
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_12_flash_emit.bp' ))
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0012/event/build/ucb0012_build_13_line_emit.bp' ))
    end,
    
    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02, false, 1.5 )
    end,
    
    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.CybranStructureDestroyEffectsExtraLarge02 )	
    end,
    
    CreateExplosionDebris03 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsFlash01, false, 1.4, { 0, 8, 0 } )
    end,
    
    DeathThread = function(self)
        local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local utilities = import('/lua/system/utilities.lua')
		local GetRandomFloat = utilities.GetRandomFloat

		self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris01( army, 'Addon01' )
        WaitSeconds(0.5)
        self:CreateExplosionDebris02( army )
        self:ExplosionTendrils( self )

        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

		WaitSeconds(0.2)

		self:CreateExplosionDebris01( army, 'LPillar02' )
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
TypeClass = UCB0012

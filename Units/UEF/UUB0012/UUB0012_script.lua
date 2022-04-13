-----------------------------------------------------------------------------
--  File     : /units/uef/uub0012/uub0012_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Experimental Gantry: UUB0012
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalGantryUnit = import('/lua/sim/ExperimentalGantryUnit.lua').ExperimentalGantryUnit

UUB0012 = Class(ExperimentalGantryUnit) {

	StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0012/event/build/uef_expairfactory_01_smoke_emit.bp' ))
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0012/event/build/uef_expairfactory_02_sparks_emit.bp' ))
		self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0012/event/build/uef_expairfactory_03_flash_emit.bp' ))
		self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0012/event/build/uef_expairfactory_04_line_emit.bp' ))
    end,	
    
    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02, false, 1.8 )
    end,
    
    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge02, false, 1.3 )
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

        self:CreateExplosionDebris01( army, 'Barrel01' )
        WaitSeconds(0.1)
        self:CreateExplosionDebris01( army, 'Door_Outter04' )
        WaitSeconds(0.4)
        self:CreateExplosionDebris01( army, 'Door_Outter02' )
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
TypeClass = UUB0012

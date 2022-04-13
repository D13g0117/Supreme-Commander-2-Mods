-----------------------------------------------------------------------------
--  File     :  /units/uef/uub0001/uub0001_script.lua
--  Author(s):  Gordon Duclos, Morien Thomas
--  Summary  :  SC2 UEF Land Factory: UUB0001
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates

UUB0001 = Class(FactoryUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
		FactoryUnit.OnStopBeingBuilt(self,builder,layer)
	end,
	
	StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0001/event/build/uef_landfactory_02_smoke_emit.bp' ))
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0001/event/build/uef_landfactory_03_sparks_emit.bp' ))
    end,
    
    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 )
    end,
    
    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge01, false, 1.4 )
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

        self:CreateExplosionDebris01( army, 'Crane01' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'Tower_HP_02' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'UUB0001_Door_r' )
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
TypeClass = UUB0001
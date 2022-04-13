-----------------------------------------------------------------------------
--  File     :  /units/uef/uub0002/uub0002_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 UEF Air Factory: UUB0002
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates

UUB0002 = Class(FactoryUnit) {

	EffectAttachBones01 = {	
        'Clamp01',
        'Clamp04',
        'Clamp06',
	},
	EffectAttachBones02 = {	
        'Clamp02',
        'Clamp03',
        'Clamp05',
	},
	
	OnAnimEndTrigger = function( self, event )
		FactoryUnit.OnAnimEndTrigger( self, event )
		local army = self:GetArmy()
	
		if event == 'FinishBuild' then
			for k, v in EffectTemplate.UEFAirFactoryBuildEffects01 do
			   CreateAttachedEmitter( self, 'UUB0002', army, v )
			end
			for kBone, vBone in self.EffectAttachBones01 do
				for k, v in EffectTemplate.UEFAirFactoryBuildEffects02 do
				   CreateAttachedEmitter( self, vBone, army, v )
				end
			end
			for kBone, vBone in self.EffectAttachBones02 do
				for k, v in EffectTemplate.UEFAirFactoryBuildEffects03 do
				   CreateAttachedEmitter( self, vBone, army, v )
				end
			end
		end
	end,
	
	StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()

	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_07_spinlight_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_09_glowlight_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_10_glowlight_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_11_smoke_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_12_smoke_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_13_centerflashes_emit.bp' ))
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0002/event/build/uef_airfactory_14_centerglow_emit.bp' ))
    end,
    
    CreateExplosionDebris01 = function( self, army, bone )
    	CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02, false, 1.3 )
    end,
    
    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge01 )
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

        self:CreateExplosionDebris01( army, 'Side01' )
        WaitSeconds(0.3)
        self:CreateExplosionDebris01( army, 'Attachpoint04' )
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
TypeClass = UUB0002
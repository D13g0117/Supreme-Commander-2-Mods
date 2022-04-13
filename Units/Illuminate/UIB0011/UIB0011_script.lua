-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0011/uib0011_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Illuminate Mobile Experimental Gantry: UIB0011
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalGantryUnit = import('/lua/sim/ExperimentalGantryUnit.lua').ExperimentalGantryUnit

UIB0011 = Class(ExperimentalGantryUnit) {

    IlluminateExperimentalFactoryBuildEffects01 = { 
		'/effects/emitters/units/illuminate/uib0011/event/build/illuminate_uib0011_01_core_emit.bp',
		'/effects/emitters/units/illuminate/uib0011/event/build/illuminate_uib0011_02_wisps_emit.bp',
		'/effects/emitters/units/illuminate/uib0011/event/build/illuminate_uib0011_03_ring_emit.bp',
		'/effects/emitters/units/illuminate/uib0011/event/build/illuminate_uib0011_04_distortring_emit.bp',
		'/effects/emitters/units/illuminate/uib0011/event/build/illuminate_uib0011_06_smallring_emit.bp',
	},

	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalGantryUnit.OnStopBeingBuilt(self,builder,layer)
		self.BuildEffects = {}
	end,

    StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
        
        for k, v in self.IlluminateExperimentalFactoryBuildEffects01 do
            self.BuildEffectsBag:Add( CreateAttachedEmitter(self, 'Addon01', self:GetArmy(), v) )
        end
        	    
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/illuminate/uib0011/event/build/illuminate_uib0011_05_glow_emit.bp' )) --  base glow
    end,
        
    CreateExplosionDebris01 = function( self, army, bone )
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
            CreateAttachedEmitter( self, bone, army, v ):OffsetEmitter( 0, 5, 10 ):ScaleEmitter(0.8)   
        end
    end,

    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge02, false, 1.2 )
    end,
    
    CreateExplosionDebris03 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsFlash01, false, 1.6, { 0, 8, 0 } )
    end,

    DeathThread = function(self)
        local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local utilities = import('/lua/system/utilities.lua')
		local GetRandomFloat = utilities.GetRandomFloat
		
        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_3' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_2' )      
        WaitSeconds(0.4)    
        self:ExplosionTendrils( self )
        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_1' )
        WaitSeconds(0.1)  
        self:CreateExplosionDebris01( army, 'UIB0011_Quoit_Outside_4' )
        
        WaitSeconds(0.2) 
        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()
                		
		self:CreateExplosionDebris02( army )
		self:CreateExplosionDebris03( army, -2 )
		
		WaitSeconds(0.2)
		
		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
        
        self:CreateWreckage(0.1)

		local scale = bp.Physics.SkirtSizeX + bp.Physics.SkirtSizeZ 
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 5 )
        
        self:Destroy()
    end,
    
}
TypeClass = UIB0011
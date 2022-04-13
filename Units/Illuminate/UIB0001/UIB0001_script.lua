-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0001/uib0001_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Land Factory: UIB0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local AIUtils = import('/lua/ai/aiutilities.lua')

UIB0001 = Class(FactoryUnit) {

	BuildEffectsEmitters = {
		'/effects/emitters/units/illuminate/uib0001/event/build/illuminate_build_01_glow_emit.bp',
		'/effects/emitters/units/illuminate/uib0001/event/build/illuminate_build_02_plasma_emit.bp',
		'/effects/emitters/units/illuminate/uib0001/event/build/illuminate_build_03_sparks_emit.bp',
		'/effects/emitters/units/illuminate/uib0001/event/build/illuminate_build_04_smoke_emit.bp',
	},

	OnStopBeingBuilt = function(self,builder,layer)
        FactoryUnit.OnStopBeingBuilt(self,builder,layer)
		self.EffectsBag = {}
    end,

    OnCreate = function(self, createArgs)
        FactoryUnit.OnCreate(self, createArgs)
        self:ForkThread(self.NaniteCloudThread)
    end,

	StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
	    
		for k, v in self.BuildEffectsEmitters do
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Addon11', army, v ) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Addon12', army, v ) )
		end
    end,
    
    NaniteCloudThread = function(self)
        while not self:IsDead() do
            if self.NaniteCloudActive then
                -- Get friendly units in the area (including self)
                local affectradius = 30
                local captureCategory = (categories.MOBILE * categories.LAND) - categories.COMMAND - categories.EXPERIMENTAL
                local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), captureCategory, self:GetPosition(), affectradius)
                -- Give them a 5 second regen buff
                for _,unit in units do
                    if not unit:IsDead() then
                        ApplyBuff(unit, 'HealingNaniteCloudBuff')
                    end
                end

                -- Wait 1 second
            end
            WaitSeconds(1)
        end
    end,
    
    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsSecondary01 )
    end,
    
    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge01 )
    end,

    CreateExplosionDebris03 = function( self, army, bone )
    	CreateEmittersAtBone( self, bone, army, EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01, false, 1, { 0, -2, 0 } )
    end,
    
    CreateExplosionDebris04 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsFlash01, false, 1.4, { 0, 8, 0 } )
    end,
    
    DeathThread = function(self)
        local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local utilities = import('/lua/system/utilities.lua')
		local GetRandomFloat = utilities.GetRandomFloat

		self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris01( army, 'Addon04' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'Addon02' )
        WaitSeconds(0.4)
        self:CreateExplosionDebris03( army, 'Addon09' )
        WaitSeconds(0.1)
        self:ExplosionTendrils( self )

        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

		WaitSeconds(0.1)

		self:CreateExplosionDebris02( army )
		self:CreateExplosionDebris04( army, -2 )

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
TypeClass = UIB0001
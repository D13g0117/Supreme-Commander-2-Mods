-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0002/uib0002_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Air Factory: UIB0002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local AIUtils = import('/lua/ai/aiutilities.lua')

UIB0002 = Class(FactoryUnit) {

    IlluminateAirFactoryBuildIdleEffects01 = {
		'/effects/emitters/units/illuminate/uib0002/ambient/illuminate_airfactory_01_emit.bp',
		'/effects/emitters/units/illuminate/uib0002/ambient/illuminate_airfactory_02_emit.bp',
		'/effects/emitters/units/illuminate/uib0002/ambient/illuminate_airfactory_04_emit.bp',
	},

	OnStopBeingBuilt = function(self,builder,layer)
		FactoryUnit.OnStopBeingBuilt(self,builder,layer)
	end,

    OnCreate = function(self, createArgs)
        FactoryUnit.OnCreate(self, createArgs)
        self:ForkThread(self.NaniteCloudThread)
    end,

    StartBuildFx = function(self, unitBeingBuilt)
        local army = self:GetArmy()
        
        for k, v in self.IlluminateAirFactoryBuildIdleEffects01 do
            self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Addon01', self:GetArmy(), v ) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'Addon02', self:GetArmy(), v ) )
        end
	    
	    self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/illuminate/uib0002/ambient/illuminate_airfactory_03_emit.bp' )) --  base glow
    end,

    CreateExplosionDebris01 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsSecondary01, false, 1.7, { 0, 3, 0} )
    end,

    CreateExplosionDebris02 = function( self, army )
		CreateEmittersAtEntity( self, army, EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge01 )
    end,

    CreateExplosionDebris03 = function( self, army, bone )
		CreateEmittersAtBone( self, bone, army, EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsFlash01, false, 1.2, { 0, 8, 0 } )
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
            end
            WaitSeconds(1)
        end
    end,

    DeathThread = function(self)
        local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local utilities = import('/lua/system/utilities.lua')
		local GetRandomFloat = utilities.GetRandomFloat

		self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris01( army, 'SmallSpinner01' )
        WaitSeconds(0.2)
        self:CreateExplosionDebris01( army, 'SmallSpinner04' )
        self:CreateExplosionDebris01( army, 'SmallSpinner03' )
        WaitSeconds(0.4)
        self:CreateExplosionDebris01( army, 'SmallSpinner02' )
        WaitSeconds(0.1)
        self:ExplosionTendrils( self )

        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

        self:CreateExplosionDebris01( army, 'SmallSpinner04' )
        self:CreateExplosionDebris01( army, 'SmallSpinner03' )

		WaitSeconds(0.2)

		self:CreateExplosionDebris02( army )
		self:CreateExplosionDebris03( army, -2 )

		WaitSeconds(0.4)

		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end

        self:CreateWreckage(0.1)

		local scale = bp.Physics.SkirtSizeX + bp.Physics.SkirtSizeZ
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 3 )

        self:Destroy()
    end,
}
TypeClass = UIB0002
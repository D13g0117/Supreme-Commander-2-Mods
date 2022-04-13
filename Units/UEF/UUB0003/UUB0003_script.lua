-----------------------------------------------------------------------------
--  File     : /units/uef/uub0003/uub0003_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Sea Factory: UUB0003
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0003 = Class(FactoryUnit) {

    UEFSeaFactoryBuildEffects01 = {
		'/effects/emitters/units/uef/uub0003/build/uef_seafactory_06_spark_emit.bp',
		'/effects/emitters/units/uef/uub0003/build/uef_seafactory_09_smoke_emit.bp',
	},
	UEFSeaFactoryBuildEffects02 = {
		'/effects/emitters/units/uef/uub0003/build/uef_seafactory_08_spark_emit.bp',
		'/effects/emitters/units/uef/uub0003/build/uef_seafactory_09_smoke_emit.bp',
	},

    StartBuildFx = function(self, unitBeingBuilt)
		local army = self:GetArmy()
        for k, v in self.UEFSeaFactoryBuildEffects01 do
            self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'RightDoor', self:GetArmy(), v ) )
        end
        for k, v in self.UEFSeaFactoryBuildEffects02 do
			self.BuildEffectsBag:Add( CreateAttachedEmitter( self, 'LeftDoor', self:GetArmy(), v ) )
        end
        
        self.BuildEffectsBag:Add( CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/uef/uub0003/build/uef_seafactory_05_flash_emit.bp' ))
    end,
    
	OnAnimEndTrigger = function( self, event )
		local army = self:GetArmy()
				
		if event == 'FinishBuild' then
			for k, v in EffectTemplate.UEFSeaFactoryBuildEffects01 do
			   CreateAttachedEmitter( self, 'Dock', army, v )
			end
			if self.FactoryBuildFailed then
				self:SendAnimEvent( 'StopBuild' )
			end
		elseif event == 'ReverseFinishBuild' then
			self.InRolloffAnim = false

			-- We've finished our reverse build animation and already started building.
			-- Just start up the build animation if we have one, and unhide the new unit
			-- being built.
			if self.BuildingUnit then
				self.BuildingUnit:ShowMesh()
				self:PlayBuildAnim()
			end
		end
	end,

	OnBuildPreRelease = function(self, unitBeingBuilt )
		local motionType = self.BuildingUnit:GetBlueprint().Physics.MotionType

		if motionType == 'RULEUMT_SurfacingSub' then
			self:SendAnimEvent( 'AltFinishBuild' )	
		elseif motionType == 'RULEUMT_Water' or motionType == 'RULEUMT_AmphibiousFloating' then
			self:SendAnimEvent( 'FinishBuild' )		
		end

		self:PlayUnitSound('ConstructOpen')
	end,

	PlayReverseRolloffAnim = function(self)
		local motionType = self.BuildingUnit:GetBlueprint().Physics.MotionType
		if motionType == 'RULEUMT_SurfacingSub' then
			self:SendAnimEvent( 'AltReverseFinishBuild' )	
		elseif motionType == 'RULEUMT_Water' or motionType == 'RULEUMT_AmphibiousFloating' then
			self:SendAnimEvent( 'ReverseFinishBuild' )		
		end
	end,
	
    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        local layer = self:GetCurrentLayer()
        self:DestroyIdleEffects()
		
        if (not self:IsBeingBuilt() or (self:IsBeingBuilt() and self:GetFractionComplete() > 0.5)) and ( layer == 'Water' or layer == 'Seabed' or layer == 'Sub' ) then
			-- Remove any build scaffolding
			if self.BuildScaffoldUnit and not self.BuildScaffoldUnit:IsDead() then
				self.BuildScaffoldUnit:BuildUnitComplete()
			end
			
			-- Give us a move type so we can sink
			self:SetImmobile(false)
			self:OccupyGround(false)
			self:SetMotionType('RULEUMT_Water')
			self:CreateNavigator()
			self:PlayUnitSound('Killed')
			self:PlayUnitAmbientSound('Sinking')
            self.SinkThread = self:ForkThread(self.SinkingThread)
            self.Callbacks.OnKilled:Call( self, instigator, type )
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
        else
            self.DeathBounce = 1
            FactoryUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,
	
    SinkingThread = function(self)
		if self:PrecacheDebris() then
			WaitTicks(1)
		end

		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect
		local ExplosionScale = bp.Death.ExplosionEffectScale or 1

		if ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][ExplosionEffect]

			if emitters then
				--CreateBoneEffects( self, -2, self:GetArmy(), emitters )

                for k, v in emitters do
                    CreateEmitterAtBone( self, -2, self:GetArmy(), v ):ScaleEmitter( ExplosionScale )
                end
			end
		end

		if bp.Death.DebrisPieces then
			self:DebrisPieces( self )
		end

		if bp.Death.ExplosionTendrils then
			self:ExplosionTendrils( self )
		end

		if bp.Death.Light then
			local myPos = self:GetPosition()
			myPos[2] = myPos[2] + 7
			CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.1, 0.1, 0.5 )
		end

		-- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

        self:ForkThread(self.SinkingEffects)
    end,

    OnImpact = function(self, with, other)
		if not self:IsDead() then
			return
		end

        -- This is a bit of safety to keep us from calling the death thread twice in case we bounce twice quickly
        if not self.DeathBounce then
            self:ForkThread(self.DeathThread, self.OverKillRatio )
            self.DeathBounce = 1
        end
    end,

    DeathThread = function(self, overkillRatio, instigator)
        self:ForkThread(self.SeaFloorImpactEffects)

        -- delay so dust impact effects can cover up the wreckage/prop swap
        WaitSeconds(1.0)

        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))

        local bp = self:GetBlueprint()
		self:StopUnitAmbientSound('Sinking')

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  / 7
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(vol/12)
    end,

    SinkingEffects = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz / 7
        local army = self:GetArmy()

        while i >= 0 do
            if i > 0 then
                local rx, ry, rz = self:GetRandomOffset(1)
                local rs = Random(vol/2, vol*2) / (vol*2)
                CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,self.LeftFrontWakeBone,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,self.RightFrontWakeBone,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            end

            local rx, ry, rz = self:GetRandomOffset(1)
            local rs = Random(vol/2.5, vol*2.5) / (vol*2.5)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_bubbles_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(vol/8)

            i = i - 1
            WaitSeconds(1)
        end
    end,
}
TypeClass = UUB0003
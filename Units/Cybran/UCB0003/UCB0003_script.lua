-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0003/ucb0003_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Sea Factory: UCB0003
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCB0003 = Class(FactoryUnit) {

	Weapons = {
        Cannon01 = Class(DefaultProjectileWeapon) {},
        Cannon02 = Class(DefaultProjectileWeapon) {},
        Cannon03 = Class(DefaultProjectileWeapon) {},
        Cannon04 = Class(DefaultProjectileWeapon) {},
    },

    BuildEffectsEmitters = {
		'/effects/emitters/units/cybran/ucb0003/event/build/ucb0003_build_01_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0003/event/build/ucb0003_build_02_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0003/event/build/ucb0003_build_03_smoke_emit.bp',
	},

	OnStopBeingBuilt = function(self,builder,layer)
        FactoryUnit.OnStopBeingBuilt(self,builder,layer)
		self.EffectsBag = {}
    end,
    
	OnAnimStartTrigger = function( self, event )
		if event == 'StartBuildLoop' then
	        if self.EffectsBag then
				for k, v in self.EffectsBag do
					v:Destroy()
				end
				self.EffectsBag = {}
			end
			
			local army = self:GetArmy()
			
			table.insert( self.EffectsBag, CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0003/event/build/ucb0003_build_06_spinlight_emit.bp' ))
			table.insert( self.EffectsBag, CreateAttachedEmitter( self, -2, army, '/effects/emitters/units/cybran/ucb0003/event/build/ucb0003_build_07_glowlight_emit.bp' ))
			
			for k, v in self.BuildEffectsEmitters do
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, 'ucb0003_RightBuild01', self:GetArmy(), v ) )
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, 'ucb0003_RightBuild02', self:GetArmy(), v ) )
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, 'ucb0003_LeftBuild01', self:GetArmy(), v ) )
				table.insert( self.EffectsBag, CreateAttachedEmitter( self, 'ucb0003_LeftBuild02', self:GetArmy(), v ) )
			end
		end
	end,

	-- Overide OnAnimEndTrigger for custom factory behavior.
	OnAnimEndTrigger = function( self, event )
		if event == 'FinishBuild' then
			if self.FactoryBuildFailed then
				self:SendAnimEvent( 'StopBuild' )
			end

			for k, v in EffectTemplate.CybranSeaFactoryBuildEffects01 do
			   CreateAttachedEmitter( self, 'ucb0003_Door01_Center', self:GetArmy(), v )
			   CreateAttachedEmitter( self, 'ucb0003_Door02_Center', self:GetArmy(), v )
			end

			if self.EffectsBag then
				for k, v in self.EffectsBag do
					v:Destroy()
				end
				self.EffectsBag = {}
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

    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        local layer = self:GetCurrentLayer()
        self:DestroyIdleEffects()

        if (not self:IsBeingBuilt() or (self:IsBeingBuilt() and self:GetFractionComplete() > 0.5)) and ( layer == 'Water' or layer == 'Seabed' or layer == 'Sub' ) then
			-- Remove any build scaffolding
			if self.BuildScaffoldUnit and not self.BuildScaffoldUnit:IsDead() then
				self.BuildScaffoldUnit:BuildUnitComplete()
			end
			
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

	OnMotionHorzEventChange = function( self, new, old )
		SeaUnit.OnMotionHorzEventChange(self, new, old )
	end,

    --*******************************************************************
    -- ROCKING
    --*******************************************************************
    -- While not as exciting as Rock 'n Roll, this will make the unit rock from side to side slowly
    -- in the water
    StartRocking = function(self)
        KillThread(self.StopRockThread)
        self.StartRockThread = self:ForkThread( self.RockingThread )
    end,

    StopRocking = function(self)
		if self.StartRockThread then
			KillThread(self.StartRockThread)
			self.StartRockThread = nil
			self.StopRockThread = self:ForkThread( self.EndRockingThread )
		end
    end,

    RockingThread = function(self)
        local bp = self:GetBlueprint().Display
        if not self.RockManip and not self:IsDead() and (bp.MaxRockSpeed and bp.MaxRockSpeed > 0) then
            self.RockManip = CreateRotator( self, 0, 'z', nil, 0, (bp.MaxRockSpeed or 1.5) / 5, (bp.MaxRockSpeed or 1.5) * 3 / 5 )
            self.Trash:Add(self.RockManip)
            self.RockManip:SetPrecedence(0)
            while (true) do
                WaitFor( self.RockManip )
                if self:IsDead() then break end -- abort if the unit died
                self.RockManip:SetTargetSpeed( -(bp.MaxRockSpeed or 1.5) )
                WaitFor( self.RockManip )
                if self:IsDead() then break end -- abort if the unit died
                self.RockManip:SetTargetSpeed( bp.MaxRockSpeed or 1.5 )
            end
        end
    end,

    EndRockingThread = function(self)
        local bp = self:GetBlueprint().Display
        if self.RockManip then
            self.RockManip:SetGoal( 0 )
            self.RockManip:SetSpeed( (bp.MaxRockSpeed or 1.5) / 4 )
            WaitFor( self.RockManip )

            if self.RockManip then
                self.RockManip:Destroy()
                self.RockManip = nil
            end
        end
    end,
}
TypeClass = UCB0003
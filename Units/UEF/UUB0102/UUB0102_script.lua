-----------------------------------------------------------------------------
--  File     :  /units/uef/uub0102/uub0102_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Anti-Air Tower: UUB0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0102 = Class(StructureUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {

			--PlayFxWeaponPackSequence: Played when a weapon packs up.  It has no target and is done with all of its rack salvos
			PlayFxWeaponPackSequence = function(self)
				self.AimControl:SetResetPoseTimer(0)
				WaitSeconds(2)
				--LOG( 'PlayFxWeaponPackSequence' )
				DefaultProjectileWeapon.PlayFxWeaponPackSequence(self)
			end,

			--PlayFxWeaponPackSequence: Played when a weapon packs up.  It has no target and is done with all of its rack salvos
			PlayFxWeaponUnpackSequence = function(self)
				self.AimControl:SetResetPoseTime(9999999)
				DefaultProjectileWeapon.PlayFxWeaponUnpackSequence(self)
			end,

			OnStopTracking = function(self, label)
				self:PlayWeaponSound('BarrelStop')
				self:StopWeaponAmbientSound('BarrelLoop')
			end,

			WeaponPackingState = State {
				WeaponWantEnabled = true,
				WeaponAimWantEnabled = true,

				Main = function(self)
					self.unit:SetBusy(true)
					local bp = self:GetBlueprint()
					--LOG('Weapon ' .. bp.Label .. ' entered WeaponPackingState.')
					WaitSeconds(self:GetBlueprint().WeaponRepackTimeout)
					self:PlayFxWeaponPackSequence()
					self:AimManipulatorSetEnabled(false)
					ChangeState(self, self.IdleState)
				end,

				OnGotTarget = function(self)
					if not self:GetBlueprint().ForceSingleFire then
						ChangeState(self, self.WeaponUnpackingState)
					end
				end,

				-- Override so that it doesn't play the firing sound when
				-- we're not actually creating the projectile yet
				OnFire = function(self)
					local bp = self:GetBlueprint()
					if bp.RequiresAmmo and not bp.ForceSingleFire then
						ChangeState(self, self.WeaponUnpackingState)
					end
				end,
			},
        },
    },
	
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
			self:SetMotionType('RULEUMT_AmphibiousFloating')
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
            StructureUnit.OnKilled(self, instigator, type, overkillRatio)
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
        if self:GetCurrentLayer() == 'Water' then
			SeaUnit.DeathThread(self, overkillRatio)
        else
            StructureUnit.DeathThread(self, overkillRatio)
        end
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
TypeClass = UUB0102
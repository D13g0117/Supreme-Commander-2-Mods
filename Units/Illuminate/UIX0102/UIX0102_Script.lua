-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uix0102/uix0102_script.lua
--  Author(s):	Gordon Duclos
--  Summary  :  SC2 Illuminate Experimental Sea Hunter: UIX0102
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TurretWeapon = import('/lua/sim/weapon.lua').TurretWeapon

local MAXPODS = 12
local INITIALSPAWNWAITTIME = 1
local SPAWNWAITTIME = 0.8

UIX0102 = Class(ExperimentalMobileUnit) {

	ExhaustAttachBones = {
        'Exhaust01',
        'Exhaust02',
        'Exhaust03',
        'Exhaust04',
        'Exhaust05',
        'Exhaust06',
	},

    EngineRotateBones = {
        'VTOL01',
        'VTOL02',
        'VTOL03',
        'VTOL04',
        'VTOL05',
        'VTOL06',
    },

	BeamExhaust = {
		'/effects/emitters/units/illuminate/uix0102/movement/uix0102_move_beam_01_emit.bp',
		'/effects/emitters/units/illuminate/uix0102/movement/uix0102_move_beam_02_emit.bp',
	},

    Weapons = {
        BodyAim = Class(TurretWeapon) {
            OnFire = function(self)
                local target = self:GetCurrentTarget()
                for k, v in self.unit.Pods do
                    IssueClearCommands({v})
                    IssueAttack({v}, target)
                end
                TurretWeapon.OnFire(self)
            end,
            OnLostTarget = function(self)
                local target = self:GetCurrentTarget()
                for k, v in self.unit.Pods do
                    IssueClearCommands({v})
                    IssueGuard({v}, self.unit)
                end
                TurretWeapon.OnLostTarget(self)
            end,
        },
    },

	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
		self.Pods = {}
		self.TT1 = self:ForkThread( self.SpawnPodThread )

		local army = self:GetArmy()
		self.BeamExhaustEffectsBag = {}

		for kEffect, vEffect in self.BeamExhaust do
			for kBone, vBone in self.ExhaustAttachBones do
				table.insert( self.BeamExhaustEffectsBag, CreateBeamEmitterOnEntity(self, vBone, self:GetArmy(), vEffect ))
			end
		end

        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, 'Thruster', value))
        end

        -- set up the thursting arcs for the engines
        for key,value in self.EngineManipulators do
            --                          XMAX, XMIN, YMAX,YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( 0, 0, -0.50, 0.50, 0, 0, 100, 0.02 )
        end
	end,

    OnTeleportUnit = function(self, teleporter, location, orientation)
		for k, v in self.Pods do
			v:SetParent(nil)
			v:Destroy()
		end
		self.Pods = {}
        ExperimentalMobileUnit.OnTeleportUnit(self, teleporter, location, orientation)
        self.TT1 = self:ForkThread( self.SpawnPodThread )
    end,
	
	OnAddToStorage = function(self, unit)
		ExperimentalMobileUnit.OnAddToStorage(self, unit)
		for k, v in self.Pods do
			v:SetParent(nil)
			v:Destroy()
		end
		self.Pods = {}
	end,
	
	OnRemoveFromStorage = function(self, unit)
		ExperimentalMobileUnit.OnRemoveFromStorage(self, unit)
		self.TT1 = self:ForkThread( self.SpawnPodThread )
	end,

	CreatePod = function( self )
		local location = self:GetPosition('UIX0102')
        local qx, qy, qz, qw = unpack(self:GetOrientation())
        local pod = CreateUnit( 'UIX0116', self:GetArmy(), location[1], location[2] + 4, location[3], qx, qy, qz, qw, 'Air' )
        local dir = VMult(self:GetOrientation(), 2)
        IssueMove({pod}, {location[1]-dir[1], location[2], location[3]-dir[3]})
		pod:SetUnSelectable(true)
		pod:SetDoNotTarget(true)
		pod:SetParent(self)
		table.insert( self.Pods, pod )
		self.Trash:Add( pod )
		IssueGuard( {pod}, self )
	end,
	
	RemovePod = function(self, pod)
		for k, v in self.Pods do
			if pod == v then
				table.remove(self.Pods, k)
				break
			end
		end
	end,

	SpawnPodThread = function(self)
		local lastPosition = VECTOR3(0,0,0)
		WaitSeconds(INITIALSPAWNWAITTIME)

		while table.getn( self.Pods ) < MAXPODS do
			self:CreatePod()
			WaitSeconds(SPAWNWAITTIME)
		end
	end,

    DestroyBeamExhaust = function( self )
        CleanupEffectBag(self,'BeamExhaustEffectsBag')
    end,

    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
		for k, v in self.Pods do
			v:SetParent(nil)
			v:Kill()
		end
		self.Pods = {}
        self:DestroyIdleEffects()
		self:DestroyBeamExhaust()

        if instigator and IsUnit(instigator) then
            instigator:OnKilledUnit(self)
        end
    end,
	
    OnDestroyed = function(self, instigator, type, overkillRatio)
		for k, v in self.Pods do
			v:SetParent(nil)
			v:Destroy()
		end
		self.Pods = {}
    end,

    SinkingThread = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sy * sz
        local army = self:GetArmy()

		if self:PrecacheDebris() then
			WaitTicks(1)
		end

		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect

		if ExplosionEffect then
			local faction = bp.General.FactionName
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Units[faction][layer].General[ExplosionEffect]
			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
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
            local rs = Random(vol/2, vol*2) / (vol*2)
            CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

            i = i - 1
            WaitSeconds(1)
        end
    end,

    OnImpact = function(self, with, other)
		if not self:IsDead() then
			return
		end

        if with == 'Water' then
            self:PlayUnitSound('AirUnitWaterImpact')
            
            for k, v in EffectTemplates.WaterSplash01 do
				CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(1.6)
			end
            
            self:DestroyAllDamageEffects()
			self:PlayUnitAmbientSound('Sinking')
            self.SinkThread = self:ForkThread(self.SinkingThread)
            --self:Destroy()
        else
            -- This is a bit of safety to keep us from calling the death thread twice in case we bounce twice quickly
            if not self.DeathBounce then
				self:StopUnitAmbientSound('Sinking')
                self:ForkThread(self.DeathThread, self.OverKillRatio )
                self.DeathBounce = 1
            end
        end
    end,

}
TypeClass = UIX0102
-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0111/uix0111_eyelaser.lua
--  Author(s): Jessica Snook, Matt Vainio, Gordon Duclos
--  Summary  : SC2 Illuminate Eye Laser Weapon: UIX0111_EyeLaser
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollosusCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').CollosusCollisionBeam

EyeLaser = Class(DefaultBeamWeapon) {
    BeamType = CollosusCollisionBeam,
    FxUpackingChargeEffectScale = 1,
    
    OnCreate = function(self)
        DefaultBeamWeapon.OnCreate(self)
        
        self.BeamEffectsBag = {}
        self.Trash = TrashBag()
    end,
    
    OnDestroy = function(self)
        DefaultBeamWeapon.OnDestroy(self)
    
        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,

	IdleState = State (DefaultBeamWeapon.IdleState) {
        Main = function(self)
            if self.TargetCheckThread then
                KillThread(self.TargetCheckThread)
            end
            DefaultBeamWeapon.IdleState.Main(self)
        end,

        OnGotTarget = function(self)
            local target = self:GetCurrentTarget()

            if target and IsBlip(target) then
                target = target:GetSource()
            end

            if target and target.DeathClawed then
                --LOG("EYE LAZER - Target already deathclawed")
                self:ResetTarget()
                return
            end

            DefaultBeamWeapon.IdleState.OnGotTarget(self)
        end,

        OnExitState = function(self)
            if self.unit:IsDead() then return end

            self.TargetCheckThread = self:ForkThread(self.CheckTargets)
        end,
    },

    CheckTargets = function(self)
        while not self.unit:IsDead() do
            local target = self:GetCurrentTarget()

            if target and IsBlip(target) then
                target = target:GetSource()
            end

            if target and (target.Grabbed or target:IsEntityState('DoNotTarget')) then
                --LOG("EYE LAZER - Target already deathclawed")
                self:ResetTarget()
            end

            WaitTicks(1)
        end
    end,
    
    PlayFxBeamStart = function(self, muzzle)
        DefaultBeamWeapon.PlayFxBeamStart(self, muzzle)
        
        local army = self.unit:GetArmy()
        for k, v in EffectTemplates.Weapons.Illuminate_Beam01_CustomMuzzle01 do
            local fx = CreateAttachedEmitter(self.unit, 'UIX0111_Chest', army, v)
            table.insert( self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end              
    end,	
    
    PlayFxBeamEnd = function(self, beam)
        DefaultBeamWeapon.PlayFxBeamEnd(self, beam)
        
        for k, v in self.BeamEffectsBag do
            v:Destroy()
        end
        self.BeamEffectsBag = {}
    end,
}
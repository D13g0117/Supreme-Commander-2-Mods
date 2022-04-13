-----------------------------------------------------------------------------
--  File     : /units/uef/uux0104/uux0104_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Experimental Aircraft Carrier: UUX0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalSeaUnit = import('/lua/sim/ExperimentalSeaUnit.lua').ExperimentalSeaUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUX0104 = Class(ExperimentalSeaUnit) {
    FxDamage1 = {EffectTemplates.DamageSparks01},
    FxDamage2 = {EffectTemplates.DamageSparks01},
    FxDamage3 = {EffectTemplates.DamageSparks01},

    Weapons = {
        Turret01 = Class(DefaultProjectileWeapon) {},
        Turret02 = Class(DefaultProjectileWeapon) {},
        Torpedo01 = Class(DefaultProjectileWeapon) {},
        Torpedo02 = Class(DefaultProjectileWeapon) {},
    },

    OnCreate = function(self, createArgs)
        ExperimentalSeaUnit.OnCreate(self, createArgs)
		self.UnitBeingBuilt = nil
        self.OpenAnimManips = {}
        self.OpenAnimManips[1] = CreateAnimator(self):PlayAnim('/units/UEF/UUX0104/UUX0104_aopen01.sca'):SetRate(-1)
        for k, v in self.OpenAnimManips do
            self.Trash:Add(v)
        end
        if self:GetCurrentLayer() == 'Water' then
            self:PlayAllOpenAnims(true)
        end
    end,

    PlayAllOpenAnims = function(self, open)
        for k, v in self.OpenAnimManips do
            if open then
                v:SetRate(1)
            else
                v:SetRate(-1)
            end
        end
    end,

    OnMotionVertEventChange = function( self, new, old )
        ExperimentalSeaUnit.OnMotionVertEventChange(self, new, old)
        if new == 'Down' then
			self:RemoveCommandCap('RULEUCC_Transport')
            self:PlayAllOpenAnims(false)
        elseif new == 'Top' then
			self:AddCommandCap('RULEUCC_Transport')
            self:PlayAllOpenAnims(true)
        end
    end,

    BuildAttachBone = 'UUX0104',

    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalSeaUnit.OnStopBeingBuilt(self,builder,layer)
        self:DetachAll(self.BuildAttachBone)
		if self:GetBlueprint().Build.UseBuildMaterial then
			self:SetTextureSetByName("Base")
		end
    end,

    OnStartBuild = function(self, unitBuilding, order)
        ExperimentalSeaUnit.OnStartBuild(self, unitBuilding, order)

        self.UnitBeingBuilt = unitBuilding
        unitBuilding:SetDoNotTarget(true)
        unitBuilding:SetCanTakeDamage(false)
        unitBuilding:SetUnSelectable(true)
        unitBuilding:HideMesh()
        local bone = self.BuildAttachBone
        self:DetachAll(bone)
        unitBuilding:AttachBoneTo(-2, self, bone)
        self.UnitDoneBeingBuilt = false
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        ExperimentalSeaUnit.OnStopBuild(self, unitBeingBuilt)
        if not unitBeingBuilt or unitBeingBuilt:IsDead() then
            return
        end

        unitBeingBuilt:DetachFrom(true)
        unitBeingBuilt:SetDoNotTarget(false)
        unitBeingBuilt:SetCanTakeDamage(true)
        unitBeingBuilt:SetUnSelectable(false)
        self:DetachAll(self.BuildAttachBone)
        if self:TransportHasAvailableStorage(unitBeingBuilt) then
            self:TransportAddUnitToStorage(unitBeingBuilt)
        else
            local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
            IssueMoveOffFactory({unitBeingBuilt}, worldPos)
            unitBeingBuilt:ShowMesh()
        end
        
        -- If there are no available storage slots, pause the builder!
        if self:GetNumberOfAvailableStorageSlots() == 0 then
            self:SetBuildDisabled(true)
            self:SetPaused(true)
        end        
        
		self.UnitBeingBuilt = nil
        self:RequestRefreshUI()
    end,

    OnFailedToBuild = function(self)
        ExperimentalSeaUnit.OnFailedToBuild(self)
        self:DetachAll(self.BuildAttachBone)
    end,
    
    OnTransportUnloadUnit = function(self,unit)
        if self:IsBuildDisabled() and self:GetNumberOfAvailableStorageSlots() > 0 then
            self:SetBuildDisabled(false)
            self:RequestRefreshUI()
        end   
    end,

    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(vol/18)
    end,

    SinkingEffects = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = (sx * sz)/2   
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
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_bubbles_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(vol/12)
            
            i = i - 1
            WaitSeconds(1)
        end
        
    end,
}
TypeClass = UUX0104
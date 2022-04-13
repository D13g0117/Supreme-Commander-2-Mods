-----------------------------------------------------------------------------
--  File     : /units/cybran/ucm0001/ucm0001_script.lua
--  Author(s): Drew Staltman, Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Cybran Commander Escape Pod - UCM0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local BareBonesWeapon = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon

UCM0001 = Class(AirUnit) {
    BeamExhaustIdle = {	'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_01_beam_emit.bp', },
    BeamExhaustCruise = { '/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_04_beam_idle_emit.bp', },

    Weapons = {
        DeathWeapon = Class(BareBonesWeapon) {
            OnFire = function(self)
            end,

            Fire = function(self)
				local bp = self:GetBlueprint()
				local proj = self.unit:CreateProjectile( bp.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
				proj:PassDamageData(self:GetDamageTable())
				proj:PassData(bp.NukeData)
            end,
        },
    },
		
	OnCreate = function(self)
		AirUnit.OnCreate(self)
		self:SetCapturable(false)
		
		for k, v in EffectTemplates.UEFEscapePodEjectEffect01 do
			CreateAttachedEmitter( self, -2, self:GetArmy(), v )
		end
	end,
    
    OnFailedToBuild = function(self)
		AirUnit.OnFailedToBuild(self)
		self:SetUnSelectable(false)

		if self:GetHealth() <= 0 then
			if self.unitBeingBuilt and not self.unitBeingBuilt:IsDead() then
				self.unitBeingBuilt:SetDeathWeaponEnabled(false)
				self.unitBeingBuilt:Kill()
				self.unitBeingBuilt = nil
			end
		end		
    end,	
	
    OnStopBuild = function(self, unitBeingBuilt, order)
        AirUnit.OnStopBuild(self, unitBeingBuilt, order)
        if ( unitBeingBuilt and not unitBeingBuilt:IsDead() and not unitBeingBuilt:IsBeingBuilt() ) then
            local aiBrain = self:GetAIBrain()
            unitBeingBuilt:SetCustomName( aiBrain.Nickname )
			unitBeingBuilt:ShowBone('UCL0001_Head',true)
			unitBeingBuilt:SetUnSelectable(false)
			self.unitBeingBuilt = nil
            self:Destroy()
        end
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AirUnit.OnStartBuild(self, unitBeingBuilt, order)
        AirUnit.StartBuildingEffects(self, unitBeingBuilt, order)
		unitBeingBuilt:HideBone('UCL0001_Head',true)
		self:SetUnSelectable(true)
		unitBeingBuilt:SetUnSelectable(true)
		self.unitBeingBuilt = unitBeingBuilt
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
		local buildBone = 'UCL0001_Head'
		local army = self:GetArmy()

		for kBone, vBone in self:GetBlueprint().Build.EffectBones do
			self.BuildEffectsBag:Add( AttachBeamEntityToEntity( self, vBone, unitBeingBuilt, buildBone, army, '/effects/emitters/units/general/event/repair/repair_01_beam_emit.bp' ) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( unitBeingBuilt, buildBone, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_15_weldglow_emit.bp' ):ScaleEmitter(0.5) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( unitBeingBuilt, buildBone, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_06_fire_emit.bp' ):ScaleEmitter(0.5) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( unitBeingBuilt, buildBone, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_03_sparks_emit.bp' ):ScaleEmitter(0.5) )
			self.BuildEffectsBag:Add( CreateAttachedEmitter( unitBeingBuilt, buildBone, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_18_bluesparks_emit.bp' ):ScaleEmitter(0.5) )
		end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.DeathWeaponEnabled != false then
			self.Callbacks.OnKilled:Call( self, instigator, type )

			if instigator and IsUnit(instigator) then
				instigator:OnKilledUnit(self)
			end                
            self:DoDeathWeapon()
			self:Destroy()
        else
			AirUnit.OnKilled(self, instigator, type, overkillRatio)
		end
    end,
}
TypeClass = UCM0001
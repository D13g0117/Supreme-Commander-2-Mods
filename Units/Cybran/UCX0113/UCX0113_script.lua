-----------------------------------------------------------------------------
--  File     : UCX0113
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Krakken!
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalSeaUnit = import('/lua/sim/ExperimentalSeaUnit.lua').ExperimentalSeaUnit
local TurretWeapon = import('/lua/sim/weapon.lua').TurretWeapon
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local KrakenCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').KrakenCollisionBeam

local TentacleBeamWeapon = Class(DefaultBeamWeapon) {
	BeamType = KrakenCollisionBeam,
}

UCX0113 = Class(ExperimentalSeaUnit) {

	Unpacked = false,

    Weapons = {
		BodyAim = Class(TurretWeapon) {
			OnGotTarget = function(self)
				if not self.unit:IsMoving() then
					self.unit:SendAnimEvent( 'OnDeploy' )
					self.unit:PlayUnitSound('Unpack')	
				end
				TurretWeapon.OnGotTarget(self)
			end,

			OnLostTarget = function(self)
				if not self.unit.packed then
					self.unit:SendAnimEvent( 'SetLooping', 'false' )
					self.unit:PlayUnitSound('Pack')
					self.unit:OnTentaclePackup()
				end
				TurretWeapon.OnLostTarget( self )
			end,
		},
		Tentacle01 = Class(TentacleBeamWeapon) {},
		Tentacle02 = Class(TentacleBeamWeapon) {},
		Tentacle03 = Class(TentacleBeamWeapon) {},
		Tentacle04 = Class(TentacleBeamWeapon) {},
		Tentacle05 = Class(TentacleBeamWeapon) {},
		Tentacle06 = Class(TentacleBeamWeapon) {},
		Tentacle07 = Class(TentacleBeamWeapon) {},
		Tentacle08 = Class(TentacleBeamWeapon) {},
        Torpedo01 = Class(DefaultProjectileWeapon) {},
        Torpedo02 = Class(DefaultProjectileWeapon) {},
    },

    OnCreate = function(self, createArgs)
        ExperimentalSeaUnit.OnCreate(self, createArgs)

		-- Initialize amphibious walker animset
		local animset = self:GetBlueprint().AnimSet
		if animset then
			self:PushAnimSet(animset, "Base");
		end
    end,

	OnStopBeingBuilt = function(self, builder, layer)
		ExperimentalSeaUnit.OnStopBeingBuilt(self, builder, layer)
		self:SendAnimEvent( 'OnIdleUnderwater' )
		
		self.packed = true;

		CreateRotator( self, 'ucx0113_Thruster', 'z', nil, 0, 60, 360):SetTargetSpeed(250)
		
		if self:GetBlueprint().Build.UseBuildMaterial then
			self:SetTextureSetByName("Base")
		end   		
	end,

    OnMotionHorzEventChange = function( self, new, old )
		ExperimentalSeaUnit.OnMotionHorzEventChange(self, new, old)
		local layer = self:GetCurrentLayer()

		if ( new != 'Stopped' ) then
			if layer == 'Sub' then
				self:SendAnimEvent( 'OnMoveUnderwater' )
			else
				self:SendAnimEvent( 'OnMoveSurface' )
				if not self.packed then
					self:PlayUnitSound('Pack')
					self:OnTentaclePackup()
				end
			end
		elseif ( new == 'Stopped' ) then
			self:SendAnimEvent( 'SetLooping', 'false' )
			if self.packed and self:GetWeapon('BodyAim'):WeaponHasTarget() then
				self:SendAnimEvent( 'OnDeploy' )
                self:PlayUnitSound('Unpack')
			end
		end
    end,

	OnMotionVertEventChange = function( self, new, old )
        ExperimentalSeaUnit.OnMotionVertEventChange( self, new, old )

		-- Support only for walking land unit animations with jump jets
		if new == 'Down' and old == 'Top' then
			self:SendAnimEvent( 'OnTransitionToUnderwater' )
		elseif new == 'Up' and old == 'Bottom' then
			self:SendAnimEvent( 'OnTransitionToSurface' )
		end
	end,

	OnAnimEndTrigger = function(self,event)
		if event == 'OnDeployed' then
            self:SetWeaponEnabledByLabel('Tentacle01', true)
            self:SetWeaponEnabledByLabel('Tentacle02', true)
            self:SetWeaponEnabledByLabel('Tentacle03', true)
            self:SetWeaponEnabledByLabel('Tentacle04', true)
            self:SetWeaponEnabledByLabel('Tentacle05', true)
            self:SetWeaponEnabledByLabel('Tentacle06', true)
            self:SetWeaponEnabledByLabel('Tentacle07', true)
            self:SetWeaponEnabledByLabel('Tentacle08', true)
			self.packed = false;
		end
	end,

	OnTentaclePackup = function(self)
		self:GetWeapon('Tentacle01'):OnHaltFire()
		self:GetWeapon('Tentacle02'):OnHaltFire()
		self:GetWeapon('Tentacle03'):OnHaltFire()
		self:GetWeapon('Tentacle04'):OnHaltFire()
		self:GetWeapon('Tentacle05'):OnHaltFire()
		self:GetWeapon('Tentacle06'):OnHaltFire()
		self:GetWeapon('Tentacle07'):OnHaltFire()
		self:GetWeapon('Tentacle08'):OnHaltFire()
        self:SetWeaponEnabledByLabel('Tentacle01', false)
        self:SetWeaponEnabledByLabel('Tentacle02', false)
        self:SetWeaponEnabledByLabel('Tentacle03', false)
        self:SetWeaponEnabledByLabel('Tentacle04', false)
        self:SetWeaponEnabledByLabel('Tentacle05', false)
        self:SetWeaponEnabledByLabel('Tentacle06', false)
        self:SetWeaponEnabledByLabel('Tentacle07', false)
        self:SetWeaponEnabledByLabel('Tentacle08', false)
		self.packed = true;
	end,
}
TypeClass = UCX0113
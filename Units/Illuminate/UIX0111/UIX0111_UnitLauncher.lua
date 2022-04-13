-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0111/uix0111_unitlauncher.lua
--  Author(s): Jessica Snook, Gordon Duclos
--  Summary  : SC2 Illuminate Unit Launcher Weapon: UIX0111_UnitLauncher
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UnitLauncher = Class(DefaultProjectileWeapon) {

    CreateProjectileAtMuzzle = function( self, muzzle )
        if self.CountdownThread then
            KillThread( self.CountdownThread )
            self.CountdownThread = nil
        end

		--LOG( 'UnitLauncher01 CreateProjectileAtMuzzle' )
        local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

		if self.UnitAmmo and not self.UnitAmmo:IsDead() then
			--LOG( 'Has unit ammo' )
			if proj then
				self.UnitAmmo:DetachFrom(true)
				self.UnitAmmo:AttachTo(proj, -1)
				proj:SetUnitAmmo( self.UnitAmmo )
			else
				self.UnitAmmo:Kill(self.unit)
			end
		end
	
		self.UnitAmmo = nil		

		self.AimControl:SetResetPoseTime(100)
		self:SetEnabled(false)
		self:ResetTarget()
		self.tt1 = self:ForkThread(self.ClawEnableThread)
    end,

	ClawEnableThread = function( self )
		WaitSeconds( 1.0 )
		
        if not self.unit or self.unit:IsDead() then
            return
        end
		
		self.unit:RetractClaw(self:GetBlueprint().ClawIndex or 0)
		
		WaitSeconds( 1.0 )

        if not self.unit or self.unit:IsDead() then
            return
        end

		self.AimControl:SetFrozen(false)
		self.AimControl:SetEnabled(false)

		if self.ClawWeapon then
			self.ClawWeapon:SetEnabled(true)
            local heading,pitch = self.AimControl:GetHeadingPitch()
            self.ClawWeapon.AimControl:SetHeadingPitch(heading,pitch)
			self.ClawWeapon.AimControl:SetEnabled(true)
		end
		self.tt1 = nil
	end,

	AddUnitAmmo = function( self, newAmmo )
		self.UnitAmmo = newAmmo
        self.CountdownThread = self:ForkThread( self.AmmoCountdown )
	end,

    AmmoCountdown = function(self)
        WaitSeconds(10)
        if not self.unit or self.unit:IsDead() then
            return
        end

        if self.UnitAmmo and not self.UnitAmmo:IsDead() then
			self.UnitAmmo:DetachFrom(true)
            self.UnitAmmo:Kill()
            self.UnitAmmo = nil
		    self:SetEnabled(false)
		    self:ResetTarget()
		    self.AimControl:SetEnabled(false)
		    self.tt1 = self:ForkThread(self.ClawEnableThread)
        end
    end,

	OnDestroy = function(self)
		if self.CountdownThread then
            KillThread( self.CountdownThread )
            self.CountdownThread = nil
        end
		if self.tt1 then
            KillThread( self.tt1 )
            self.tt1 = nil
        end
		DefaultProjectileWeapon.OnDestroy(self)
	end,
}
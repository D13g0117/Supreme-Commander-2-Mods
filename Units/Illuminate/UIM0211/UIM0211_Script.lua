-----------------------------------------------------------------------------
--  File     : /units/illuminate/uim0211/uim0211_script.lua
--  Author(s): Gordon, Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Shield Upgrade: UIM0211
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UIM0211 = Class(StructureUnit) {

	ShieldEffects = {
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_05_glow_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_06_upwardwisps_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_07_plasmacore_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_08_corewisps_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
		self:SetCapturable(false)
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)
		StructureUnit.OnStopBeingBuilt(self,builder,layer)
		if self.UpgradeParent then
			self.UpgradeParent:CreateShield()
		end

		self.Spinners = {
			Spinner01 = CreateRotator(self, 'UIB0202_Ring02', 'y', nil, 0, 50, 360):SetTargetSpeed(-10),
		}
		self.Trash:Add(self.Spinner)
	end,
	
	OnShieldEnabled = function(self)
        self:PlayUnitSound('ShieldOn')
        StructureUnit.OnShieldEnabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end
        
    end,
    
    OnShieldDisabled = function(self)
        self:PlayUnitSound('ShieldOff')
        StructureUnit.OnShieldDisabled(self)
    
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
}
TypeClass = UIM0211
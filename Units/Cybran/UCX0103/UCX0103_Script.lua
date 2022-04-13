-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0103/ucx0103_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Experimental Bomb Bouncer: UCX0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit

local BombEnableThreshold = 4000

local BlastRadius = 20
local BlastHeightBottom = 10
local BlastDamage = 2500
local BlastDamageType = 'Normal'

UCX0103 = Class(ExperimentalMobileUnit) {

    ShieldEffects = {
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_01_emit.bp',
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_02_emit.bp',
        '/effects/emitters/units/cybran/ucb0202/shield/cybran_shield_01_generator_03_emit.bp',
    },

    OnCreate = function(self, createArgs)
        ExperimentalMobileUnit.OnCreate(self, createArgs)

        self.AbsorbLevel = 0
        self.chargeEmitters = {}
        self.ambientEmitters = {}
    end,

    ShieldDamageAbsorbed = function(self, damage)
        ExperimentalMobileUnit.ShieldDamageAbsorbed(self, damage)
		--LOG( 'ShieldDamageAbsorbed ', damage )

        if self.MegaBlastEnabled then
            return
        end

        self.AbsorbLevel = self.AbsorbLevel + damage

		self:SetWorkProgress( self.AbsorbLevel / BombEnableThreshold )
        if self.AbsorbLevel > BombEnableThreshold then
            --LOG('*DEBUG: Enabling bomb bouncer')
            self.MegaBlastEnabled = true

            -- Charge complete effects
		    for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0103.Charged01 do
				table.insert( self.chargeEmitters, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
			end

			-- Speed up spinner
		    self.Spinners.Spinner01:SetTargetSpeed(-200)

			self:SetAbilityEnabled( 'BombBouncerCharge', false )
			self:SetAbilityEnabled( 'BombBouncerMegaBlast', true )
        end
    end,

    OnBombBounceChargeActivate = function(self, abilityBP, state)
        self.AbsorbLevel = BombEnableThreshold
        self.MegaBlastEnabled = true
        self:SetWorkProgress( 1 )
		self:PlayUnitAmbientSound( 'ChargeActivate' )

        -- Charge complete effects
	    for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0103.Charged01 do
			table.insert( self.chargeEmitters, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
		end

		-- Speed up spinner
		self.Spinners.Spinner01:SetTargetSpeed(-200)
		self:SetAbilityEnabled( 'BombBouncerCharge', false )
		self:SetAbilityEnabled( 'BombBouncerMegaBlast', true )
    end,

    OnMegaBlastActivate = function(self, abilityBP, state)
        if not self.MegaBlastEnabled then
            return
        end

        self.MegaBlastEnabled = false
        self.AbsorbLevel = 0
		self:SetWorkProgress( self.AbsorbLevel / BombEnableThreshold )

        local enemies = self:GetAIBrain():GetUnitsAroundPoint( categories.ALLUNITS, self:GetPosition(), BlastRadius, 'Enemy' )
        local filteredEnemies = {}
        local minHeight = self:GetPosition()[2] + BlastHeightBottom

        --for k,v in enemies do
        --    if v:GetPosition()[2] < minHeight then
        --        continue
        --    end
        --        --LOG('*DEBUG: Adding Unit - Height = ' .. v:GetPosition()[2] .. ' - Min Allowed = ' .. minHeight )
        --    table.insert( filteredEnemies, v )
        --end
        --
        for k,v in enemies do
            --LOG('*DEBUG: Damaging unit')
            Damage(self, self:GetPosition(), v, BlastDamage, BlastDamageType)
        end

		self:StopUnitAmbientSound( 'ChargeActivate' )
		self:PlayUnitSound('MegaBlast')

        -- Activation effects for main AOE attack
		CreateBoneEffects( self, -2, self:GetArmy(), EffectTemplates.Units.Cybran.Experimental.UCX0103.MainAttack01 )

		-- Cleanup charged state emitters
		if self.chargeEmitters then
		    for k, v in self.chargeEmitters do
			    v:Destroy()
		    end
		    self.chargeEmitters = {}
		end

		-- Slow down spinner
		self.Spinners.Spinner01:SetTargetSpeed(-10)

		self:SetAbilityEnabled( 'BombBouncerMegaBlast', false )
		self:SetAbilityEnabled( 'BombBouncerCharge', true )
    end,

	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.Spinners = {
            Spinner01 = CreateRotator(self, 'UCX0103_Head', 'z', nil, 0, 60, 360):SetTargetSpeed(-10),
        }
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )

		        -- Charge complete effects
	    for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0103.Ambient01 do
			table.insert( self.ambientEmitters, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
		end
	end,
}
TypeClass = UCX0103
-----------------------------------------------------------------------------
--  File     : /units/illuminate/uim0002/uim0002_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 Illuminate Nanites: UIM0002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultMeleeWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultMeleeWeapon

UIM0002 = Class(MobileUnit) {

	OnCreate = function(self)
		MobileUnit.OnCreate(self)

		local army = self:GetArmy()
		self.AmbientEffects = {}

		-- Nanite spawn in effects
		for k, v in EffectTemplates.GenericTeleportIn01 do
			CreateAttachedEmitter( self, -2, army, v )
		end

		-- Nanite ambient effects
		for kEffect, vEffect in EffectTemplates.RogueNaniteAmbientEffect do
			table.insert( self.AmbientEffects, CreateAttachedEmitter( self, -2, army, vEffect ))
		end
	end,

    Weapons = {

        Sacrifice = Class(DefaultMeleeWeapon) {
            FireMelee = function( self )
                local bp = self:GetBlueprint()
                local unit = self.unit
                local damage = self:GetDamage()

                -- The GetCurrentTarget may return a unit or a blip
                -- If it's a blip we need to get the blip's source (the actual unit)
                local target = self:GetCurrentTarget()
                local realTarget = target
                if realTarget and not IsUnit(realTarget) then
                    realTarget = realTarget:GetSource()
                end

                -- Can't heal or damage props like wreckage
                if IsProp(realTarget) then
                    return
                end

                local unitArmy = self.unit:GetAIBrain():GetArmyIndex()
                local otherArmy = realTarget:GetAIBrain():GetArmyIndex()

                local targetIsAlly = false
                -- If the target is an ally switch to healing
                if IsAlly( unitArmy, otherArmy ) then
                    targetIsAlly = true
                    -- If an ally target is already at max health no sense wasting a good Nanite
                    if realTarget:GetHealthPercent() == 1 or realTarget:IsBeingBuilt() then
                        return
                    end
                end

                if bp.WeaponFireDelay then
                    WaitSeconds( bp.WeaponFireDelay )
                end

                if not realTarget or realTarget:IsDead() then
                    return
                end

                if targetIsAlly then
                    target:AdjustHealth(self.unit, damage)
					self:PlayWeaponSound('Heal')
            		-- heal death effect
            		for kEffect, vEffect in EffectTemplates.RogueNaniteFriendlyDeathEffect do
						CreateAttachedEmitter( self.unit, -2, self.unit:GetArmy(), vEffect )
					end
                else
					self:PlayWeaponSound('Damage')
                    Damage( unit, unit:GetPosition(), realTarget, damage, bp.DamageType )
                    -- damage death effect
            		for kEffect, vEffect in EffectTemplates.RogueNaniteEniemyDeathEffect do
						CreateAttachedEmitter( self.unit, -2, self.unit:GetArmy(), vEffect )
					end
                end

                self:OnWeaponFired()
            end,

            OnWeaponFired = function(self )
                DefaultMeleeWeapon.OnWeaponFired(self )
                if not self.unit:IsDead() then
                    self.unit:Kill()
                end
            end,
        },
    },
}
TypeClass = UIM0002
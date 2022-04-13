-----------------------------------------------------------------------------
--  File     : /units/illuminate/uil0002/uil0002_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Engineer: UIL0002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ConstructionUnit = import('/lua/sim/ConstructionUnit.lua').ConstructionUnit

UIL0002 = Class(ConstructionUnit) {
	IsHoverUnit = true,
}
TypeClass = UIL0002
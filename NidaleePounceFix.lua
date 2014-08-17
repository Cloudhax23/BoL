function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "Pounce" then
		Packet("S_CAST", {spellId = _W}):send()
	end
end

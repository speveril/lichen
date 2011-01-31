function setupmap()
	kk.chrset = 2
end

function entermap()
	for c_index, character in ipairs(geas.party) do
		character.entity.speed = (character.entity.speed / 2)
	end
end

function enter_shodas_brook()
	if geas.party[1].entity.direction == 3 then	-- facing left
		gotomap("town_shodas.map",58,7,'fade')
	elseif geas.party[1].entity.direction == 1 then	-- facing up
		gotomap("town_shodas.map",30,58,'fade')
	end
end
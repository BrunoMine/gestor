--
-- Mod gestor
--
-- Diretrizes
--

-- Variavel de Diretrizes
gestor.diretrizes = {}

-- Lista de vilas (lista de estruturas ja salvas)

gestor.vilas = {}

do
	local list = minetest.get_dir_list(minetest.get_worldpath() .. "/gestor/estruturas")
	for n, arq in ipairs(list) do
		if string.find(arq, ".mts") then
			arq = string.gsub(arq, ".mts", "")
			if arq ~= "centro" then
				table.insert(gestor.vilas, arq)
			end
		end
	end
end

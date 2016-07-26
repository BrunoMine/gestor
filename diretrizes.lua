--
-- Mod gestor
--
-- Diretrizes
--

-- Variavel de Diretrizes
gestor.diretrizes = {}

-- Estruturas
gestor.diretrizes.estruturas = {
	--	arquivo,			largura,	altura
		-- Centro
		["centro"] = 	{	10,		10	},
		-- Vilas
}

-- Lista de vilas (lista de estruturas ja salvas)
gestor.vilas = {
	-- "exemplo",
}


-- Lista-string configurada altomaticamente
gestor.lista_vilas = ""
local i = 1
while (gestor.vilas[i]~=nil) do
	gestor.lista_vilas = gestor.lista_vilas..gestor.vilas[i]
	if i < table.maxn(gestor.vilas) then gestor.lista_vilas = gestor.lista_vilas .. "," end
	i = i + 1
end
-- Variavel de registros
gestor.registros = {}



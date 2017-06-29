--
-- Mod gestor
--
-- Estruturador
--

-- Diretorio do Mundo
local worldpath = minetest.get_worldpath()

-- Nodes que podem ter metadados serializados
local meta_ok = {
	"terrenos:livre",
	"default:sign_wall_wood",
	"default:sign_wall_steel",
	"bau_comunitario:bau",
	"antipvp:placa",
	"portais:bilheteria",
	"macromoney:caixa_de_banco",
}

-- Assegurar pasta de estruturas
do
	local list = minetest.get_dir_list(worldpath, true)
	local r = false
	for n, ndir in ipairs(list) do
		if ndir == "gestor" then
			r = true
			break
		end
	end
	if r == false then
		minetest.mkdir(worldpath.."/gestor")
	end
	
	list = minetest.get_dir_list(worldpath.."/gestor", true)
	r = false
	for n, ndir in ipairs(list) do
		if ndir == "estruturas" then
			r = true
			break
		end
	end
	if r == false then
		minetest.mkdir(worldpath.."/gestor/estruturas")
	end
	
end


-- Variavel global de estruturador
gestor.estruturador = {}


-- Arredondar posicao
local arredondar = function(pos)
	local r = {}
	if pos.x > (math.floor(pos.x)+0.5) then
		r.x = math.ceil(pos.x)
	else
		r.x = math.floor(pos.x)
	end
	if pos.y > (math.floor(pos.y)+0.5) then
		r.y = math.ceil(pos.y)
	else
		r.y = math.floor(pos.y)
	end
	if pos.z > (math.floor(pos.z)+0.5) then
		r.z = math.ceil(pos.z)
	else
		r.z = math.floor(pos.z)
	end
	return r
end


-- Serializar estrutura
gestor.estruturador.salvar = function(pos, nome, largura, altura, path, silencio)
	if not pos or not nome then return false end
	-- arredondar posicao
	local as = pos.x
	pos = arredondar(pos)
	
	if path == nil then
		path = worldpath .. "/gestor/estruturas"
	end
	largura = largura or gestor.diretrizes.estruturas[nome][1]
	altura = altura or gestor.diretrizes.estruturas[nome][1]
	if not largura or not altura then return false end
	
	-- Coordenada do extremo oposto da estrutura
	local pmax = {x=pos.x+largura, y=pos.y+altura, z=pos.z+largura}
	
	-- Criar arquivo schematic
	if silencio == nil or silencio == false then minetest.chat_send_all("Criando arquivo esquematico da estrutura ...") end
	minetest.create_schematic(pos, pmax, {}, path .. "/"..nome..".mts")
	
	-- Metadados de alguns nodes
	local metadados = {}
	
	-- Metadados dos nodes
	metadados.nodes = {}
	
	-- Armazena as dimensoes
	metadados.altura = altura
	metadados.largura = largura
	
	-- Pegar nodes quem podem ter seus metadados serializados
	local nodes = minetest.find_nodes_in_area(pos, pmax, meta_ok)
	
	-- Pegar metadados dos nodes encontrados
	for _,pn in ipairs(nodes) do
		-- Serializa os metadados
		local meta = minetest.get_meta(pn):to_table()
		
		-- Calcula a posicao relativa a coordenada extremo-negativa
		local pr = {x=pn.x-pos.x, y=pn.y-pos.y, z=pn.z-pos.z}
		metadados.nodes[pr.x.." "..pr.y.." "..pr.z] = meta
	end
	
	-- Criar arquivo de metadados
	local output = io.open(path .. "/"..nome..".meta", "w")
	
	-- Serializa os metadados
	if silencio == nil or silencio == false then minetest.chat_send_all("Serializando metadados ...") end
	metadados = minetest.serialize(metadados)
	
	if silencio == nil or silencio == false then minetest.chat_send_all("Escrevendo metadados serializados em arquivo ...") end
	output:write(metadados)
	io.close(output)

	-- Estrutura serializada com sucesso
	return true
end


-- Deserializar uma estrutura
gestor.estruturador.carregar = function(pos, nome, largura, altura, path, silencio)
	if pos == nil or nome == nil then return false end
	if silencio == nil or silencio == false then minetest.chat_send_all("Criando estrutura. Aguarde...") end
	-- Coleta de dados
	local dados = {}
	if path == nil then
		path = worldpath .. "/gestor/estruturas"
	end
	
	-- Obter metadados
	local metadados = ""
	local input = io.open(path .. "/"..nome..".meta", "r")
	if input then
		metadados = input:read("*l")
	else
		return false
	end
	if not metadados then
		minetest.chat_send_all("Erro. Faltou o arquivo de metadados")
		return false
	end 
	io.close(input)
	
	-- Deserializar metadados
	metadados = minetest.deserialize(metadados)
	
	altura = metadados.altura
	largura = metadados.largura
	
	
	
	-- Coordenada do extremo oposto da estrutura
	local pmax = {x=pos.x+largura, y=pos.y+altura, z=pos.z+largura}
	
	-- Colocar estrutura esquematica
	minetest.place_schematic(pos, path.."/"..nome..".mts", nil, nil, true)
	
	-- Restaurar metadados nos nodes
	for pos_string,meta in pairs(metadados.nodes) do
				
		-- Obter pos em tabela
		local pos_tb = string.split(pos_string, " ")
		pos_tb = {x=tonumber(pos_tb[1]),y=tonumber(pos_tb[2]),z=tonumber(pos_tb[3])}
		
		-- Calcular pos real do node
		local pn = {x=pos.x+pos_tb.x, y=pos.y+pos_tb.y, z=pos.z+pos_tb.z}
		
		-- Salva metadados
		minetest.get_meta(pn):from_table(meta)
		
	end	
	
	-- Estrutura construida com sucesso
	if silencio == nil or silencio == false then minetest.chat_send_all("Estrutura construida. Aguarde o mapa ser renderizado.") end
	return true
end

--
-----
--------
-- Nodes restaurador de escadarias
local criar_nivel_escadaria = function(pos, largura, name)
	local limx, limz = pos.x+(largura/2), pos.z+(largura/2)
	local x, z = pos.x-(largura/2), pos.z-(largura/2)
	while (x<=limx) do
		z = pos.z-(largura/2)
		while (z<=limz) do
			local npos = {x=x,y=pos.y,z=z}
			local node = minetest.get_node(npos)
			if node.name == "ignore" then
				minetest.get_voxel_manip():read_from_map(npos, npos)
				node = minetest.get_node(npos)
			end
			if node.name == "air" then
				minetest.set_node(npos, {name=name})
			end
			z=z+1
		end
		x=x+1
	end
end
local criar_escadaria = function(pos, node)
	local npos = {x=pos.x,y=pos.y-10,z=pos.z}
	local altura = pos.y - 8
	while altura <= pos.y do
		criar_nivel_escadaria({x=pos.x,y=altura,z=pos.z}, (math.abs(pos.y-altura)*4)+7, node)
		altura = altura + 1
	end
end
minetest.register_node("gestor:escadaria", {
	description = "Restaurador de escadaria",
	tiles = {
		"default_pine_wood.png",
		"default_pine_wood.png",
		"default_pine_wood.png",
		"default_pine_wood.png",
		"default_pine_wood.png",
		"default_pine_wood.png"
	},
	groups = {choppy=2,oddly_breakable_by_hand=2,wood=1},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos)
		local node = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
		criar_escadaria({x=pos.x,y=pos.y-1,z=pos.z}, node.name)
		minetest.set_node(pos, {name="air"})
		minetest.set_node({x=pos.x,y=pos.y+1,z=pos.z}, {name="air"})
	end,
})
-- Fim
--------
-----
--

-- Pegar metadados da estrutura
gestor.estruturador.get_meta = function(nome)
	local path = worldpath .. "/gestor/estruturas"
	
	-- Obter metadados
	local metadados = ""
	local input = io.open(path .. "/"..nome..".meta", "r")
	if not input then return nil end 
	metadados = input:read("*l")
	io.close(input)
	
	return minetest.deserialize(metadados)
end

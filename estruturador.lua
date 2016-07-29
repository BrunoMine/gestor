--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Estruturador
  ]]

-- Diretorio do Mod
local modpath = minetest.get_modpath("gestor")

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

-- Restaurar as refenrencias em relacao a uma pos
local restaurar_pos = function(pos, ref)
	local r = {}
	r.x, r.y, r.z = (pos.x+ref.x), (pos.y+ref.y), (pos.z+ref.z)
	return r
end

-- calcular o deslocamento de ref em relacao a pos
local ref_pos = function(pos, ref)
	local r = {}
	r.x, r.y, r.z = (ref.x-pos.x), (ref.y-pos.y), (ref.z-pos.z)
	return r
end

-- metodo melhorado para pegar nodes (pega nodes ainda nao carregados)
local function pegar_node(pos)
	local resp = {}
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	resp = {node=node}
	--[[
		Para salvar os metadados é criada um valor meta (node.meta)
		para que alguns dados possam ser mantidos de forma serializada 
		no node e posteriormente serem restaurados quando a estrutura 
		for restaurada
	  ]]
	local meta = minetest.get_meta(pos)
	if node.name == "placa_terreno:livre" then -- placas de terreno
		local ref1 = ""
		local ref2 = ""
		if meta:get_string("ref1") ~= "" then
			-- Mantem os antigos ref's caso existam no metadado
			ref1 = minetest.deserialize(meta:get_string("ref1"))
			ref2 = minetest.deserialize(meta:get_string("ref2"))
		else
			-- Calcula os ref's
			ref1 = minetest.serialize(ref_pos(pos, minetest.deserialize(meta:get_string("pos1"))))
			ref2 = minetest.serialize(ref_pos(pos, minetest.deserialize(meta:get_string("pos2"))))
		end
		local custo = meta:get_string("custo")
		local altura = meta:get_string("altura")
		resp = {node=node,meta={ref1=ref1,ref2=ref2,custo=custo,altura=altura}}
	elseif node.name == "default:sign_wall" then -- placas normais de parede
		local text = meta:get_string("text")
		local infotext = meta:get_string("infotext")
		resp = {node=node,meta={text=text,infotext=infotext}}
	end
	return resp
end


-- Serializar estrutura
gestor.estruturador.salvar = function(pos, nome, largura, altura, modp, silencio)
	if not pos or not nome then return false end
	-- arredondar posicao
	pos = arredondar(pos)
	
	if modp == nil then
		modp = modpath
	end
	largura = largura or gestor.diretrizes.estruturas[nome][1]
	altura = altura or gestor.diretrizes.estruturas[nome][1]
	if not largura or not altura then return false end
	-- Criar estrutura
	if silencio == nil or silencio == false then minetest.chat_send_all("Serializando estrutura. Aguarde...") end
	local estrutura = {}
	local ix, iy, iz = 1, 1, 1
	local x, y, z = pos.x, pos.y, pos.z
	local limx, limy, limz = (pos.x+largura-1), (pos.y+altura-1), (pos.z+largura-1)
	local i = 0
	while (x <= limx) do
		while (y <= limy) do
			while (z <= limz) do
				estrutura[ix.." "..iy.." "..iz] = pegar_node({x = x, y = y, z = z})
				i = i + 1
				z = z + 1
				iz = iz + 1
			end
			z = pos.z
			iz = 1
			y = y + 1
			iy = iy + 1
		end
		y = pos.y
		iy = 1
		x = x + 1
		ix = ix + 1
	end
	
	-- Criar arquivo
	local output = io.open(modp .. "/estruturas/"..nome, "w")
	output:write(minetest.serialize(estrutura))
	io.close(output)

	-- Estrutura serializada com sucesso
	if silencio == nil or silencio == false then minetest.chat_send_all("Serializacao concluida.") end
	return true
end

-- Deserializar uma estrutura
gestor.estruturador.carregar = function(pos, nome, largura, altura, modp, silencio)
	if pos == nil or nome == nil then return false end
	if silencio == nil or silencio == false then minetest.chat_send_all("Criando estrutura. Aguarde...") end
	-- Coleta de dados
	local dados = {}
	if modp == nil then
		dados = gestor.diretrizes.estruturas[nome] or {}
		largura = dados[1] or largura
		altura = dados[2] or altura
		modp = modpath
	end
	if largura == nil or altura == nil or nome == nil then return false end
	local input = io.open(modp .. "/estruturas/"..nome, "r")
	if input then
		dados.estrutura = minetest.deserialize(input:read("*l"))
	else
		return false
	end
	io.close(input)
	-- Criar estrutura
	local ix, iy, iz = 1, 1, 1
	local x, y, z = pos.x, pos.y, pos.z
	local limx, limy, limz = (pos.x+largura-1), (pos.y+altura-1), (pos.z+largura-1)
	local i = 0
	while (x <= limx) do
		while (y <= limy) do
			while (z <= limz) do
				local PosNode = dados.estrutura[ix.." "..iy.." "..iz] or {node={name="air"}}
				minetest.set_node({x = x, y = y, z = z}, PosNode.node)
				if PosNode.meta then
					if PosNode.node.name == "placa_terreno:livre" then
						local meta = minetest.get_meta({x = x, y = y, z = z})
						--[[
							Tenta restaurar pos1 e pos2 mas devido a um erro
							desconhecido as vezes desloca 1 node de distancia 
							para alguma direção
						  ]]
						meta:set_string("pos1", 
							minetest.serialize(restaurar_pos(minetest.deserialize(PosNode.meta.ref1), 
							{x = x, y = y, z = z}))
						)
						meta:set_string("pos2", 
							minetest.serialize(restaurar_pos(minetest.deserialize(PosNode.meta.ref2), 
							{x = x, y = y, z = z}))
						)
						--[[
							Mantes ref1 e ref2 no meto do bloco para evitar distorções maiores
							usando sempre esses ref's a distorção pode ser no maximo 1 node
						  ]]
						meta:set_string("ref1", minetest.serialize(PosNode.meta.ref1))
						meta:set_string("ref2", minetest.serialize(PosNode.meta.ref2))
						meta:set_string("custo", PosNode.meta.custo)
						meta:set_string("altura", PosNode.meta.altura)
						meta:set_string("status", "livre")
						meta:set_string("infotext", "Terreno a Venda")
					elseif PosNode.node.name == "default:sign_wall" then
						local meta = minetest.get_meta({x = x, y = y, z = z})
						meta:set_string("text", PosNode.meta.text)
						meta:set_string("infotext", PosNode.meta.infotext)
					end
				end
				i = i + 1
				z = z + 1
				iz = iz + 1
			end
			z = pos.z
			iz = 1
			y = y + 1
			iy = iy + 1
		end
		y = pos.y
		iy = 1
		x = x + 1
		ix = ix + 1
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

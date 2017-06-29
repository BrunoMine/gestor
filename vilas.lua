--
-- Mod gestor
--
-- Vilas
--


-- Encontrar altura de um bloco alvo (em uma coluna)
local pegar_altura_solo = function(pos, alvos, amplitude)
	if not pos then
		minetest.log("error", "[Plagen] Tabela 'pos' nula (em pegar_altura_solo)")
		return false
	end
	
	local y = pos.y + amplitude
	local resp = pos.y
	while y >= pos.y - amplitude do
		if table.maxn(minetest.find_nodes_in_area({x=pos.x,y=y,z=pos.z}, {x=pos.x,y=y,z=pos.z}, alvos)) == 1 then
			resp = y
			break
		end
		y = y - 1
	end
	return resp
end


-- Comando para colocar vila
--[[
	Esse metodo monta uma vila no mapa e retorna 
	uma mensagem de erro quando ocorre alguma falha 
	ou algo impede
	Retorno:
		<resp> Pode ser true (booleano) caso de tudo certo e
		uma string de mensagem de erro caso ocorra algum problema
	Argumentos:
		<>
  ]]
gestor.montar_vila = function(pos, vila)
	
	-- Verificar dados
	if not pos then
		minetest.log("error", "[Plagen] Tabela 'pos' nula (em gestor.montar_vila)")
		return "Erro interno"
	end
	if not vila then
		minetest.log("error", "[Plagen] String de 'vila' nula (em gestor.montar_vila)")
		return "Erro interno"
	end
	
	-- Destacar tabela pos (evitar bugs)
	pos = {x=pos.x, y=pos.y, z=pos.z}
	
	-- Verificando se ja existe essa vila

	if gestor.bd:verif("vilas", vila) then return "Vila ja existente" end
	
	-- Pegar material do solo
	local p_solo = {x=pos.x, y=pos.y, z=pos.z}
	p_solo.y = pegar_altura_solo(pos, {"default:dirt", "default:desert_sand"}, 15)
	local node_solo = minetest.get_node(p_solo)
	if pos == false then return "Impossivel encontrar solo" end
	if node_solo.name == "default:dirt" then
		p_solo.y = p_solo.y + 1
	elseif node_solo.name == "default:desert_sand" then
		p_solo.y = p_solo.y
	else
		return "Solo inapropriado"
	end
	local solo = minetest.get_node({x=p_solo.x, y=p_solo.y, z=p_solo.z}).name
	local subsolo = minetest.get_node({x=p_solo.x, y=p_solo.y-1, z=p_solo.z}).name
	local rocha = "default:stone"
	local materiais = {solo=solo,subsolo=subsolo,rocha=rocha}
	if solo.name == "air" then return "Falha ao pegar solo" end
	

	-- Adquirindo dados

	local dados = gestor.diretrizes.estruturas[vila]

	if not dados then return "Estrutura nao encontrada" end
	
	-- Planificar
	if plagen.planificar(pos, "quadrada", dados[1]+2, 15, materiais, 15, true, true) ~= true then
		return "Falha ao planificar"
	end
	
	pos.y = pegar_altura_solo(pos, {solo}, 15) + 1
	
	-- Variaveis auxiliares

	local minp = {x=pos.x-(dados[1]/2), y=pos.y-dados[3], z=pos.z-(dados[1]/2)}
	

	-- Construir estrutura

	if gestor.estruturador.carregar(minp, vila) == false then return "Estrutura nao encontrada" end
	
	return true
end

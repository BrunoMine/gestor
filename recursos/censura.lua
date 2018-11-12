--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para censurar palavras no chat publico
  ]]

-- Tradutor de texto
local S = gestor.S

-- Lista de termos proibidos
if gestor.bd.verif("censura", "bad_words_list") == false then
	gestor.bd.salvar("censura", "bad_words_list", {})
end

-- Variavel de controle
local censurar = minetest.settings:get_bool("gestor_censurar_termos_proibidos", false) or false

-- Tabelas de uso
local bad_words = {}
local update_tb_bad_words = function()
	bad_words = gestor.bd.pegar("censura", "bad_words_list")
end
update_tb_bad_words()

-- Controle de acessos
local acessos = {}
minetest.register_on_joinplayer(function(player)
	acessos[player:get_player_name()] = {}
end)
minetest.register_on_leaveplayer(function(player)
	acessos[player:get_player_name()] = nil
end)

-- Registrar aba 'censura'
gestor.registrar_aba("censura", {
	titulo = S("Termos Proibidos"),
	get_formspec = function(name)
		
		-- Gera string dos moderadores listados
		local bad_words_string = ""
		for _,bad_word in pairs(gestor.bd.pegar("censura", "bad_words_list")) do
			if bad_words_string ~= "" then bad_words_string = bad_words_string .. "," end
			bad_words_string = bad_words_string .. bad_word
		end
		
		local formspec = "label[3.5,1;"..S("Termos Proibidos").."]"
			.."label[9,1;"..S("Lista de Termos Proibidos").."]"
			.."textlist[9,1.5;4.5,3;bad_words_list;"..bad_words_string.."]"
			.."field[3.8,2.3;5,1;new_word;"..S("Termo")..";]"
			.."button[3.5,2.9;5,1;add_word;"..S("Adicionar Termo").."]"
			.."button[3.5,3.8;5,1;rem_word;"..S("Remover Termo").."]"
			
			.."checkbox[3.5,4.6;bad_words_status;"..S("Censurar Termos Proibidos")..";"..tostring(minetest.settings:get("gestor_censurar_termos_proibidos", false)).."]"
			
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		-- Selecionar item
		if fields.bad_words_list and table.maxn(gestor.bd.pegar("censura", "bad_words_list")) > 0 then
			local n = string.split(fields.bad_words_list, ":")
			acessos[name].escolha = tonumber(n[2]) or 1
			gestor.menu_principal(name)
		
		-- Adicionar moderador
		elseif fields.add_word and string.lower(fields.new_word) ~= "" then
			local bad_words_list = gestor.bd.pegar("censura", "bad_words_list")
			table.insert(bad_words_list, string.lower(fields.new_word))
			gestor.bd.salvar("censura", "bad_words_list", bad_words_list)
			update_tb_bad_words()
			gestor.menu_principal(name)
		
		-- Remover moderador
		elseif fields.rem_word and acessos[name].escolha then
			local bad_words_list = gestor.bd.pegar("censura", "bad_words_list")
			table.remove(bad_words_list, acessos[name].escolha)
			gestor.bd.salvar("censura", "bad_words_list", bad_words_list)
			update_tb_bad_words()
			gestor.menu_principal(name)
		
		-- Ativar censura
		elseif fields.bad_words_status then
			minetest.settings:set("gestor_censurar_termos_proibidos", fields.bad_words_status)
			minetest.settings:write()
			censurar = minetest.settings:get_bool("gestor_censurar_termos_proibidos", false)
			
		-- Sair
		elseif fields.exit then
			acessos[name].escolha = nil
		end
	end,
})

-- Impedir jogadores silenciados de falaram no chat e restaura o priv de fala se estiver acabado o periodo de penalidade
minetest.register_on_chat_message(function(name, message)
	
	if censurar == false then return end
	
	-- Deixa todas as palavras no minusculo
	local m = string.lower(message)
	
	-- Tenta encontrar cada um dos termos os termos
	for _,w in ipairs(bad_words) do
		-- Varre a mensagem em busca do termo
		if string.match(m, w) then
			-- Caso encontrar, notifica o jogador
			minetest.chat_send_player(name, S("Proibido usar o termo @1", minetest.colorize("#FF0000", m)))
			return true
		end
	end
end)



--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Castigo a jogadores
  ]]


-- Controle de acessos
local acessos = {}
minetest.register_on_joinplayer(function(player)
	acessos[player:get_player_name()] = {}
end)
minetest.register_on_leaveplayer(function(player)
	acessos[player:get_player_name()] = nil
end)

-- Penalidades
local penas = {
	"Silenciar",
	"Banir",
}

-- Gera string para formspec
local penas_list_string = ""
for _,name in ipairs(penas) do
	if penas_list_string ~= "" then penas_list_string = penas_list_string .. "," end
	penas_list_string = penas_list_string .. name
end

-- Tempos para penalidades
local tempos_penas = {
	"1 minuto",
	"5 minutos",
	"15 minutos",
	"30 minutos",
	"1 hora",
	"6 horas",
	"12 horas",
	"1 dia",
	"2 dias",
	"3 dias",
	"4 dias",
	"5 dias",
	"10 dias",
	"15 dias",
	"20 dias",
	"25 dias",
	"30 dias",
	"2 meses",
	"3 meses",
	"4 meses",
	"5 meses",
	"6 meses",
	"1 ano",
	"2 anos",
	"sempre"
}
-- Gera string para formspec
local tempos_penas_list_string = ""
for _,name in ipairs(tempos_penas) do
	if tempos_penas_list_string ~= "" then tempos_penas_list_string = tempos_penas_list_string .. "," end
	tempos_penas_list_string = tempos_penas_list_string .. name
end

-- Termos proibidos


-- Registrar aba 'penalidades'
gestor.registrar_aba("penalidades", {
	titulo = "Penalidades",
	get_formspec = function(name)
		
		local formspec = "label[3.5,1;Penalidades]"
			
			.."field[3.8,2.3;5,1;jogador;Jogador a penalizar;]"
			.."button[3.5,2.9;5,1;rem_pena;Remover Penalidades]"
			
			.."label[8.5,1.65;Pena]"
			.."dropdown[8.5,2.08;3,1;tipo_pena;"..penas_list_string..";]"
			.."label[11.4,1.65;Tempo]"
			.."dropdown[11.4,2.08;2,1;tempo_pena;"..tempos_penas_list_string..";]"
			.."button[8.5,2.9;5,1;add_pena;Aplicar Penalidade]"
		
		if acessos[name].aviso_penalidades then
			formspec = formspec.."label[3.5,3.8;"..acessos[name].aviso_penalidades.."]"
			acessos[name].aviso_penalidades = nil
		end
		
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		-- Adicionar pena
		if fields.add_pena then
			-- Verificar nome informado
			if fields.jogador == "" then
				acessos[name].aviso_penalidades = "Nenhum jogador informado"
				gestor.menu_principal(name)
				return 
			end
			
			-- Penalizar jogador
			gestor.penalizar(fields.jogador, fields.tipo_pena, fields.tempo_pena)
			acessos[name].aviso_penalidades = "Penalidade aplicada em "..fields.jogador
			gestor.menu_principal(name)
		
		-- Remover pena
		elseif fields.rem_pena then
			-- Verificar nome informado
			if fields.jogador == "" then
				acessos[name].aviso_penalidades = "Nenhum jogador informado"
				gestor.menu_principal(name)
				return 
			end
			
			for _,p in ipairs(penas) do
				gestor.remover_penalidade(fields.jogador, p)
			end
			acessos[name].aviso_penalidades = "Todas penalidades removidas de "..fields.jogador
			gestor.menu_principal(name)
		end
		
	end,
})

-- Remover penalidade
gestor.remover_penalidade = function(name, pena)
	if pena == "Banir" then
		gestor.bd.remover("penalizados", "Banir_"..name)
		
	elseif pena == "Silenciar" then
	
		local privs = minetest.get_player_privs(name)
		privs.shout = true
		minetest.set_player_privs(name, privs)
		gestor.bd.remover("penalizados", "Silenciar_"..name)
	end
end

-- Penalizar jogador
gestor.penalizar = function(name, pena, tempo)
	
	-- Em caso de banimento ja expulsa do servidor
	if pena == "Banir" then
		minetest.kick_player(name, "Foste expulso do servidor")
	end
	
	-- Remove priv shout se for silenciar
	if pena == "Silenciar" then
		local privs = minetest.get_player_privs(name)
		privs.shout = nil
		minetest.set_player_privs(name, privs)
	end
	
	if tempo == "sempre" then
		-- Salva pena no banco de dados
		gestor.bd.salvar("penalizados", pena.."_"..name, "sempre")
		return
	end
	
	-- Calcular data a ser adicionada para contagem
	local data_add = {}
	local t = string.split(tempo, " ")
	if t[2] == "minuto" or t[2] == "minutos" then
		data_add = {
			minutos = tonumber(t[1]),
			horas = 0,
			dias = 0,
			meses = 0,
			anos = 0,
		}
	elseif t[2] == "hora" or t[2] == "horas" then
		data_add = {
			minutos = 0,
			horas = tonumber(t[1]),
			dias = 0,
			meses = 0,
			anos = 0,
		}
	elseif t[2] == "dia" or t[2] == "dias" then
		data_add = {
			minutos = 0,
			horas = 0,
			dias = tonumber(t[1]),
			meses = 0,
			anos = 0,
		}
	elseif t[2] == "mes" or t[2] == "meses" then
		data_add = {
			minutos = 0,
			horas = 0,
			dias = 0,
			meses = tonumber(t[1]),
			anos = 0,
		}
	elseif t[2] == "ano" or t[2] == "anos" then
		data_add = {
			minutos = 0,
			horas = 0,
			dias = 0,
			meses = 0,
			anos = tonumber(t[1]),
		}
	end
	
	local data_fim = gestor.calcular_data_fim(data_add)
	
	-- Salva pena no banco de dados
	gestor.bd.salvar("penalizados", pena.."_"..name, data_fim)
end

-- Impedir jogadores banidos de reconectar
minetest.register_on_prejoinplayer(function(name)
	
	-- Verificar se existe pena de banimento no banco de dados
	if gestor.bd.verif("penalizados", "Banir_"..name) ~= true then return end
	
	-- Verificar data
	local data_fim = gestor.bd.pegar("penalizados", "Banir_"..name)
	
	-- Caso seja banimento permanente
	if data_fim == "sempre" then
		return "Foste banido permanentemente deste servidor"
	
	-- Caso seja banimento temporario
	else
		local dif_dias, dif_horas, dif_minutos = gestor.comparar_data(data_fim[1], data_fim[2], data_fim[3], data_fim[4], data_fim[5])
		if dif_dias > 0 or dif_horas > 0 or dif_minutos > 0 then
			local rest = ""
			if dif_dias > 0 then rest = rest..dif_dias.."d " end
			if dif_horas > 0 then rest = rest..dif_horas.."h " end
			if dif_minutos > 0 then rest = rest..dif_minutos.."min " end
			return "Foste banido temporariamente. Restam ainda "..rest.."para poderes retornar"
		else
			-- Fim da penalidade
			gestor.remover_penalidade(name, "Banir")
			return
		end
	end
end)

-- Impedir jogadores silenciados de falaram no chat e restaura o priv de fala se estiver acabado o periodo de penalidade
minetest.register_on_chat_message(function(name, message)
	
	-- Verifica se tem o priv de fala
	if minetest.check_player_privs(name, {shout=true}) == true then return end
	
	-- Verificar se existe pena de banimento no banco de dados
	if gestor.bd.verif("penalizados", "Silenciar_"..name) ~= true then return end
	
	-- Verificar data
	local data_fim = gestor.bd.pegar("penalizados", "Silenciar_"..name)
	
	-- Caso seja banimento permanente
	if data_fim == "sempre" then
		minetest.chat_send_player(name, "Foste silenciado permanentemente neste servidor")
		return
	-- Caso seja banimento temporario
	else
		local dif_dias, dif_horas, dif_minutos = gestor.comparar_data(data_fim[1], data_fim[2], data_fim[3], data_fim[4], data_fim[5])
		if dif_dias > 0 or dif_horas > 0 or dif_minutos > 0 then
			local rest = ""
			if dif_dias > 0 then rest = rest..dif_dias.."d " end
			if dif_horas > 0 then rest = rest..dif_horas.."h " end
			if dif_minutos > 0 then rest = rest..dif_minutos.."min " end
			minetest.chat_send_player(name, "Foste silenciado temporariamente. Restam ainda "..rest.."para poderes voltar a falar normalmente")
			return
		else
			-- Fim da penalidade
			gestor.remover_penalidade(name, "Silenciar")
			return
		end
	end
	
end)

--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Castigo a jogadores
  ]]

-- Tradutor de texto
local S = gestor.S

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
	S("Silenciar"),
	S("Banir"),
}
local get_pena_st = {
	[penas[1]] = "Silenciar",
	[penas[2]] = "Banir",
}

-- Gera string para formspec
local penas_list_string = ""
for _,name in ipairs(penas) do
	if penas_list_string ~= "" then penas_list_string = penas_list_string .. "," end
	penas_list_string = penas_list_string .. name
end

-- Tempos para penalidades
local tempos_penas = {
	S("@1 minutos", 30),
	S("@1 hora", 1),
	S("@1 horas", 3),
	S("@1 horas", 6),
	S("@1 horas", 12),
	S("@1 dia", 1),
	S("@1 dias", 3),
	S("@1 dias", 10),
	S("@1 dias", 20),
	S("@1 dias", 30),
	S("@1 meses", 2),
	S("@1 meses", 6),
	S("@1 ano", 1),
	S("@1 anos", 2),
	S("sempre")
}

local get_tempo_st = {
	[tempos_penas[1]] = "30 minutos",
	[tempos_penas[2]] = "1 hora",
	[tempos_penas[3]] = "3 horas",
	[tempos_penas[4]] = "6 horas",
	[tempos_penas[5]] = "12 horas",
	[tempos_penas[6]] = "1 dia",
	[tempos_penas[7]] = "3 dias",
	[tempos_penas[8]] = "10 dias",
	[tempos_penas[9]] = "20 dias",
	[tempos_penas[10]] = "30 dias",
	[tempos_penas[11]] = "2 meses",
	[tempos_penas[12]] = "6 meses",
	[tempos_penas[13]] = "1 ano",
	[tempos_penas[14]] = "2 anos",
	[tempos_penas[15]] = "sempre"
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
	titulo = S("Penalidades"),
	get_formspec = function(name)
		
		local formspec = "label[3.5,1;"..S("Penalidades").."]"
			
			.."field[3.8,2.3;5,1;jogador;"..S("Jogador a penalizar")..";]"
			.."button[3.5,2.9;5,1;rem_pena;"..S("Remover Penalidades").."]"
			
			.."label[8.5,1.65;"..S("Pena").."]"
			.."dropdown[8.5,2.08;3,1;tipo_pena;"..penas_list_string..";]"
			.."label[11.4,1.65;"..S("Tempo").."]"
			.."dropdown[11.4,2.08;2,1;tempo_pena;"..tempos_penas_list_string..";]"
			.."button[8.5,2.9;5,1;add_pena;"..S("Aplicar Penalidade").."]"
		
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
				acessos[name].aviso_penalidades = S("Nenhum jogador informado")
				gestor.menu_principal(name)
				return 
			end
			
			-- Penalizar jogador
			gestor.penalizar(fields.jogador, fields.tipo_pena, fields.tempo_pena)
			acessos[name].aviso_penalidades = S("Penalidade aplicada em @1", fields.jogador)
			gestor.menu_principal(name)
		
		-- Remover pena
		elseif fields.rem_pena then
			-- Verificar nome informado
			if fields.jogador == "" then
				acessos[name].aviso_penalidades = S("Nenhum jogador informado")
				gestor.menu_principal(name)
				return 
			end
			
			for _,p in ipairs(penas) do
				gestor.remover_penalidade(fields.jogador, p)
			end
			acessos[name].aviso_penalidades = S("Todas penalidades removidas de @1", fields.jogador)
			gestor.menu_principal(name)
		end
		
	end,
})

-- Remover penalidade
gestor.remover_penalidade = function(name, pena)
	if pena == penas[2] then
		gestor.bd.remover("penalizados", "Banir_"..name)
		
	elseif pena == penas[1] then
	
		local privs = minetest.get_player_privs(name)
		privs.shout = true
		minetest.set_player_privs(name, privs)
		gestor.bd.remover("penalizados", "Silenciar_"..name)
	end
end

-- Penalizar jogador
gestor.penalizar = function(name, pena, tempo)
	
	-- Em caso de banimento ja expulsa do servidor
	if get_pena_st[pena] == "Banir" then
		minetest.kick_player(name, "Foste expulso do servidor")
	end
	
	-- Remove priv shout se for silenciar
	if get_pena_st[pena] == "Silenciar" then
		local privs = minetest.get_player_privs(name)
		privs.shout = nil
		minetest.set_player_privs(name, privs)
	end
	
	if tempo == tempos_penas[15] then
		-- Salva pena no banco de dados
		gestor.bd.salvar("penalizados", get_pena_st[pena].."_"..name, "sempre")
		return
	end
	
	-- Calcular data a ser adicionada para contagem
	local data_add = {}
	local t = string.split(get_tempo_st[tempo], " ")
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
	gestor.bd.salvar("penalizados", get_pena_st[pena].."_"..name, data_fim)
end

-- Impedir jogadores banidos de reconectar
minetest.register_on_prejoinplayer(function(name)
	
	-- Verificar se existe pena de banimento no banco de dados
	if gestor.bd.verif("penalizados", "Banir_"..name) ~= true then return end
	
	-- Verificar data
	local data_fim = gestor.bd.pegar("penalizados", "Banir_"..name)
	
	-- Caso seja banimento permanente
	if data_fim == "sempre" then
		return S("Banido permanentemente")
	
	-- Caso seja banimento temporario
	else
		local dif_dias, dif_horas, dif_minutos = gestor.comparar_data(data_fim[1], data_fim[2], data_fim[3], data_fim[4], data_fim[5])
		if dif_dias > 0 or dif_horas > 0 or dif_minutos > 0 then
			return S("Banido temporariamente por (d:h:m):").." "
				..tostring(dif_horas or 0)..":"..tostring(dif_minutos or 0)..":"..tostring(dif_dias or 0)
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
		minetest.chat_send_player(name, S("Foste silenciado permanentemente neste servidor"))
		return
	-- Caso seja banimento temporario
	else
		local dif_dias, dif_horas, dif_minutos = gestor.comparar_data(data_fim[1], data_fim[2], data_fim[3], data_fim[4], data_fim[5])
		if dif_dias > 0 or dif_horas > 0 or dif_minutos > 0 then
			return S("Foste silenciado temporariamente. Restam ainda @1d @2h e @3d para poderes voltar a falar normalmente", dif_dias, dif_horas, dif_minutos)
		else
			-- Fim da penalidade
			gestor.remover_penalidade(name, "Silenciar")
			return
		end
	end
	
end)

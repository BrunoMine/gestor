--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para sistema Anti Flood para o chat
  ]]

-- Variavel de controle
local antiflood = minetest.settings:get_bool("gestor_sistema_antflood", false) or false

-- Controle de acessos
local acessos = {}
minetest.register_on_joinplayer(function(player)
	acessos[player:get_player_name()] = 0
end)
minetest.register_on_leaveplayer(function(player)
	acessos[player:get_player_name()] = nil
end)

-- reduzir limitador de falas
local red_fala = function(name)
	if acessos[name] == nil then return end
	-- Verifica se ja está zerado
	if acessos[name] == 0 then return end
	
	-- Reduz 1
	acessos[name] = acessos[name] - 1
end

-- Impedir jogadores silenciados de falaram no chat e restaura o priv de fala se estiver acabado o periodo de penalidade
minetest.register_on_chat_message(function(name, message)
	
	if antiflood == false then return end
	
	if acessos[name] == nil then return end
	
	if acessos[name] >= 3 then 
		minetest.chat_send_player(name, "Proibido floddar o chat com muitas mensagens")
		return true
	else
		acessos[name] = acessos[name] + 1
		minetest.after(7.5, red_fala, name)
	end
end)



--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para desligamento do servidor
  ]]

-- Registrar aba 'desligar'
gestor.registrar_aba("desligar", {
	titulo = "Desligar",
	get_formspec = function(name)
		formspec = "label[6,2;Tem certeza que quer \ndesligar do servidor?]"
			.."button_exit[6,3;4,1;ok;Confirmar]"
		return formspec
	end,
	on_receive_fields = function(player, fields)
		if fields.ok then
			local name = player:get_player_name()
			minetest.chat_send_all("*** Servidor desligando em 3 segundos. (Por "..name..")")
			minetest.after(3, minetest.chat_send_all, "*** Servidor Desligado")
			minetest.after(3, minetest.request_shutdown)
		end
	end,
})

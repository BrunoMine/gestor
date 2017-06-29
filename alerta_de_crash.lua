--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Funcionalidades do alerta de crash
  ]]

gestor.alerta_de_crash = {}

-- Lista de admins
local lista_moderadores = {}

-- Coloca o nome de admin padrao se houver
if minetest.setting_get("name") then
	lista_moderadores[minetest.setting_get("name")] = true
end


-- Enviar email
gestor.alerta_de_crash.enviar_email = function()
	local servidor_smtp = minetest.setting_get("gestor_servidor_smtp")
	local login_smtp = minetest.setting_get("gestor_login_smtp")
	local senha_login_smtp = minetest.setting_get("gestor_senha_login_smtp")
	local email_destinatario = minetest.setting_get("gestor_email_destinatario")
	local titulo = minetest.setting_get("gestor_titulo_email")
	local texto = minetest.setting_get("gestor_texto_email")
	
	-- Verificar tem todos os dados
	if not servidor_smtp 
		or not login_smtp 
		or not senha_login_smtp 
		or not email_destinatario 
		or not titulo 
		or not texto
	then
		return false
	end
	
	-- Enviar comando
	local comando = "nohup sendemail -s \""..servidor_smtp.."\" -xu \""..login_smtp.."\" -xp \""..senha_login_smtp.."\" -f \""..login_smtp.."\" -t \""..email_destinatario.."\" -u \""..titulo.."\" -m \""..texto.."\" >> gestor_envios_de_alerta.out &"
	os.execute(comando)
	
	return true
end


-- Avisar por email quando o servidor desligar inesperadamente
minetest.register_on_shutdown(function()
	
	if minetest.setting_getbool("gestor_alerta_de_crash") then
		local inesperado = true
		
		-- Verifica se um admin está online (nesse caso nao precisa enviar alerta no email)
		for _,player in ipairs(minetest.get_connected_players()) do
			if lista_moderadores[player:get_player_name()] then
				inesperado = false
				break
			end
		end
	
		if inesperado then
			gestor.alerta_de_crash.enviar_email()
		end
        end
        
end)

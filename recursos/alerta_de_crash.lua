--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para alerta de crash do servidor
  ]]

-- Registrar aba 'diretrizes'
gestor.registrar_aba("alerta_de_crash", {
	titulo = "Alerta de Crash",
	get_formspec = function(name)
		
		-- Pegar dados
		local status_alerta_de_crash = minetest.setting_getbool("gestor_alerta_de_crash") or false
		local servidor_smtp = minetest.setting_get("gestor_servidor_smtp") or "-"
		local login_smtp = minetest.setting_get("gestor_login_smtp") or "-"
		local senha_login_smtp = minetest.setting_get("gestor_senha_login_smtp")
		local email_destinatario = minetest.setting_get("gestor_email_destinatario") or "-"
		local titulo = minetest.setting_get("gestor_titulo_email") or "-"
		local texto = minetest.setting_get("gestor_texto_email") or "-"
		
		local status_senha = "nenhuma"
		if senha_login_smtp then
			status_senha = "salva"
		end
		
		if status_alerta_de_crash == false then
			status_alerta_de_crash = "1"
		else
			status_alerta_de_crash = "2"
		end
		
		formspec = "label[3.5,1;Alerta de Crash]"
			
			-- Sistema Verificador AntiCrash
			.."label[3.5,2;Sistema Verificador AntiCrash]"
			.."button[3.5,2.6;3,1;salvar;Salvar Dados]"
			-- Sistema Notificador via Email
			.."label[3.5,5;Sistema Notificador via Email]"
			.."label[3.5,5.4;Estado]"
			
			.."dropdown[3.5,5.8;2,1;status_email;Inativo,Ativo;"..status_alerta_de_crash.."]"
			.."field[5.8,6;4.3,1;login_smtp;Login emissor;"..login_smtp.."]"
			.."pwdfield[10.1,6;3.3,1;senha;Senha ("..status_senha..")]"
			.."field[3.8,7.2;9.6,1;servidor_smtp;Servidor SMTP de envio (host:porta);"..servidor_smtp.."]"
			.."field[3.8,8.4;5,1;titulo;Titulo da mensagem de email enviada;"..titulo.."]"
			.."field[8.8,8.4;4.6,1;email_destinatario;Email do destinatario;"..email_destinatario.."]"
			.."field[3.8,9.6;9.6,1;texto;Texto;"..texto.."]"
			.."button[3.5,10;5,1;testar_email;Enviar mensagem de teste]"
			
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		if fields.salvar then
		
			-- Salvar todos os dados
			
			-- Status de alerta de email
			if fields.status_email == "Ativo" then
				minetest.setting_setbool("gestor_alerta_de_crash", true)
			else
				minetest.setting_setbool("gestor_alerta_de_crash", false)
			end
			
			-- Servidor SMTP
			if fields.servidor_smtp and fields.servidor_smtp ~= "-" then
				minetest.setting_set("gestor_servidor_smtp", fields.servidor_smtp)
			end
			
			-- Login SMTP
			if fields.login_smtp and fields.login_smtp ~= "-" then
				minetest.setting_set("gestor_login_smtp", fields.login_smtp)
			end
			
			-- Senha de Login SMTP
			if fields.senha and fields.senha ~= "" then
				minetest.setting_set("gestor_senha_login_smtp", fields.senha)
			end
			
			-- Email do Destinatario
			if fields.email_destinatario and fields.email_destinatario ~= "-" then
				minetest.setting_set("gestor_email_destinatario", fields.email_destinatario)
			end
			
			-- Titulo da mensagem de Email
			if fields.titulo and fields.titulo ~= "-" then
				minetest.setting_set("gestor_titulo_email", fields.titulo)
			end
			
			-- Texto da mensagem de Email
			if fields.texto and fields.texto ~= "-" then
				minetest.setting_set("gestor_texto_email", fields.texto)
			end
			
			minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
				default.gui_bg..
				default.gui_bg_img..
				"label[0,0;SUCESSO \nOs dados validos foram \nsalvos.]"
			)
			minetest.after(2, gestor.menu_principal, name)
			return
			
			
		elseif fields.testar_email then
		
			if gestor.alerta_de_crash.enviar_email() then
				minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;FEITO \nComando de envio feito.\nVeja o arquivo de relatorio\ngestor_envios_de_alerta.out]"
				)	
			else
				minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;FALHA \nFaltam dados para\nrealizar o comando de envio.\n]"
				)
			end
			minetest.after(2, gestor.menu_principal, name)
		end
	end,
})

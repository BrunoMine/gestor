--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Menu Principal (Painel do gestor)
  ]]

local escolha_local_avulso = {}

local escolha_vila = memor.online()

-- Caminho do mod
local modpath = minetest.get_modpath("gestor")

-- Desordenar tabela
local desordenar = function(tb)
	local ntb = {}
	for _,d in ipairs(tb) do
		ntb[d] = {}
	end
	return ntb
end

-- Lista-string configurada altomaticamente
gestor.lista_vilas = ""
local i = 1
while (gestor.vilas[i]~=nil) do
	gestor.lista_vilas = gestor.lista_vilas..gestor.vilas[i]
	if i < table.maxn(gestor.vilas) then gestor.lista_vilas = gestor.lista_vilas .. "," end
	i = i + 1
end

-- Abrir Menu principal
local aba = {} -- salva em que aba o jogador esta
gestor.menu_principal = function(name, inicio)
	if inicio == true then aba[name] = "inicio" end
	
	local formspec = "size[14,11]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;Gestor Administrativos do Servidor]"
		.."button[0,1;3,1;desligar;Desligar]" -- Botao 1
		.."button[0,2;3,1;lugares;Lugares]" -- Botao 2
		.."button[0,3;3,1;conf;Diretrizes]" -- Botao 3
		.."button[0,4;3,1;alerta_de_crash;Alerta de Crash]" -- Botao 4
		--.."button[0,5;3,1;;]" -- Botao 5
		--.."button[0,6;3,1;;]" -- Botao 6
		--.."button[0,7;3,1;;]" -- Botao 7
		--.."button[0,8;3,1;;]" -- Botao 8
		--.."button[0,9;3,1;;]" -- Botao 9

	--
	-- Gerando Abas
	--
	
	-- Lugares
	if aba[name] == "lugares" then
		local lugares = {}
		lugares["centro"] = desordenar(minetest.get_dir_list(minetest.get_worldpath().."/gestor/centro"))
		lugares["vilas"] = desordenar(minetest.get_dir_list(minetest.get_worldpath().."/gestor/lugares"))
		lugares["avulsos"] = desordenar(minetest.get_dir_list(minetest.get_worldpath().."/gestor/avulsos"))
		local status_lugares = {}

		-- Status e teleporte do Centro do Servidor
		if gestor.bd:verif("centro", "status") then 
			status_lugares["centro"] = "Ativo" 
			formspec = formspec.."button_exit[7,2.5;3,1;ir_centro;Ir para Centro]"
			formspec = formspec.."button[10,2.5;3,1;tp_centro;Redefinir pos. tp.]"
		else 
			status_lugares["centro"] = "Inativo" 
		end
		
		-- Preparar variaveis para Lugares avulsos
		local lista_avulsos = ""
		local desc_avulso = "Selecione um lugar \nna lista ao lado \n<<<<<<<<<<<<<\npara saber sobre"
			.."\nMaximizar a tela \najuda na leitura da \nlista e do texto"
		local n = 0
		for nome_avulso, v in pairs(lugares["avulsos"]) do
			if lista_avulsos ~= "" then lista_avulsos = lista_avulsos.."," end
			if v.status then lista_avulsos = lista_avulsos.."OK |" else lista_avulsos = lista_avulsos.."PEND. |" end
			lista_avulsos = lista_avulsos.." "..nome_avulso
			n = n + 1
			if tonumber(escolha_local_avulso[name]) == n then desc_avulso = v.texto end
		end
		if lista_avulsos == "" then lista_avulsos = "Nenhum" end
		formspec = formspec..
			"label[4,1;Lugares]"..
			-- Centro do Servidor
			"label[4,2;Centro do Servidor - Spawn ("..status_lugares["centro"]..")]"..
			"button[4,2.5;3,1;construir_centro;Constrir Aqui]"..
			-- Vilas
			"label[4,4;Vilas]"..
			"dropdown[4,4.5;4,1;vila;"..gestor.lista_vilas..";1]"..
			"button[8,4.4;2.5,1;construir_vila;Constrir Aqui]"..
			"button_exit[10.5,4.4;3.1,1;tp_vila;Definir spawn de vila]"..
			-- Lugares Avulsos
			"label[4,6;Lugares Avulsos]"..
			"textlist[4,6.5;5,4;avulsos;"..lista_avulsos.."]"..
			"textarea[9.4,6.48;4.5,4.73;desc_avulso;Sobre o lugar;"..desc_avulso.."]"
	
	-- Diretrizes
	elseif aba[name] == "diretrizes" then

		formspec = formspec
			.."label[4,1;Diretrizes]"
			.."label[4,2;Ponto de Spawn]"
			.."button_exit[4,2.4;3,1;definir_spawn;Definir Aqui]"
			.."button_exit[7,2.4;3,1;ir_spawn;Ir para Spawn]"
			.."field[4.3,4.1;3,1;slots;Limite de Jogadores;"..minetest.setting_get("max_users").."]"
			.."button_exit[7,3.8;3,1;definir_slots;Redefinir Limite]"
			
	-- Alerta de crash
	elseif aba[name] == "alerta_de_crash" then
		
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
		
		formspec = formspec
		
			.."label[4,1;Alerta de Crash]"
			
			-- Sistema Verificador AntiCrash
			.."label[4,2;Sistema Verificador AntiCrash]"
			.."button[4,2.6;3,1;salvar;Salvar Dados]"
			-- Sistema Notificador via Email
			.."label[4,5;Sistema Notificador via Email]"
			.."label[4,5.4;Estado]"
			
			.."dropdown[4,5.8;2,1;status_email;Inativo,Ativo;"..status_alerta_de_crash.."]"
			.."field[6.3,6;4.3,1;login_smtp;Login emissor;"..login_smtp.."]"
			.."pwdfield[10.6,6;3.3,1;senha;Senha ("..status_senha..")]"
			.."field[4.3,7.2;9.6,1;servidor_smtp;Servidor SMTP de envio (host:porta);"..servidor_smtp.."]"
			.."field[4.3,8.4;5,1;titulo;Titulo da mensagem de email enviada;"..titulo.."]"
			.."field[9.3,8.4;4.6,1;email_destinatario;Email do destinatario;"..email_destinatario.."]"
			.."field[4.3,9.6;9.6,1;texto;Texto;"..texto.."]"
			.."button[4,10;5,1;testar_email;Enviar mensagem de teste]"
			
	end

	-- Exibir tela
	minetest.show_formspec(name, "gestor:menu_principal", formspec)
end


-- Receptor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	
	-- Menu Principal
	if formname == "gestor:menu_principal" then
		local name = player:get_player_name()
		
		--
		-- Alternar aba selecionada
		--
		
		if fields.lugares then -- Lugares
			aba[name] = "lugares"
			gestor.menu_principal(name)
			return true
		elseif fields.conf then -- Diretrizes
			aba[name] = "diretrizes"
			gestor.menu_principal(name)
			return true
		elseif fields.alerta_de_crash then -- Alerta de Crash
			aba[name] = "alerta_de_crash"
			gestor.menu_principal(name)
			return true
		end
		
		
		-- Botao Desligar servidor
		if fields.desligar then
			minetest.show_formspec(name, "gestor:aviso_desligamento", "size[4,1.8]"..
				default.gui_bg..
				default.gui_bg_img..
				"label[0,0;Tem certeza que quer \ndesligar do servidor?]"..
				"button[0,1;2,1;cancelar;Cancelar]"..
				"button_exit[2,1;2,1;ok;Sim]"
			)
		end
		
		--
		-- Recebendo campos de Abas
		--
		
		-- Lugares
		if aba[name] == "lugares" then 
			if fields.construir_centro then
				minetest.show_formspec(name, "gestor:aviso_construir_centro", "size[4,1.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;Tem certeza que quer \nconstruir Centro do Servidor]"..
					"button[0,1;2,1;cancelar;Cancelar]"..
					"button_exit[2,1;2,1;ok;Sim]"
				)
			elseif fields.construir_vila then
				escolha_vila[name] = fields.vila
				minetest.show_formspec(name, "gestor:aviso_construir_vila", "size[4,4.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;Tem certeza que quer \nconstruir essa vila?]"..
					"label[0,1;"..core.colorize("#FF0000", "Fique na faixa de altura \n") .. core.colorize("#FF0000", "maxima dos picos em volta").."]"..
					"field[0.25,3.2;4,1;nome_vila;;Nome da Vila]"..
					"label[0,2;Arquivo de midia: \n"..escolha_vila[name].."]"..
					"button[0,4;2,1;cancelar;Cancelar]"..
					"button_exit[2,4;2,1;ok;Sim]"
				)
			elseif fields.tp_vila then
				if fields.vila then
					if gestor.bd:verif("vilas", fields.vila) then
						local dados_vila = gestor.bd:pegar("vilas", fields.vila)
						gestor.bd:salvar("vilas", fields.vila, {nome=dados_vila.nome, pos=player:getpos()})
						minetest.chat_send_player(name, "Posicao de teleporte da vila "..fields.vila.." redefinido para esse local.")
					else
						minetest.chat_send_player(name, "Vila "..fields.vila.." ainda nao existe.")
					end
				else
					minetest.log("error", "Nome da vila parece inconsistente ("..dump(fields.vila)..").")
				end
			elseif fields.ir_centro then
				player:setpos(gestor.bd:pegar("centro", "pos"))
				minetest.chat_send_player(name, "Teleportado para o Centro do Servidor")
			elseif fields.tp_centro then
				gestor.bd:salvar("centro", "pos", player:getpos())
				minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;AVISO\nPosicao de teleport \ndo Centro do Servidor \nredefinido para aqui]"
				)
				minetest.after(2, gestor.menu_principal, name)
			elseif fields.avulsos then
				local n = string.split(fields.avulsos, ":")
				escolha_local_avulso[name] = n[2]
				gestor.menu_principal(name)
			end
		
		-- Diretrizes
		elseif aba[name] == "diretrizes" then 
			if fields.definir_spawn then
				local pos = player:getpos()
				minetest.setting_set("static_spawnpoint", pos.x.." "..pos.y.." "..pos.z)
				minetest.chat_send_player(name, "Spawn redefinido aqui.")
			elseif fields.ir_spawn then
				local pos = minetest.setting_get_pos("static_spawnpoint") or {x=0,y=0,z=0}
				player:setpos(pos)
				minetest.chat_send_player(name, "Teleportado para ponto de Spawn.")
			elseif fields.definir_slots then
				if tonumber(fields.slots) then
					minetest.setting_set("max_users", fields.slots)
					minetest.chat_send_player(name, "Limite de jogadores redefinido para "..fields.slots..".")
				else
					minetest.chat_send_player(name, "Digite um numero para o limite de jogadores")
				end
			end
		
		-- Alerta de Crash
		elseif aba[name] == "alerta_de_crash" then 
			
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
		end
	end

	--
	-- Janelas de aviso e outros
	--
	
	-- Desligamento
	if formname == "gestor:aviso_desligamento" then
		local name = player:get_player_name()		
		
		if fields.ok then
			minetest.chat_send_all("*** Servidor desligando em 3 segundos. (Por "..name..")")
			minetest.after(3, minetest.chat_send_all, "*** Servidor Desligado")
			minetest.after(3, minetest.request_shutdown)
		end
		if fields.cancelar then
			gestor.menu_principal(name)
		end
	end
	
	-- Construir Centro do Servidor
	if formname == "gestor:aviso_construir_centro" then
		local name = player:get_player_name()		
		
		if fields.ok then
			-- adquirindo dados
			local pos = player:getpos()
			local dados_estrutura = gestor.estruturador.get_meta("centro")
			if not dados_estrutura then return minetest.chat_send_player(name, "Estrutura nao encontrada") end
			local pos_c = {x=pos.x-(dados_estrutura.largura/2), y=pos.y-8, z=pos.z-(dados_estrutura.largura/2)}
			local n_spawn = {x=pos.x, y=pos.y+2, z=pos.z}
			-- Construir estrutura
			if gestor.estruturador.carregar(pos_c, "centro") == false then return minetest.chat_send_player(name, "Estrutura nao encontrada") end
			-- Proteger area da estrutura
			local resp = gestor.proteger_area(
				name, -- Quem registra
				name, -- Quem vai ser o dono
				"Centro", -- Nome(etiqueta) da area
				{x=pos.x-(dados_estrutura.largura/2)-100, y=2000, z=pos.z-(dados_estrutura.largura/2)-100}, -- um dos cantos opostos
				{x=pos.x+(dados_estrutura.largura/2)+100, y=pos.y-60, z=pos.z+(dados_estrutura.largura/2)+100} -- outro dos cantos opostos
			)
			if resp ~= true then minetest.chat_send_player(name, "Falha ao proteger: "..resp) end
			-- Salvar dados
			minetest.setting_set("static_spawnpoint", pos.x.." "..(pos.y+10).." "..pos.z)
			gestor.bd:salvar("centro", "pos", n_spawn)
			gestor.bd:salvar("centro", "status", true)
			-- Finalizando
			player:moveto(n_spawn)
			minetest.chat_send_player(name, "Centro construido e parcialmente definido. Configure a loja principal e o banco apenas. Recomendavel redefinir o spawn.")
			
		end
		if fields.cancelar then
			gestor.menu_principal(name)
		end
	end
	
	-- Construir vila
	if formname == "gestor:aviso_construir_vila" then
		local name = player:get_player_name()		
		
		if fields.ok then
			
			local pos = player:getpos()
			local vila = escolha_vila[name]
			
			-- Montar vila
			local r = gestor.montar_vila(pos, vila)
			if r ~= true then
				return minetest.chat_send_player(name, r)
			end
			
			
			local dados_estrutura = gestor.estruturador.get_meta(vila)
			local n_spawn = pos
			
			-- Proteger area da estrutura
			local resp = gestor.proteger_area(
				name, -- Quem registra
				name, -- Quem vai ser o dono
				fields.vila, -- Nome(etiqueta) da area
				{x=pos.x-(dados_estrutura.largura/2)-10, y=2000, z=pos.z-(dados_estrutura.largura/2)-50}, -- um dos cantos opostos
				{x=pos.x+(dados_estrutura.largura/2)+10, y=pos.y-60, z=pos.z+(dados_estrutura.largura/2)+50} -- outro dos cantos opostos
			)
			if resp ~= true then minetest.chat_send_player(name, "Falha ao proteger: "..resp) end
			
			-- Salvar dados
			gestor.bd:salvar("vilas", vila, {nome=fields.nome_vila,pos=n_spawn})
			
			-- Finalizando
			player:moveto(n_spawn)
			minetest.chat_send_player(name, "*** Vila construida quase pronta. Ajuste as entradas da vila e o ponto de TP(spawn) perto da bilheteria.")
		end
		if fields.cancelar then
			gestor.menu_principal(name)
		end
	end
	
	
end)


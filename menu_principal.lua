--
-- Mod gestor
--
-- Menu Principal
--

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
		.."button[0,4;3,1;anticrash;AntiCrash]" -- Botao 4
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
			
	-- AntiCrash
	elseif aba[name] == "anticrash" then
		
		local status_senha = ""
		if gestor.bd:pegar("anticrash", "from_senha") then status_senha = " (Salva)" end
		
		local status_email = "1"
		if gestor.bd:pegar("anticrash", "status_email") == "true"  then status_email = "2" end
		
		local status_backup = "1"
		if gestor.bd:pegar("anticrash", "status_backup") == "true"  then status_backup = "2" end
		
		--[[
		local bin_paths = io.popen"locate bin/minetest":read"*all"
		bin_paths = string.gsub(bin_paths, "bin/minetest", "bin")
		bin_paths = string.gsub(bin_paths, "\n", ",")
		local path_selecionado = gestor.bd:pegar("anticrash", "bin_path") or "-"
		]]
		local comando_selecionado = 1
		local co = gestor.bd:pegar("anticrash", "comando_abertura")
		for n, c in ipairs(string.split("minetest --server,minetestserver", ",")) do
			if c == co then
				comando_selecionado = n
				break
			end
		end
		
		formspec = formspec
			.."label[4,1;AntiCrash]"
			-- Sistema Verificador AntiCrash
			.."label[4,2;Sistema Verificador AntiCrash]"
			.."button[4,2.6;3,1;salvar;Salvar Dados]"
			.."field[7.4,3;3.2,1;quedas;Lim. quedas seguidas;"..gestor.bd:pegar("anticrash", "quedas").."]"
			.."field[10.6,3;3.3,1;interval;Intervalo de verif. (s);"..gestor.bd:pegar("anticrash", "interval").."]"
			.."textarea[4.3,3.8;9.6,1.5;comando;Comando de abertura do servidor (digite no terminal UNIX);$ cd \""..string.gsub(modpath, " ", " ").."\"\n$ ./../mod/gestor/./gestor-anticrash-minetest.sh]"
			-- Sistema Notificador via Email
			.."label[4,5;Sistema Notificador via Email]"
			.."label[4,5.4;Estado]"
			.."dropdown[4,5.8;2,1;status_email;Inativo,Ativo;"..status_email.."]"
			.."field[6.3,6;4.3,1;from_email;Email emissor;"..gestor.bd:pegar("anticrash", "from_email").."]"
			.."pwdfield[10.6,6;3.3,1;from_senha;Senha"..status_senha.."]"
			.."field[4.3,7;4,1;from_login;Login do SMTP;"..gestor.bd:pegar("anticrash", "from_login").."]"
			.."field[8.3,7;4,1;from_smtp;SMTP do email emissor;"..gestor.bd:pegar("anticrash", "from_smtp").."]"
			.."field[12.3,7;1.6,1;from_smtp_port;Porta;"..gestor.bd:pegar("anticrash", "from_smtp_port").."]"
			.."field[4.3,8;5,1;from_subject;Titulo da mensagem de email enviada;"..gestor.bd:pegar("anticrash", "from_subject").."]"
			.."field[9.3,8;4.6,1;to_email;Email do destinatario;"..gestor.bd:pegar("anticrash", "to_email").."]"
			-- Sistema de Backup
			.."label[4,8.8;Sistema de Backup]"
			.."dropdown[4,9.3;3,1;status_backup;Inativo,Ativo;"..status_backup.."]"
			.."button[10.6,8.6;3,1;testar_email;Enviar email teste]" -- Testar email
			
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
		elseif fields.anticrash then -- AntiCrash
			aba[name] = "anticrash"
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
				minetest.show_formspec(name, "gestor:aviso_construir_vila", "size[4,3.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;Tem certeza que quer \nconstruir essa vila?]"..
					"field[0.25,1.2;4,1;nome_vila;;Nome da Vila]"..
					"label[0,2;Arquivo de midia: \n"..escolha_vila[name].."]"..
					"button[0,3;2,1;cancelar;Cancelar]"..
					"button_exit[2,3;2,1;ok;Sim]"
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
		
		-- Anticrash
		elseif aba[name] == "anticrash" then 
			
			if fields.salvar then
				
				-- Salvar dados gerais
				if fields.from_email == "" then fields.from_email = "-" end
				if fields.from_login == "" then fields.from_login = "-" end
				if fields.from_smtp == "" then fields.from_smtp = "-" end
				if fields.from_smtp_port == "" then fields.from_smtp_port = "-" end
				if fields.from_subject == "" then fields.from_subject = "-" end
				if fields.to_email == "" then fields.to_email = "-" end
				if fields.quedas == "" or not tonumber(fields.quedas) then fields.quedas = "5" end
				if fields.interval == "" or not tonumber(fields.interval) then fields.interval = "300" end
				gestor.bd:salvar("anticrash", "from_email", fields.from_email)
				gestor.bd:salvar("anticrash", "from_login", fields.from_login)
				gestor.bd:salvar("anticrash", "from_smtp", fields.from_smtp)
				gestor.bd:salvar("anticrash", "from_smtp_port", fields.from_smtp_port)
				gestor.bd:salvar("anticrash", "from_subject", fields.from_subject)
				gestor.bd:salvar("anticrash", "to_email", fields.to_email)
				gestor.bd:salvar("anticrash", "quedas", fields.quedas)
				gestor.bd:salvar("anticrash", "interval", fields.interval)
				if fields.from_senha ~= "" then
					gestor.bd:salvar("anticrash", "from_senha", fields.from_senha)
				end
				-- Salva todos os dados para o shell
				gestor.anticrash.salvar_dados()
				
				-- Verificar sistema de email
				if fields.status_email == "Ativo" then
					-- Verificando dados
					if fields.from_email == "-"
						or fields.from_smtp == "-"
						or fields.from_smtp_port == "-"
						or fields.from_subject == "-"
						or fields.to_email == "-"
						or gestor.bd:verif("anticrash", "from_senha") ~= true
					then
						minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
							default.gui_bg..
							default.gui_bg_img..
							"label[0,0;AVISO \nFaltam dados no sistema \nde emails]"
						)
						minetest.after(2, gestor.menu_principal, name)
						gestor.bd:salvar("anticrash", "status_email", "false")
						return
					end
					-- Verificando se sendemail esta instalado
					local verif_sendemail = os.execute("sendemail --help")
					if verif_sendemail ~= 0 and verif_sendemail ~= 256 then
						minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
							default.gui_bg..
							default.gui_bg_img..
							"label[0,0;AVISO \nFalta o software sendEmail \nno computador para usar \no Sistema de Email]"
						)
						minetest.after(3, gestor.menu_principal, name)
						gestor.bd:salvar("anticrash", "status_email", "false")
						return
					end 
						
					gestor.bd:salvar("anticrash", "status_email", "true")
				else
					gestor.bd:salvar("anticrash", "status_email", "false")
				end
				
				-- Verificar sistema de backup
				if fields.status_backup == "Ativo" then
					-- Verificando se compactador TAR esta instalado
					local verif_tar = os.execute("tar --help")
					if verif_tar ~= 0 and verif_tar ~= 256 then
						minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
							default.gui_bg..
							default.gui_bg_img..
							"label[0,0;AVISO \nFalta o compactador TAR\nno computador para usar \no Sistema de Backups]"
						)
						minetest.after(3, gestor.menu_principal, name)
						gestor.bd:salvar("anticrash", "status_backup", "false")
						return
					end 
						
					gestor.bd:salvar("anticrash", "status_backup", "true")
				else
					gestor.bd:salvar("anticrash", "status_backup", "false")
				end
				
				minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;DADOS SALVOS \nTodos os dados foram \nsalvos com sucesso]"
				)
				
				minetest.after(2, gestor.menu_principal, name)
				return
			
			elseif fields.testar_email then
				if gestor.bd:pegar("anticrash", "status_email") == "false" then
					minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
						default.gui_bg..
						default.gui_bg_img..
						"label[0,0;AVISO \nO sistema de emails \nprecisa estar ativo para \nenviar email teste]"
					)
					minetest.after(2, gestor.menu_principal, name)
					return
				end
				local comando = "sendemail "
					.."-s \""..gestor.bd:pegar("anticrash", "from_smtp")..":"..gestor.bd:pegar("anticrash", "from_smtp_port").."\" "
					.."-xu \""..gestor.bd:pegar("anticrash", "from_login").."\" "
					.."-xp \""..gestor.bd:pegar("anticrash", "from_senha").."\" "
					.."-f \""..gestor.bd:pegar("anticrash", "from_email").."\" "
					.."-t \""..gestor.bd:pegar("anticrash", "to_email").."\" "
					.."-u \"Gestor - Email teste\" "
					.."-m \"Essa mensagem foi um teste enviado pelo mod gestor\" "
					.."-o message-charset=UTF-8 &"
				minetest.show_formspec(name, "gestor:aviso", "size[4,1.8]"..
					default.gui_bg..
					default.gui_bg_img..
					"label[0,0;AVISO \nEmail de teste enviado \nverifique a caixa de \nentrada do destinatario]"
				)
				os.execute(comando)
				minetest.after(2, gestor.menu_principal, name)
				return
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
			local dados_estrutura = gestor.diretrizes.estruturas["centro"]
			if not dados_estrutura then return minetest.chat_send_player(name, "Estrutura nao encontrada") end
			local pos_c = {x=pos.x-(dados_estrutura[1]/2), y=pos.y-2, z=pos.z-(dados_estrutura[1]/2)}
			local n_spawn = {x=pos.x, y=pos.y+2, z=pos.z}
			-- Construir estrutura
			if gestor.estruturador.carregar(pos_c, "centro") == false then return minetest.chat_send_player(name, "Estrutura nao encontrada") end
			-- Proteger area da estrutura
			local resp = gestor.proteger_area(
				name, -- Quem registra
				name, -- Quem vai ser o dono
				"Centro", -- Nome(etiqueta) da area
				{x=pos.x-(dados_estrutura[1]/2)-10, y=2000, z=pos.z-(dados_estrutura[1]/2)-10}, -- um dos cantos opostos
				{x=pos.x+(dados_estrutura[1]/2)+10, y=pos.y-60, z=pos.z+(dados_estrutura[1]/2)+10} -- outro dos cantos opostos
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
			-- Verificando se ja existe essa vila
			local vila = escolha_vila[name]
			if gestor.bd:verif("vilas", vila) then return minetest.chat_send_player(name, "Vila ja existente") end
			-- Adquirindo dados
			local pos = player:getpos()
			local dados_estrutura = gestor.diretrizes.estruturas[vila]
			if not dados_estrutura then return minetest.chat_send_player(name, "Estrutura nao encontrada") end
			local pos_c = {x=pos.x-(dados_estrutura[1]/2), y=pos.y-2, z=pos.z-(dados_estrutura[1]/2)}
			local n_spawn = {x=pos.x, y=pos.y+10, z=pos.z}
			-- Construir estrutura
			if gestor.estruturador.carregar(pos_c, vila) == false then return minetest.chat_send_player(name, "Estrutura nao encontrada") end
			-- Proteger area da estrutura
			local resp = gestor.proteger_area(
				name, -- Quem registra
				name, -- Quem vai ser o dono
				fields.vila, -- Nome(etiqueta) da area
				{x=pos.x-(dados_estrutura[1]/2)-10, y=2000, z=pos.z-(dados_estrutura[1]/2)-10}, -- um dos cantos opostos
				{x=pos.x+(dados_estrutura[1]/2)+10, y=pos.y-60, z=pos.z+(dados_estrutura[1]/2)+10} -- outro dos cantos opostos
			)
			if resp ~= true then minetest.chat_send_player(name, "Falha ao proteger: "..resp) end
			-- Salvar dados
			gestor.bd:salvar("vilas", vila, {nome=fields.nome_vila,pos=n_spawn})
			-- Finalizando
			player:moveto(n_spawn)
			minetest.chat_send_player(name, "*** Vila construida quase pronta. Ajuste as entradas da vila e o ponto de TP(spawn) perto da bilheteria. Configure lojas e bancos existentes.")
		end
		if fields.cancelar then
			gestor.menu_principal(name)
		end
	end
	
	
end)


--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para edição de diretrizes do servidor
  ]]

-- Lista de configurações alteraveis
local lista_configs = {
	-- Nome do servidor
	{
		name = "Nome do Servidor",
		format = "string",
		desc = "Esse nome vai ser exibido na lista de servidores publicos",
		get_value = function()
			return minetest.settings:get("server_name")
		end,
		set_value = function(value)
			minetest.settings:set("server_name", value)
		end,
	},
	-- Descritivo do servidor
	{
		name = "Descritivo do Servidor",
		format = "string",
		desc = "Esse texto descritivo do servidor vai ser exibido na lista de servidores publicos",
		get_value = function()
			return minetest.settings:get("server_description")
		end,
		set_value = function(value)
			minetest.settings:set("server_description", value)
		end,
	},
	-- Website do servidor
	{
		name = "Website do Servidor",
		format = "string",
		desc = "Precisar ser o URL do website do servidor",
		get_value = function()
			return minetest.settings:get("server_url")
		end,
		set_value = function(value)
			minetest.settings:set("server_url", value)
		end,
	},
	-- Endereço do servidor
	{
		name = "Endereço do Servidor",
		format = "string",
		desc = "Endereço do servidor",
		get_value = function()
			return minetest.settings:get("server_address")
		end,
		set_value = function(value)
			minetest.settings:set("server_address", value)
		end,
	},
	-- Porta do servidor
	{
		name = "Porta UDP do Servidor",
		format = "int",
		desc = "Porta UDP do onde o servidor de Minetest vai operar na hospedagem",
		get_value = function()
			return minetest.settings:get("port")
		end,
		set_value = function(value)
			minetest.settings:set("port", value)
		end,
	},
	-- Anunciar Servidor
	{
		name = "Anunciar Servidor",
		format = "bool",
		desc = "Anunciar Servidor na lista de servidores",
		checkbox_name = "Anunciar Servidor",
		get_value = function()
			return minetest.settings:get("server_announce") or "true"
		end,
		set_value = function(value)
			minetest.settings:set("server_announce", value)
		end,
	},
	-- Spawn Estatico
	{
		name = "Spawn Estatico",
		format = "string",
		desc = "Coordenada do spawn estatico do servidor onde os jogadores vao spawnar ou respawnar apos morrer"
			.."\nExemplo:"
			.."\n1500 45 -555",
		get_value = function()
			return minetest.settings:get("static_spawnpoint") or ""
		end,
		set_value = function(value)
			minetest.settings:set("static_spawnpoint", value)
		end,
	},
	-- Senha do Servidor
	{
		name = "Senha do Servidor",
		format = "string",
		desc = "Senha obrigatoria para novos jogadores",
		get_value = function()
			return minetest.settings:get("default_password")
		end,
		set_value = function(value)
			minetest.settings:set("default_password", value)
		end,
	},
	-- Vagas/Slots
	{
		name = "Vagas",
		format = "int",
		desc = "Vagas para jogadores online"
			.."\nJogadores com o privilegio server possuem vaga reservada",
		get_value = function()
			return minetest.settings:get("max_users")
		end,
		set_value = function(value)
			minetest.settings:set("max_users", value)
		end,
	},
	-- PvP
	{
		name = "PvP",
		format = "bool",
		desc = "Permitir que jogadores ataquem diretamente outros jogadores",
		checkbox_name = "Ativar PvP",
		get_value = function()
			return minetest.settings:get("enable_pvp") or "true"
		end,
		set_value = function(value)
			minetest.settings:set("enable_pvp", value)
		end,
	},
	-- Dano
	{
		name = "Dano",
		format = "bool",
		desc = "Permitir que jogadores levem dano",
		checkbox_name = "Ativar Dano",
		get_value = function()
			return minetest.settings:get("enable_damage") or "true"
		end,
		set_value = function(value)
			minetest.settings:set("enable_damage", value)
		end,
	},
	-- Modo Criativo
	{
		name = "Modo Criativo",
		format = "bool",
		desc = "Permitir que jogar no modo criativo incluindo inventario criativo e itens ilimitados",
		checkbox_name = "Ativar Modo Criativo",
		get_value = function()
			return minetest.settings:get("creative_mode") or "true"
		end,
		set_value = function(value)
			minetest.settings:set("creative_mode", value)
		end,
	},
	-- Distancia para ver Jogadores
	{
		name = "Distancia para ver Jogadores",
		format = "int",
		desc = "Distancia minima para visualizar outros jogadores no mapa"
			.."\nDefina 0 para distancia ilimitada",
		get_value = function()
			return minetest.settings:get("player_transfer_distance")
		end,
		set_value = function(value)
			minetest.settings:set("player_transfer_distance", value)
		end,
	},
	-- Permanencia de Itens Dropados
	{
		name = "Permanencia de Itens Dropados",
		format = "int",
		desc = "Tempo em segundos que um item fica dropado ate ser removido automaticamente pelo servidor",
		get_value = function()
			return minetest.settings:get("item_entity_ttl") or 900
		end,
		set_value = function(value)
			minetest.settings:set("item_entity_ttl", value)
		end,
	},
	-- Mostrar status ao conectar
	{
		name = "Mostrar status ao conectar",
		format = "bool",
		desc = "Mostrar status do servidor ao conectar",
		checkbox_name = "Mostrar Status",
		get_value = function()
			return minetest.settings:get("show_statusline_on_connect") or "true"
		end,
		set_value = function(value)
			minetest.settings:set("show_statusline_on_connect", value)
		end,
	},
	-- Tempo do Ciclo dia/noite
	{
		name = "Tempo do Ciclo dia/noite",
		format = "int",
		desc = "Tempo do Ciclo dia/noite"
			.."\nEquivale a um multiplicador de velocidade relacionado ao tempo do ciclo dia/noite real"
			.."\nExemplos:"
			.."\n72 = 20 minutos"
			.."\n360 = 4 minutos"
			.."\n1 = 24 horas (equivalendo a um dia real)",
		get_value = function()
			return minetest.settings:get("time_speed") or 72
		end,
		set_value = function(value)
			minetest.settings:set("time_speed", value)
		end,
	},
	-- Limite do Mundo
	{
		name = "Limite do Mundo",
		format = "int",
		desc = "Distancia do centro ate a borda do mundo",
		get_value = function()
			return minetest.settings:get("mapgen_limit") or 31000
		end,
		set_value = function(value)
			minetest.settings:set("mapgen_limit", value)
		end,
	},
	-- Auto Salvamento
	{
		name = "Auto Salvamento",
		format = "float",
		desc = "Tempo em segundos entre cada auto salvamento do mundo do servidor",
		get_value = function()
			return minetest.settings:get("server_map_save_interval") or 72
		end,
		set_value = function(value)
			minetest.settings:set("server_map_save_interval", value)
		end,
	},
	-- Senha Obrigatoria
	{
		name = "Senha Obrigatoria",
		format = "bool",
		desc = "Impede que jogadores novos se conectem ao servidor sem usar senha",
		checkbox_name = "Senha Obrigatoria",
		get_value = function()
			return minetest.settings:get("disallow_empty_password") or "false"
		end,
		set_value = function(value)
			minetest.settings:set("disallow_empty_password", value)
		end,
	},
	-- Privilegios Automaticos
	{
		name = "Privilegios Automaticos",
		format = "string",
		desc = "Privilegios dados automaticamente quando um novo jogador se conecta ao servidor"
			.."\nSeparados por virgulas",
		get_value = function()
			return minetest.settings:get("default_privs") or "interact, shout"
		end,
		set_value = function(value)
			minetest.settings:set("default_privs", value)
		end,
	},
	-- Privilegios Basicos
	{
		name = "Privilegios Basicos",
		format = "string",
		desc = "Privilegios dados para jogadores que possuem o privilegio basic_privs"
			.."\nSeparados por virgulas",
		get_value = function()
			return minetest.settings:get("basic_privs") or "interact, shout"
		end,
		set_value = function(value)
			minetest.settings:set("basic_privs", value)
		end,
	},
	-- AntiCheat
	{
		name = "AntiCheat",
		format = "bool",
		desc = "Esse AntiCheat faz parte dos algoritimos basicos do Minetest para verificar a atividade dos jogadores",
		checkbox_name = "Anticheat",
		get_value = function()
			local v = minetest.settings:get("disable_anticheat") or "false"
			-- Inverte ao exibir
			if v == "false" then
				return "true"
			else
				return "false"
			end
		end,
		set_value = function(value)
			-- Desinverter por exibir invertido
			if value == "false" then
				return minetest.settings:set("disable_anticheat", "true")
			else
				return minetest.settings:set("disable_anticheat", "false")
			end
			
		end,
	},
	-- RollBack
	{
		name = "RollBack",
		format = "bool",
		desc = "Sistema que armazena eventos e atividades dos jogadores afim de reconstituir atividades",
		checkbox_name = "RollBack",
		get_value = function()
			return minetest.settings:get("enable_rollback_recording") or "false"
		end,
		set_value = function(value)
			minetest.settings:set("enable_rollback_recording", value)
		end,
	},
	-- Mensagem de bem vindo
	{
		name = "Mensagem de Bem Vindo",
		format = "string",
		desc = "Mensagem apresentada ao jogador quando conectar ao servidor",
		get_value = function()
			return minetest.settings:get("motd")
		end,
		set_value = function(value)
			minetest.settings:set("motd", value)
		end,
	},
	-- Mensagem de crash do servidor
	{
		name = "Mensagem de Crash",
		format = "string",
		desc = "Mensagem exibida aos jogadores que estiverem online quando o servidor parar de funcionar inesperadamente (por erros do jogo)",
		get_value = function()
			return minetest.settings:get("kick_msg_crash")
		end,
		set_value = function(value)
			minetest.settings:set("kick_msg_crash", value)
		end,
	},
}

-- Lista de itens do menu do shop em formato de string
local string_menu_configs = ""
for _,d in pairs(lista_configs) do
	if string_menu_configs ~= "" then string_menu_configs = string_menu_configs .. "," end
	string_menu_configs = string_menu_configs .. d.name
end

-- Controle de acessos
local acessos = {}
minetest.register_on_joinplayer(function(player)
	acessos[player:get_player_name()] = {}
end)
minetest.register_on_leaveplayer(function(player)
	acessos[player:get_player_name()] = nil
end)


-- Registrar aba 'diretrizes'
gestor.registrar_aba("conf", {
	titulo = "Diretrizes",
	get_formspec = function(name)
		
		local formspec = "label[3.5,1;Diretrizes]"
			.."textlist[9,1;4.5,9.8;menu;"..string_menu_configs.."]"
		
		-- Construir formulario de acordo com item escolhido
		if acessos[name].escolha then
			local escolha = lista_configs[tonumber(acessos[name].escolha)]
			
			-- Formspec do item escolhido
			local form = ""
			
			-- Nome
			form = form .. "label[3.5,1.5;"..escolha.name.."]"
			
			-- Campo para preenchimento numero ou texto simples
			if escolha.format == "int" or escolha.format == "float" or escolha.format == "string" then
				form = form ..  "field[3.8,2.3;5,1;config_label_1;;"..escolha.get_value().."]"
				
				-- Botao para definir configuração
				form = form ..  "button[3.5,2.8;5,1;definir;Definir]"
				
				-- Texto de aviso
				if acessos[name].aviso then
					form = form .. "label[3.5,3.7;"..acessos[name].aviso.."]"
					acessos[name].aviso = nil
				end
				
				-- Descritivo
				form = form .. "textarea[3.8,4.3;5,7.7;;Descritivo:\n"..escolha.desc..";]"
			end
			
			-- Checkbox para preenchimento
			if escolha.format == "bool" then
				
				form = form ..  "checkbox[3.5,1.8;definir;"..escolha.checkbox_name..";"..tostring(escolha.get_value()).."]"
				
				-- Texto de aviso
				if acessos[name].aviso then
					form = form .. "label[3.5,2.6;"..acessos[name].aviso.."]"
					acessos[name].aviso = nil
				end
				
				-- Descritivo
				form = form .. "textarea[3.8,3.3;5,8.7;;Descritivo:\n"..escolha.desc..";]"
			end
			
			-- Insere no formspec
			formspec = formspec .. form
		else
			
			-- Nenhuma diretriz escolhida
			formspec = formspec .. "textarea[3.8,1.5;5,8.7;;Escolha uma diretriz para editar\n\nTodas as diretrizes serao repassadas ao arquivo minetest.config quando o minetest for encerrado, no entanto algumas modificações ja causam efeito imediato\n\nCuidado ao editar algumas diretrizes pois podem causar instabilidade no servidor;]"
		
		end
		
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		-- Salva os campos editados para reexibir
		acessos[name].config_label_1 = fields.config_label_1
		
		-- Escolher um item
		if fields.menu then
			local n = string.split(fields.menu, ":")
			acessos[name].escolha = tonumber(n[2]) or 1
			gestor.menu_principal(name)
		
		-- Definir valor
		elseif fields.definir then
			local escolha = lista_configs[tonumber(acessos[name].escolha)]
			
			-- Valor a ser salvo
			local value = fields.config_label_1
			
			-- Verificar valor
			-- Formato de numero
			if escolha.format == "int" or escolha.format == "float" then
				if tonumber(value) == nil then
					acessos[name].aviso = "Precisar ser numero"
					gestor.menu_principal(name)
					return
				else
					value = tonumber(fields.config_label_1)
					
					-- Arredonda para baixo caso precise ser inteiro
					if escolha.format == "int" then 
						value = math.ceil(value)
					end
				end
			
			elseif escolha.format == "bool" then
				value = fields.definir
				
			-- Outros formatos
			else
				value = fields.config_label_1
			end
			
			-- Atualiza campo exibido no painel
			acessos[name].config_label_1 = value
			
			-- Verificador personalizado
			if escolha.check_value then
				local check = escolha.check_value()
				if check ~= true then
					acessos[name].aviso = check
					gestor.menu_principal(name)
					return
				end
			end
			
			-- Texto de aviso
			acessos[name].aviso = "Definido"
			if value == "true" then
				acessos[name].aviso = "Ativado"
			elseif value == "false" then
				acessos[name].aviso = "Desativado"
			end
			
			-- Configurar valor
			escolha.set_value(value)
			minetest.settings:write()
			gestor.menu_principal(name)
		end
	end,
})

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
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("server_name")
		end,
		set_value = function(value)
			minetest.setting_set("server_name", value)
		end,
	},
	-- Descritivo do servidor
	{
		name = "Descritivo do Servidor",
		format = "string",
		desc = "Esse texto descritivo do servidor vai ser exibido na lista de servidores publicos",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("server_description")
		end,
		set_value = function(value)
			minetest.setting_set("server_description", value)
		end,
	},
	-- Website do servidor
	{
		name = "Website do Servidor",
		format = "string",
		desc = "Precisar ser o URL do website do servidor",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("server_url")
		end,
		set_value = function(value)
			minetest.setting_set("server_url", value)
		end,
	},
	-- Endereço do servidor
	{
		name = "Endereço do Servidor",
		format = "string",
		desc = "Endereço do servidor",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("server_address")
		end,
		set_value = function(value)
			minetest.setting_set("server_address", value)
		end,
	},
	-- Porta do servidor
	{
		name = "Porta do Servidor",
		format = "int",
		desc = "Porta do servidor",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("port")
		end,
		set_value = function(value)
			minetest.setting_set("port", value)
		end,
	},
	-- Vagas/Slots
	{
		name = "Vagas",
		format = "int",
		desc = "Vagas para jogadores online"
			.."\nJogadores com o privilegio 'server' possuem vaga reservada",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("max_users")
		end,
		set_value = function(value)
			minetest.setting_set("max_users", value)
		end,
	},
	-- PvP
	{
		name = "PvP",
		format = "bool",
		desc = "Permitir que jogadores ataquem diretamente outros jogadores",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("enable_pvp")
		end,
		set_value = function(value)
			minetest.setting_set("enable_pvp", value)
		end,
	},
	-- Mensagem de bem vindo
	{
		name = "Mensagem de Bem Vindo",
		format = "string",
		desc = "Mensagem apresentada ao jogador quando conectar ao servidor",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("motd")
		end,
		set_value = function(value)
			minetest.setting_set("motd", value)
		end,
	},
	-- Mensagem de crash do servidor
	{
		name = "Mensagem de Crash",
		format = "string",
		desc = "Mensagem exibida aos jogadores que estiverem online quando o servidor parar de funcionar inesperadamente (por erros do jogo)",
		check_value = function(value)
			return true
		end,
		get_value = function()
			return minetest.setting_get("kick_msg_crash")
		end,
		set_value = function(value)
			minetest.setting_set("kick_msg_crash", value)
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
			--.."label[3.5,2;Ponto de Spawn]"
			--.."button_exit[3.5,2.4;3,1;definir_spawn;Definir Aqui]"
			--.."button_exit[6.5,2.4;3,1;ir_spawn;Ir para Spawn]"
			--.."field[3.8,4.1;3,1;slots;Limite de Jogadores;"..minetest.setting_get("max_users").."]"
			--.."button_exit[6.5,3.8;3,1;definir_slots;Redefinir Limite]"
		
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
			
			-- Campo para preenchimento
			if escolha.format == "bool" then
				form = form ..  "checkbox[3.5,1.8;checkbox;Ativar PvP;true]"
				
				
				-- Texto de aviso
				if acessos[name].aviso or 1 == 1 then
					form = form .. "label[3.5,2.6;"..acessos[name].aviso.."]"
					acessos[name].aviso = nil
				end
				
				-- Descritivo
				form = form .. "textarea[3.8,3.3;5,8.7;;Descritivo:\n"..escolha.desc..";]"
			end
			
			-- Insere no formspec
			formspec = formspec .. form
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
			
			-- Outros formatos
			else
				value = fields.config_label_1
			end
			
			-- Atualiza campo exibido no painel
			acessos[name].config_label_1 = value
			
			-- Verificador personalizado
			local check = escolha.check_value()
			if check ~= true then
				acessos[name].aviso = check
				gestor.menu_principal(name)
				return
			end
			
			-- Configurar valor
			escolha.set_value(value)
			acessos[name].aviso = "Definido"
			gestor.menu_principal(name)
		end
	end,
})

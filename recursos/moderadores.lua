--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para desligamento do servidor
  ]]


-- Lista de moderadores
if gestor.bd.verif("staff", "list") == false then
	gestor.bd.salvar("staff", "list", {})
end

-- Controle de acessos
local acessos = {}
minetest.register_on_joinplayer(function(player)
	acessos[player:get_player_name()] = {}
end)
minetest.register_on_leaveplayer(function(player)
	acessos[player:get_player_name()] = nil
end)

-- Registrar aba 'moderadores'
gestor.registrar_aba("moderadores", {
	titulo = "Moderadores",
	get_formspec = function(name)
		
		-- Gera string dos moderadores listados
		local staff_list_string = ""
		for staff,staff_name in ipairs(gestor.bd.pegar("staff", "list")) do
			if staff_list_string ~= "" then staff_list_string = staff_list_string .. "," end
			staff_list_string = staff_list_string .. staff_name
		end
		
		local formspec = "label[3.5,1;Gerenciamento de Moderadores]"
			.."label[9,1;Lista de Moderadores]"
			.."textlist[9,1.5;4.5,3;staff_list;"..staff_list_string.."]"
			.."field[3.8,2.3;5,1;new_staff;Novo moderador;]"
			.."button[3.5,2.9;5,1;add_staff;Adicionar Moderador]"
			.."button[3.5,3.8;5,1;rem_staff;Remover Moderador]"
			
			.."label[3.5,5;Interditar Servidor]"
			.."checkbox[3.5,5.5;interditar;Interditar Servidor;"..tostring(minetest.settings:get("gestor_interditado", false)).."]"
			.."textarea[3.8,6.3;10.2,1;;Expulsa todos os jogadores comuns e permite apenas moderadores conectarem;]"
			.."field[3.8,7.5;7,1;aviso_interditado;Aviso de Servidor Interditado;"..(minetest.settings:get("gestor_aviso_interditado") or "").."]"
			.."button[10.5,7.2;3,1;redefinir_msg;Redefinir]"
			
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		-- Selecionar item
		if fields.staff_list and table.maxn(gestor.bd.pegar("staff", "list")) > 0 then
			local n = string.split(fields.staff_list, ":")
			acessos[name].escolha = tonumber(n[2]) or 1
			gestor.menu_principal(name)
		
		--Adicionar moderador
		elseif fields.add_staff and fields.new_staff ~= "" then
			local staff_list = gestor.bd.pegar("staff", "list")
			table.insert(staff_list, fields.new_staff)
			gestor.bd.salvar("staff", "list", staff_list)
			gestor.menu_principal(name)
		
		-- Remover moderador
		elseif fields.rem_staff and acessos[name].escolha then
			local staff_list = gestor.bd.pegar("staff", "list")
			table.remove(staff_list, acessos[name].escolha)
			gestor.bd.salvar("staff", "list", staff_list)
			gestor.menu_principal(name)
		
		-- Interditar
		elseif fields.interditar then
			minetest.settings:set("gestor_interditado", fields.interditar)
			minetest.settings:write()
			gestor.interditar_servidor()
			
		-- Redefir mensagem de interdição
		elseif fields.redefinir_msg then
			minetest.settings:set("gestor_aviso_interditado", fields.aviso_interditado)
		-- Sair
		elseif fields.exit then
			acessos[name].escolha = nil
		end
	end,
})


-- Interditar_servidor
gestor.interditado = minetest.settings:get_bool("gestor_interditado", false) or false
gestor.interditar_servidor = function()
	-- Altera variavel global de controle
	gestor.interditado = true
	
	local staff_list = gestor.bd.pegar("staff", "list")
	local staff_list_i = {}
	for _,n in ipairs(staff_list) do
		staff_list_i[n] = true
	end
	
	-- Mensagem
	local msg = minetest.settings:get("gestor_aviso_interditado") or ""
	
	-- Expulsa jogadores que nao fazem parte dos moderadores
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if staff_list_i[name] == nil and minetest.check_player_privs(name, {server=true}) ~= true then
			minetest.kick_player(name, msg)
		end
	end
end

-- Evita conectarem caso esteja interditado
minetest.register_on_prejoinplayer(function(name)
	
	-- Mensagem
	local msg = minetest.settings:get("gestor_aviso_interditado") or ""
	
	if gestor.interditado == false then return end
	
	local staff_list = gestor.bd.pegar("staff", "list")
	local staff_list_i = {}
	for _,n in ipairs(staff_list) do
		staff_list_i[n] = true
	end
	
	if staff_list_i[name] == nil and minetest.check_player_privs(name, {server=true}) ~= true then
		return msg
	end
end)



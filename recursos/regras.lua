--[[
	Mod Gestor para Minetest
	Gestor v2.0 Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Recurso para exigir a aceitação das regras do servidor
  ]]

-- Variavel de controle
local exibir_regras = minetest.settings:get_bool("gestor_obrigar_aceitar_regras", false) or false

-- Texto de Regras
local texto_regras = "Sem Regras"
if gestor.bd.verif("regras", "default") == false then
	gestor.bd.salvar_texto("regras", "default", "Sem Regras")
end
texto_regras = gestor.bd.pegar_texto("regras", "default")


-- Controle de acessos
local acessos = {}
minetest.register_on_joinplayer(function(player)
	acessos[player:get_player_name()] = {}
end)
minetest.register_on_leaveplayer(function(player)
	acessos[player:get_player_name()] = nil
end)

local ajustar_texto = function(t)
	t = string.gsub(t, "\\", "\\\\")
	t = string.gsub(t, ";", ",")
	t = string.gsub(t, "%[", "(")
	t = string.gsub(t, '%]', ")")
	return t
end

-- Registrar aba 'regras'
gestor.registrar_aba("regras", {
	titulo = "Regras",
	get_formspec = function(name)
		
		local formspec = "label[3.5,1;Regras do Servidor]"
			.."textarea[3.9,1.8;9.8,8.5;texto_regras;;"..texto_regras.."]"
			.."button[3.5,9.4;8,1;redefinir;Redefinir]"
			.."button[11.5,9.4;2,1;verificar;Verificar]"
			.."checkbox[3.5,10.1;exibir_regras;Obrigar jogadores a aceitar as regras do servidor;"..tostring(minetest.settings:get("gestor_obrigar_aceitar_regras", false)).."]"
			
		-- Aviso
		if acessos[name].aviso then
			formspec = formspec.."label[3.5,8.9;"..acessos[name].aviso.."]"
			acessos[name].aviso = nil
		end
		
		return formspec
	end,
	on_receive_fields = function(player, fields)
		local name = player:get_player_name()
		
		-- Obrigar aceitar regras
		if fields.exibir_regras then
			minetest.settings:set("gestor_obrigar_aceitar_regras", fields.exibir_regras)
			minetest.settings:write()
			exibir_regras = minetest.settings:get_bool("gestor_obrigar_aceitar_regras", false)
		
		-- Redefinir regras
		elseif fields.redefinir and fields.texto_regras ~= "" then
			gestor.bd.salvar_texto("regras", "default", ajustar_texto(fields.texto_regras))
			texto_regras = gestor.bd.pegar_texto("regras", "default")
			acessos[name].aviso = "Regras redefinidas"
			gestor.menu_principal(name)
		
		-- Verificar como ficou a formspec
		elseif fields.verificar then
			gestor.exibir_formspec_regras(player)
		end
	end,
})

-- Exibir formspec de regras
gestor.exibir_formspec_regras = function(player)
	
	-- Formspec
	local formspec = "size[9,8]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;Regras do Servidor]"
		.."textarea[0.5,0.5;8.8,6.8;;"..texto_regras..";;true]"
		.."button_exit[0,7.4;3,1;recusar;Recusar]"
		.."button_exit[6,7.4;3,1;aceitar;Aceitar]"
	
	-- Exibe regras
	minetest.show_formspec(player:get_player_name(), "gestor:regras_obrigatorias", formspec)
end

-- Ao conectar
minetest.register_on_joinplayer(function(player)
	if exibir_regras == false then return end
	
	-- Verifica se ja aceitou
	if player:get_attribute("gestor_aceitou_regras") == "true" then return end
	
	gestor.exibir_formspec_regras(player)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "gestor:regras_obrigatorias" then -- This is your form name
		
		-- Caso estava so verificando regras
		if player:get_attribute("gestor_aceitou_regras") == "true" then return end
		
		if fields.aceitar then
			player:set_attribute("gestor_aceitou_regras", "true")
			
		-- Qualquer outro retorno
		else
			minetest.kick_player(player:get_player_name())
		end
	end
end)

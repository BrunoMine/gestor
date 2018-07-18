--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Menu Principal (Painel do gestor)
  ]]

-- Abas registradas
gestor.abas = {}

-- Registrar aba
local botoes_abas = {
	"0,1;3,1", -- 1
	"0,2;3,1", -- 2
	"0,3;3,1", -- 3
	"0,4;3,1", -- 4
	"0,5;3,1", -- 5
	"0,6;3,1", -- 6
	"0,7;3,1", -- 7
	"0,8;3,1", -- 8
	"0,9;3,1", -- 9
}
gestor.registrar_aba = function(name, def)
	gestor.abas[name] = def
	gestor.abas[name].formspec_button = "button["..botoes_abas[1]..";"..name..";"..def.titulo.."]"
	table.remove(botoes_abas, 1)
end

-- Abrir Menu principal
gestor.menu_principal = function(name)
	local player = minetest.get_player_by_name(name)
	
	-- Verifica aba em acesso
	local aba_atual = player:get_attribute("gestor_aba")
	if aba_atual == nil then
		aba_atual = "inicio"
		player:set_attribute("gestor_aba", aba_atual)
	end
	
	local formspec = "size[14,11]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;Gestor Administrativos do Servidor]"
		
	-- Botoes de abas
	for name_aba,def in pairs(gestor.abas) do
		formspec = formspec..def.formspec_button
	end
	
	--
	-- Gerando Abas
	--
	
	if aba_atual ~= "inicio" then
		
		-- Gerar formspec
		formspec = formspec .. gestor.abas[aba_atual].get_formspec(name)
		
	end

	-- Exibir tela
	minetest.show_formspec(name, "gestor:menu_principal", formspec)
end


-- Receptor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	
	-- Verifica aba em acesso
	local aba_atual = player:get_attribute("gestor_aba")
	if aba_atual == nil then
		aba_atual = "inicio"
		player:set_attribute("gestor_aba", aba_atual)
	end
	
	-- Menu Principal
	if formname == "gestor:menu_principal" then
		local name = player:get_player_name()
		
		-- Alternar aba
		for name_aba,dados in pairs(gestor.abas) do
			if fields[name_aba] then
				-- Gerar formspec
				player:set_attribute("gestor_aba", name_aba)
				gestor.menu_principal(name)
				return
			end
		end
		
		-- Retornos para a aba registrada
		if aba_atual ~= "inicio" then
	
			-- Retorno
			gestor.abas[aba_atual].on_receive_fields(player, fields)
			return
		end
		
	end
	
end)


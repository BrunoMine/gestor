--
-- Mod gestor
--
-- Comandos
--

-- Comando para exibir tela de gerenciamento
minetest.register_chatcommand("gestor", {
	privs = {server=true},
	params = "[Nenhum]",
	description = "Abrir tela de gerenciamento",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		player:set_attribute("gestor_aba", "inicio")
		minetest.after(0.1, gestor.menu_principal, name, true)
	end
})

 -- Menu de acesso simples
if sfinv_menu then
	sfinv_menu.register_button("gestor:painel", {
		title = "Gestor",
		icon = "gestor.png",
		privs = {server=true},
		func = function(player)
			local name = player:get_player_name()
			player:set_attribute("gestor_aba", "inicio")
			minetest.after(0.1, gestor.menu_principal, name, true)
		end,
	})
end

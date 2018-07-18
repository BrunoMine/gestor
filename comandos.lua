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
		minetest.after(1, gestor.menu_principal, name, true)
	end
})


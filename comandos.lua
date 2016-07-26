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
		minetest.after(1, gestor.menu_principal, name, true)
	end
})


-- Comando de serializar estrutura
minetest.register_chatcommand("serializar", {
	privs = {server=true},
	params = "[<arquivo/nome> <largura> <altura>]",
	description = "Serializa uma estrutura",
	func = function(name,  param)
		local m = string.split(param, " ")
		local param1, param2, param3 = m[1], m[2], m[3]
		if param1 then
			local player = minetest.get_player_by_name(name)
			local pos = player:getpos()
			if gestor.estruturador.salvar(pos, param1, param2, param3) then
				minetest.chat_send_player(name, "Estrutura serializada com sucesso")
			else
				minetest.chat_send_player(name, "Falha ao serializar estrutura")
			end
		else
			minetest.chat_send_player(name, "Comando invalido")
		end
	end
})

-- Comando de deserializar estrutura
minetest.register_chatcommand("deserializar", {
	privs = {server=true},
	params = "[<arquivo/nome> <largura> <altura>]",
	description = "Serializa uma estrutura",
	func = function(name,  param)
		local m = string.split(param, " ")
		local param1, param2, param3 = m[1], m[2], m[3]
		if param1 then
			local player = minetest.get_player_by_name(name)
			local pos = player:getpos()
			if gestor.estruturador.carregar(pos, param1, param2, param3) then
				minetest.chat_send_player(name, "Estrutura deserializada com sucesso")
			else
				minetest.chat_send_player(name, "Falha ao deserializar estrutura")
			end
		else
			minetest.chat_send_player(name, "Comando invalido")
		end
	end
})

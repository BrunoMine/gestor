--
-- Mod gestor
--
-- Inicializador
--

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[GESTOR]"..msg)
	end
end

local modpath = minetest.get_modpath("gestor")

-- Variavel global das funcionalidades
gestor = {}

-- Banco de Dados do gestor
gestor.bd = memor.montar_bd()

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/diretrizes.lua")
dofile(modpath.."/banco_de_dados.lua")
dofile(modpath.."/estruturador.lua")
dofile(modpath.."/protetor.lua")
dofile(modpath.."/lugares_avulsos.lua")
dofile(modpath.."/menu_principal.lua")
dofile(modpath.."/comandos.lua")
dofile(modpath.."/anticrash.lua")
notificar("OK")

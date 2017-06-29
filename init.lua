--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

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
dofile(modpath.."/estruturador.lua")
dofile(modpath.."/protetor.lua")
dofile(modpath.."/lugares_avulsos.lua")
dofile(modpath.."/vilas.lua")
dofile(modpath.."/menu_principal.lua")
dofile(modpath.."/comandos.lua")
dofile(modpath.."/alerta_de_crash.lua")
notificar("OK")

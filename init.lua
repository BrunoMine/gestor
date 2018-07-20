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
gestor.bd = dofile(modpath.."/lib/memor.lua")

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/diretrizes.lua")
dofile(modpath.."/menu_principal.lua")
dofile(modpath.."/comparar_tempo.lua")
dofile(modpath.."/comandos.lua")
-- Recursos
dofile(modpath.."/recursos/desligar.lua")
dofile(modpath.."/recursos/conf.lua")
dofile(modpath.."/recursos/moderadores.lua")
dofile(modpath.."/recursos/regras.lua")
dofile(modpath.."/recursos/penalidades.lua")
dofile(modpath.."/recursos/censura.lua")
dofile(modpath.."/recursos/antiflood.lua")
dofile(modpath.."/recursos/alerta_de_crash.lua")
notificar("OK")

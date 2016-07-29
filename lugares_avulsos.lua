--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Lugares avulsos
  ]]

-- Variavel global
gestor.lugares_avulsos = {}

-- Definir um lugar no banco de dados (usado para inserir e editar)
gestor.lugares_avulsos.definir = function(nome, status, texto)
	if not nome or not texto then return false end
	gestor.bd:salvar("avulsos", nome, {status=status, texto=texto})
	return true
end


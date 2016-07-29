--[[
	Mod Gestor para Minetest
	Gestor v1.0 Copyright (C) 2016 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Funcionalidades do anticrash
  ]]

gestor.anticrash = {}

-- Caminho da pasta de depurador (depug.txt)
local debug_path = io.popen"pwd":read"*all"
debug_path = string.split(debug_path, "\n")
debug_path = debug_path[1]

-- Caminho do mod
local modpath = minetest.get_modpath("gestor")

-- Caminho da pasta do executavel (minetest) orientado pela pasta do mod
local bin_path = modpath.."/../../bin"

-- Nome do mundo
local worldname = string.split(minetest.get_worldpath(), "worlds/")
worldname = worldname[table.maxn(worldname)]

-- Validar dados
--[[
	Verificar a existencia de dados e 
	cria-los com valor padrão para que
	estejam disponiveis
  ]]
local verificar_dado = function(dado, padrao)
	if gestor.bd:verif("anticrash", dado) ~= true then
		gestor.bd:salvar("anticrash", dado, padrao)
	end
end

-- Tabela de dados (que devem estar no banco de dados)
local dados = {
	-- 	Dados				Valor padrao
	-- Sistema AntCrash
	{	"bin_path",			"./../../bin"},
	{	"bin_args",			"./minetest --server --worldname "..worldname},
	{	"interval",			"300"},
	{	"quedas",				"2"},
	-- Sistema de Email
	{	"status_email",		"false"},
	{	"from_email",			"-"},
	{	"from_login",			"-"},
	{	"from_smtp",			"-"},
	{	"from_smtp_port",		"-"},
	{	"from_subject",		"Servidor reiniciado!"},
	{	"from_text",			"Texto"},
	{	"from_subject_em",		"ALERTA Servidor inoperante"},
	{	"from_text_em",		"O servidor cai muito rapidamente. Anticrash foi interrompido para evitar danos"},
	{	"to_email",			"-"},
	-- Sistema de Backups
	{	"status_backup",		"false"},
	{	"debug_path",			debug_path},
	{	"world_path",			minetest.get_worldpath()},
}

-- Verifica todos os dados
for _, v in ipairs(dados) do
	verificar_dado(v[1], v[2])
end

-- Salvar um valor para o antcrash
gestor.anticrash.serializar = function(dado, valor)
	if not dado or not valor then return end
	os.execute("echo \""..valor.."\" > "..string.gsub(modpath, " ", "\\ ").."/dados/"..dado)
end

-- Salva todos os dados para o shell
gestor.anticrash.salvar_dados = function()
	for _, v in ipairs(dados) do
		gestor.anticrash.serializar(v[1], gestor.bd:pegar("anticrash", v[1]))
	end
	if gestor.bd:verif("anticrash", "from_senha") then -- separada
		gestor.anticrash.serializar("from_senha", gestor.bd:pegar("anticrash", "from_senha"))
	end 
end

-- Atualiza os dados salvos por garantia
gestor.anticrash.salvar_dados()

-- Parar anticrash
minetest.register_on_shutdown(function()
	gestor.anticrash.serializar("status", "off")
end)
gestor.anticrash.serializar("status", "on") -- liga durante o ligamento do servidor


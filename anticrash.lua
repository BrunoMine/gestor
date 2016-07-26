--
-- Mod gestor
--
-- Sistema AntiCrash
--

gestor.anticrash = {}

-- Caminho da pasta de depurador (depug.txt)
local debug_path = io.popen"pwd":read"*all"
debug_path = string.split(debug_path, "\n")
debug_path = debug_path[1]

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
	{	"comando_abertura",		"./../../bin/minetest --server"},
	{	"processo",			"minetest --server"},
	{	"interval",			"300"},
	-- Sistema de Email
	{	"status_email",		"false"},
	{	"from_email",			"gestorminemacro@gmail.com"},
	{	"from_login",			"gestorminemacro@gmail.com"},
	{	"from_senha",			""},
	{	"from_smtp",			"smtp.gmail.com"},
	{	"from_smtp_port",		"587"},
	{	"from_subject",		"Servidor reiniciado!"},
	{	"to_email",			"borgesdossantosbruno@gmail.com"},
	-- Sistema de Backups
	{	"status_backup",		"false"},
	{	"debug_path",			debug_path},
	{	"world_path",			minetest.get_worldpath()},
}

-- Verifica todos os cados
for _, v in ipairs(dados) do
	verificar_dado(v[1], v[2])
end

-- Iniciar anticrash
gestor.anticrash.iniciar = function()
	local comando = "./anticrash "
		-- ..comando_abertura.." " -- 1
		-- ..processo.." " -- 2
		-- ..interval.." " -- 3
		-- ..status_email.." " -- 4
		-- ..from_email.." " -- 5
		-- ..from_login.." " -- 6
		-- ..from_senha.." " -- 7
		-- ..from_smtp.." " -- 8
		-- ..from_smtp_port.." " -- 9
		-- ..from_subject.." " -- 10
		-- ..to_email.." " -- 11
		-- ..status_backup.." " -- 12
		-- ..debug_path.." " -- 13
		-- ..world_path.." " -- 14
		.."&"
	os.execute(comando)
end



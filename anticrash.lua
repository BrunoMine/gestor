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

--local bin_path = io.popen"locate bin/minetest":read"*all"
--minetest.after(3, minetest.chat_send_all, dump(bin_path))

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
	{	"from_email",			"-"},
	{	"from_login",			"-"},
	--{	"from_senha",			""},
	{	"from_smtp",			"-"},
	{	"from_smtp_port",		"-"},
	{	"from_subject",		"Servidor reiniciado!"},
	{	"to_email",			"-"},
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
	local comando_abertura = gestor.bd:pegar("anticrash", "comando_abertura") or ""
	local processo = gestor.bd:pegar("anticrash", "processo") or ""
	local interval = gestor.bd:pegar("anticrash", "interval") or ""
	local from_email = gestor.bd:pegar("anticrash", "from_email") or ""
	local from_senha = gestor.bd:pegar("anticrash", "from_senha") or ""
	local from_smtp = gestor.bd:pegar("anticrash", "from_smtp") or ""
	local from_subject = gestor.bd:pegar("anticrash", "from_subject") or ""
	local from_text = gestor.bd:pegar("anticrash", "from_text") or ""
	local to_email = gestor.bd:pegar("anticrash", "to_email") or ""
	local world_path = gestor.bd:pegar("anticrash", "world_path") or ""
	local debug_path = gestor.bd:pegar("anticrash", "debug_path") or ""
	
	-- Verificar sistema de email
	if gestor.bd:pegar("anticrash", "status_email") == "false" then
		from_email = ""
	end
	
	-- Verificar sistema de backup
	if gestor.bd:pegar("anticrash", "status_backup") == "false" then
		debug_path = ""
	end
	
	-- Verificar dados obrigatorios
	if interval == "" or processo == "" or comando_abertura == "" then
		return false
	end
	
	local comando = "./anticrash "
		.."\""..interval.."\" " -- 1 (interval)
		.."\""..processo.."\" " -- 2 (processo)
		.."\""..comando_abertura.."\" " -- 3 (comando_abertura)
		.."\""..debug_path.."\" " -- 4 (debug_path)
		.."\""..world_path.."\" " -- 5 (world_path)
		.."\""..from_email.."\" " -- 6 (from_email)
		.."\""..from_login.."\" " -- 7 (from_login)
		.."\""..from_senha.."\" " -- 8 (from_senha)
		.."\""..from_smtp.."\" " -- 9 (from_smtp)
		.."\""..from_subject.."\" " -- 10 (from_subject)
		.."\""..from_text.."\" " -- 11 (from_text)
		.."\""..to_email.."\" " -- 12 (to_email)
		.."&"
	os.execute(comando)
	return true
end


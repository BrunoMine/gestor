--
-- Mod gestor
--
-- Lugares avulsos (gerenciamento)
--

-- Variavel global
gestor.lugares_avulsos = {}

-- Definir um lugar no banco de dados (usado para inserir e editar)
gestor.lugares_avulsos.definir = function(nome, status, texto)
	if not nome or not texto then return false end
	gestor.bd:salvar("avulsos", nome, {status=status, texto=texto})
	return true
end


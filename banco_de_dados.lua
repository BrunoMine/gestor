--
-- Mod gestor
--
-- Banco de Dados
--


-- Validar dados

-- Minemacro (tabela 'centro')
if gestor.bd:verif("centro", "pos") ~= true then
	gestor.bd:salvar("centro", "status", false) -- Se minemacro esta ativo
	gestor.bd:salvar("centro", "pos", {x=0,y=0,z=0}) -- Coordenada de teleporte para o centro do servidor
end


-- Vilas (tabela 'vilas')
--[[
	São armazenadas com a index '<nome da vila>' e 
	o valor é uma tabela com o nome apresentavel e 
	a coordenada de teleport para a vila.
	Exemplo: ["blocopolis"] = {nome="Blocopolis", pos={x=100, y=100, z=100}}
  ]]

-- Lugares avulsos (tabela 'avulsos')
--[[
	São armazenadas com a index '<nome da lugar>' 
	e o valor é uma tabela com o status (para saber 
	se foi criada e devidamente operante) e um texto
	explicando como tornar a estrutura ativa e/ou 
	sobre algo sobre a propria estrutura.
	Exemplo: ["castelinho"] = {status=false, texto="Use /montar"}
  ]]



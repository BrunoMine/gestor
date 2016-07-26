# gestor

Por BrunoMine

Um gestor de servidor de minetest

COMANDOS:
=========

/gestor
Abre o painel do gestor administrativo

/serializar <arquivo/nome> <largura> <altura>
Salva uma estrutura no diretorio de estruturas
(toma a posicao do jogador como a menos em x, y e z)

/deserializar <arquivo/nome> <largura> <altura>
Cria uma estrutura do diretorio de estruturas
(toma a posicao do jogador como a menos em x, y e z)

ESTRUTURAS
==========
Para que as estruturas sejam controladas pelo gestor
precisam estar serializadas na pasta 'estruturas' 
e devidamente registradas no arquivo 'diretrizes.lua'
Isso inclui apenas as estruturas das vilas e a do 
centro a do Centro do Servidor (essa ultima deve estar
num arquivo com nome 'centro' enquanto as demais podem
variar como 'blocopolis', 'monte_branco', 'arena_pvp')
No nome do arquivo da estrutura deve-se tomar cuidado e 
jamais usar sempre usar "_" (sublinhado/underline) no
lugar de espaço e evitar caracteres especiais como
c cidilha e outros.

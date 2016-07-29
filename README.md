Gestor v1.0
===========

Por BrunoMine

Um gestor de servidor de minetest

LICENÇA LGPL v3

Gestor é um software livre; você pode redistribuí-lo e/ou 
modificá-lo dentro dos termos da Licença Pública Geral Menor GNU 
como publicada pela Fundação do Software Livre (FSF); na versão 3 
da Licença, ou (na sua opinião) qualquer versão.
Este programa é distribuído na esperança de que possa ser útil, 
mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO
a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a
Licença Pública Geral Menor GNU para maiores detalhes.
Você deve ter recebido uma cópia da Licença Pública 
Geral Menor GNU junto com este programa, 
se não, veja <http://www.gnu.org/licenses/>.

COMANDOS

/gestor | Abre o painel do gestor administrativo

/serializar <arquivo/nome> <largura> <altura> | Salva uma estrutura no diretorio de estruturas 
(toma a posicao do jogador como a menos em x, y e z)

/deserializar <arquivo/nome> <largura> <altura> | Cria uma estrutura do diretorio de estruturas
(toma a posicao do jogador como a menos em x, y e z)

ESTRUTURAS

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

ANTICRASH

O sistema anticrash funciona de maneira independete 
do servidor no entanto os dados que ele utiliza sãoo 
atualizados quando o servidor inicia portanto sempre 
abra o servidor no mundo desejado uma vez antes de 
iniciar o anticrash (apenas quando tiver mudado de 
lugar ou renomeado um diretorio do servidor de 
minetest incluindo a pasta do mundo). O anticrash deve 
abrir o servidor e deve ser execute o arquivo 
gestor-anticrash-minetest.sh a partir de qualquer da 
pasta bin do minetest (exemplos de comandos ficam no 
painel administrativo ingame).
Lembre de rodar esse anticrash em segundo plano para 
poder fechar o terminal e deixar o anticrash rodando 
normalmente.

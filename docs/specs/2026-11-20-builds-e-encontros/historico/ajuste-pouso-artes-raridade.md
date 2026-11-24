# Ajuste de pouso e apresentação das cartas

- Seed 42, primeiro combate. Um obstáculo fora da posição de pouso invalidava a varredura integral do piso. O Tranca-Lata agora mede a distância livre nos dois sentidos a partir do pouso e usa essa faixa para patrulhar.
- A raridade sobe quatro pixels na carta de recompensa e na carta de loja. O indicador de cor dos itens foi reduzido e acompanha o texto.
- Brasa Persistente, Fornalha, Leque de Estilhaços, Núcleo de Estilhaços e Chuva de Brasas têm PNGs transparentes próprios em 128 × 80 e fontes Aseprite editáveis. O gerador fica em `assets/ui/upgrade_cards_v1/source/generate_element_specializations.lua`.

## Verificação no Godot 4.7.2

- `qa_landing_fix.gd` na cópia temporária. A faixa livre mediu 116,26 px. Com o jogador reposicionado, o inimigo avançou 117 px depois do pouso.
- `qa_current.gd` e `qa_world_screens.gd`. Runs assistidas nas seeds 42, 4162699858 e 20261120 chegaram à vitória e retornaram ao lobby.
- `qa_screens.gd`. As cinco ilustrações foram carregadas pelo recurso de cada carta. Títulos, raridades e tópicos foram inspecionados no Godot em 1080p e 720p. Loja inspecionada em 1080p. Auditoria dos cinco PNGs passou em dimensões, grade, quantidade de cores, opacidade e pixels isolados.
- As execuções assistidas verificam progressão e a regressão de pouso. A dificuldade em partida manual ainda não foi medida.


Ajuste posterior para deslizamento depois de um pulo. Em contato com o topo de uma colisão do cenário, o Tranca-Lata pode reconhecer uma plataforma no mesmo nível dos pés e dirige a saída lateral para o interior quando só parte do corpo cabe no apoio. O limite de dois segundos do voo também encerra a tentativa lateral. Depois do limite, o inimigo procura a posição apoiada livre mais próxima. A consulta inclui colisões de cenário e jogador. Correção revisada estaticamente. Validação em partida pendente.

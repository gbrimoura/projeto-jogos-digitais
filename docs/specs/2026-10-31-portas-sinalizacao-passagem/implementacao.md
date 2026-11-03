# Implementação — portas e sinalização

As portas deixam de renderizar textos de entrada/saída, estado ou travessia sobre a fase. Os nós DoorLabel ficam vazios e invisíveis para preservar os overrides e índices das cenas existentes; o script não depende deles para abrir o vão.

A saída liberada recebe seta âmbar/creme com contorno, construída por retângulos de pixels e orientada por portal_direction. Entrada, bloqueio, transição ocupada e terminal ocultam a indicação. Após falha recuperável, ela pode voltar quando a saída estiver disponível. UP/DOWN ficam alinhadas ao centro do vão; a seta inferior termina acima do piso, apontando para a abertura.

O desenho da porta foi separado em fundo/poço no z absoluto -1 e moldura/indicador no z absoluto+1. O fundo deixa de cobrir o personagem no alçapão. O piso e o teto já recortam os vãos pelo fluxo existente; a moldura aberta contém bordas, sem preencher a abertura com um retângulo opaco à frente do ator. O ajuste muda a leitura de profundidade, não o ponto físico de troca da sala.

## Arquivos e configuração

- scripts/world/exit_door.gd: apresentação dos estados, label opcional, orientação da arte e indicador; mensagens standalone encaminhadas ao StatusLabel já existente quando disponível.
- scripts/world/side_door_visual.gd: fundo aberto, atrás do ator.
- scripts/world/door_foreground_visual.gd: moldura e grades, com posições arredondadas à grade.
- scripts/world/exit_direction_indicator.gd: seta geométrica em quatro direções, sem rotação fracionária.
- scenes/exit_door.tscn: composição dos CanvasItems, preservando DoorLabel no índice2.
- scenes/main.tscn e second_room.tscn: somente overrides de label vazia e invisível.

_Indicator_offset em ExitDoor define a distância do indicador ao vão. As coordenadas de gate, sensores e linha de cruzamento não mudaram. Colisões, Player, Main, RunController, geração, seed, HP, build e fade permanecem preservados. Os erros técnicos gerenciados continuam em seus overlays.

## Validação e limites

Implementação por um único GPT-6 Luna xhigh, com Fast/priority não confirmável pela interface. Root avaliou as fontes/deltas e coordenou a correção R2 da posição das setas verticais antes da revisão externa. Não houve Godot/importação, testes, parser, linter ou audit executados nesta tarefa. A aparência em runtime não foi confirmada. Pacotes imutáveis R1/R2 e saídas originais ficam em historico/ e pareceres/.

Um arquivo vazio residual criado pelo implementador fora do repo foi preservado após bloqueio automático da tentativa de remoção. Não é referenciado pelo projeto. Caminho e incidente constam no plano; nenhuma nova tentativa de apagar ou mover foi feita. Sem commit, push ou troca de branch.

R3 corrigiu também o espelhamento da profundidade esquerda, alinhando as faixas de sombra/cobre à moldura. Gemini/Muse R3 sem achados; Grok sem parecer, Opus quota. Estado final:7fontes aplicadas, revisão estática encerrada com essas limitações e sem execução visual.

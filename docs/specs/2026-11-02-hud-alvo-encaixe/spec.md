# Especificação — painel de alvo 144×40

Manter o painel no tamanho144×40 e pixels inteiros. Retrato ocupa a região máxima32×28 em `(6,6)`: conserva tamanho natural quando cabe; se exceder, é contido e centralizado com filtragem nearest, sem ultrapassar a região.

A fonte continua5×11 com avanço6. O nome original usa a linha superior, posição `(42,6)`, largura96 e altura12; até16 caracteres ficam completos. `NV{level}` fica separado na segunda linha, em `(42,18)` com30×12 (nívelaté220). HP real e sem abreviação fica alinhado à direita em `(78,18)` com60×12; valores até `999/999` cabem. Uma barra exclusiva do alvo ocupa `(42,30)` até `(138,36)`, seis pixels de altura, e representa HP atual/máximo. A barra de vida do jogador permanece intacta.

`HudTargetPanel.set_target` e `CaldeiraHudRoot.set_target` recebem `level: int = 1` como último argumento. A bridge passa `display_name` sem prefixo e o nível como argumento distinto. Chamadas atuais com quatro argumentos seguem válidas; nível inferior a1 é apresentado como1.

Limite: nomes maiores que16 caracteres continuam sujeitos à política de truncamento da fonte. Níveis acima de220 e HP acima de três dígitos estão fora do contrato deste layout. Nenhum dado de combate é alterado.
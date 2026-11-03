# Especificação — tópicos e valores destacados

## Layout e copy
- Área de cada linha: 24 glifos (fonte 5×11, avanço 6 px); três linhas no máximo.
- Cada tópico começa com `- `; continuação do mesmo tópico começa com dois espaços.
- Quebrar o conteúdo em palavras com limite de 22 glifos, reservando duas colunas para o prefixo. Preservar palavras, pontuação e spans de cor através das quebras.
- Usar ciano `#52BAC7` no traço; cinza `#B6BEC3` nos rótulos, valores atuais, setas e condicionais; amarelo `#D2A75C` no benefício nominal ou valor novo.
- NOVO: realçar sinal, decimal e número, incluindo `s` quando for a unidade. EVOLUIR: manter cinza o valor atual e `>`, e realçar o valor novo completo, com sinal/unidade. Condições `Até 3 paredes...` e `Uma vez por rebatida` ficam cinza.
- Nenhuma caixa ou quadrado atrás das linhas de tópico. A faixa de Summary continua opaca como hoje.

## Renderização
Um script local derivado de `HudBitmapText` desenha os glifos existentes da fonte local de cartas usando o atlas/métricas já configurados pelo pai. A cor por glifo é calculada antes da quebra e remapeada a cada linha. Não alterar `HudBitmapText` nem carregar fonte nova.

## Fonte Aseprite e prévias
`clean_frames=true` só pode ser usado junto com `preview_only=true`. Limpar as marcas cobre isoladas em y=118..186 nos três frames do arquivo-fonte, sem tocar bordas, filetes/divisórias, ícones, fonte ou contato. O modo preview_only não gera os sete ícones. Reexportar as três molduras 160×240 e somente as duas prévias de estudo usando Aseprite.

## Conferência manual dos sete upgrades
Checar faixas e pior quebra, sem executar gameplay:
- Impacto, rank máximo 220: `Dano da bola: 220 > 221` precisa de duas linhas.
- Motor, rank máximo 3: valores de recarga com `s` permanecem juntos e legíveis, incluindo `0,55s > 0,4s`.
- Carga, rank máximo 220: `Dano extra: +438 > +440` pode quebrar; com `No próximo acerto`, usar três linhas no total.
- Pressão, rank máximo 3: valor por parede e limite condicional cabem em até três linhas.
- Mola, rank máximo 3: rebotes e `Duração: 2,55s > 2,9s` cabem em até três linhas.
- Dínamo, rank máximo 3: `Recarga do dash: -0,15s`/comparação e `Uma vez por rebatida` cabem em até três linhas.
- Chassi, rank máximo 95: a vida máxima e `Cura na escolha: +1 vida` cabem em até três linhas.

A quebra não pode truncar conteúdo; uma comparação pode continuar na linha seguinte sem perder a distinção visual entre valor atual, `>` e valor novo.
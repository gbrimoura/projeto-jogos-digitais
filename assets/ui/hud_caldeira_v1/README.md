# HUD Caldeira v1 — kit de autoria

Este kit reúne peças de interface pixel art e estudos de composição em Aseprite. É uma base editável para revisão visual; não está conectado ao runtime do jogo e não declara regras de HP, duração de recarga ou unidade de aceleração.

## Pastas

- `source/`: script Lua gerador e arquivos Aseprite em camadas (`.aseprite`). `source/.gdignore` mantém fontes fora do fluxo de importação automática.
- `export/`: peças PNG, atlas com padding transparente de 2 px por lado, gap de 4 px entre regiões e margem externa mínima de 2 px e metadados JSON para componentes, fonte, retratos, layout, paleta e manifest.
- `preview/`: composição sobre o fundo de referência, folha compacta, contato completo, amostras de estado e estudos de crop. `preview/.gdignore` evita importação automática dos estudos.

## Produção

Geração feita no Aseprite 1.3.18.6 com `source/generate_hud.lua`. O script espera `root` como parâmetro antes de `--script`, por exemplo:

```powershell
& 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe' -b --script-param 'root=C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais' --script 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais/assets/ui/hud_caldeira_v1/source/generate_hud.lua'
```

A saída de produção é registrada em `source/aseprite-production.log`, `source/aseprite-generate.stdout.log` e `source/aseprite-generate.stderr.log`; erros Lua são registrados em `source/aseprite-production-error.log`. `source/generate_hud.lua` reconstrói a base inteira e sobrescreve os `.aseprite`, exports e previews gerados; reexecutá-lo descarta alterações manuais feitas nos `.aseprite`. Para preservar uma edição manual, use no Aseprite **File > Save Copy...** com um novo nome `.aseprite` e **File > Export...** com um novo nome de saída. Não salve a edição sobre a fonte do gerador.

## Grade, cores e elementos

A composição de autoria mede **576×324 px** e corresponde a **1152×648 px** à escala inteira 2×. Para prévias, a folha completa é 3× (1728×2400) e a composição contextual também é fornecida a 576, 1152 e 1728 px de largura.

A paleta HUD local e suas 18 cores estão em `export/palette.json`; a máscara tipográfica é branca. Peças e fonte usam pixels duros com alpha 0/255. Os componentes incluem molduras 9-slice (cantos/margens de 6 px), painéis Player/Alvo 144×40, Dash 144×40, Salas 84×36, Gauge 84×60, moldura de barra 96×14 e fills separados de 90×8. Exemplos visuais são 3/5 = 54 px e 4/6 = 60 px.

O relógio tem 17 imagens normalizadas: índice 0 vazio/pronto, índice 16 cheio/recarga; não contém segundos de jogo. `source/clock-states.aseprite` mede 24×24 px e contém 17 frames sob a tag `clock_remaining_normalized_study`; `source/gauge-needle-states.aseprite` mede 37×20 px e contém 9 frames sob `gauge_needle_normalized_study`. O playback dessas tags é apenas estudo: um runtime futuro deve selecionar o índice normalizado, sem usar o tempo de playback como cooldown. No preview PRONTO o bloco mostra `DASH` e `PRONTO`, sem contador de tempo restante. A agulha do instrumento tem nove poses de estudo em escala normalizada, pivô inteiro e sem unidade/fórmula. `CONCEITO` é um layer/asset separado de 74×15 px, centralizado na coluna do instrumento.

A fonte bitmap própria usa célula 5×11, corpo nas linhas 2–8, acentos nas linhas 0–1, cedilha nas linhas 9–10, baseline zero-based 8, avanço 6 e entrelinha 12. A lista de glyphs e seus retângulos estão em `export/font.json`. A composição usa amostras PT-BR, incluindo `0,3s`.

Retratos usam recortes do frame 0 dos sprites existentes sem escala ou recoloração: Player (20,8,24×24), Cospe-Rebite (20,24,24×24) e Tranca-Lata (15,8,32×28). A exceção 32×28 preserva a face/visor e o capacete da referência. Fontes dos sprites permanecem somente leitura; veja `export/portraits.json` para os crops e atlas.

## Layout e limites

`export/layout.json` registra posição, dimensões e âncoras da composição padrão e uma alternativa com Gauge no canto inferior direito. O alvo tem área de valor alinhada à direita, até 42 px; quando esse valor ocupar tudo, o nome deve ser limitado a nove glyphs (54 px). Campos de texto e exemplos não definem limites nem mecânicas do jogo.

O rótulo `RECARREGANDO` tem 12 glyphs: avanço de 72 px e tinta de 71 px; a caixa de texto de 78 px conserva 6 px de folga horizontal. A arte de fundo é uma referência, não parte do overlay transparente. O arquivo `export/hud-overlay-576.png` é a camada transparente de estudo. Não foi feita integração/importação Godot nem teste automatizado; a execução do Aseprite é a etapa de autoria e exportação.

## Explorações mantidas fora da entrega

Estes arquivos são estudos de crops/folhas de versões anteriores; não são assets de entrega e não devem ser usados no lugar das saídas listadas em `export/manifest.json`:

- `export/portrait-tranca-lata-24.png` — crop anterior do alvo; o retrato atual é `portrait-tranca-lata-32x28.png`.
- `preview/portrait-candidates-target.png` — grade exploratória 24×24 anterior.
- `preview/hud-elements-1728x1728.png` e `preview/hud-elements-native-576x576.png` — folhas de contato exploratórias anteriores.

Os arquivos foram preservados. A tentativa de remoção foi bloqueada automaticamente; o retorno informou somente `Blocked by policy`, sem motivo específico. Não houve remoção nem movimentação.
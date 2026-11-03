# HUD Caldeira v1 — kit de autoria

Este kit reúne peças de interface pixel art e estudos de composição em Aseprite. É uma base editável para revisão visual; não está conectado ao runtime do jogo e não declara regras de HP, duração de recarga ou unidade de aceleração.

## Pastas

- `source/`: script Lua gerador e arquivos Aseprite em camadas (`.aseprite`). `source/.gdignore` mantém fontes fora do fluxo de importação automática.
- `export/`: peças PNG, atlas com padding transparente de 2 px e metadados JSON para componentes, fonte, retratos, layout, paleta e manifest.
- `preview/`: composição sobre o fundo de referência, folha compacta, contato completo, amostras de estado e estudos de crop. `preview/.gdignore` evita importação automática dos estudos.

## Produção

Geração feita no Aseprite 1.3.18.6 com `source/generate_hud.lua`. O script espera `root` como parâmetro antes de `--script`, por exemplo:

```powershell
& 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe' -b --script-param 'root=C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais' --script 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais/assets/ui/hud_caldeira_v1/source/generate_hud.lua'
```

A saída de produção é registrada em `source/aseprite-production.log`, `source/aseprite-generate.stdout.log` e `source/aseprite-generate.stderr.log`; erros Lua são registrados em `source/aseprite-production-error.log`. Os `.aseprite` devem ser abertos no Aseprite para ajustes de pixels e layers; execute o gerador novamente para regenerar exports e previews derivados.

## Grade, cores e elementos

A composição de autoria mede **576×324 px** e corresponde a **1152×648 px** à escala inteira 2×. Para prévias, a folha completa é 3× (1728×2400) e a composição contextual também é fornecida a 576, 1152 e 1728 px de largura.

A paleta HUD local e suas 18 cores estão em `export/palette.json`; a máscara tipográfica é branca. Peças e fonte usam pixels duros com alpha 0/255. Os componentes incluem molduras 9-slice (cantos/margens de 6 px), painéis Player/Alvo 144×40, Dash 144×40, Salas 84×36, Gauge 84×60, moldura de barra 96×14 e fills separados de 90×8. Exemplos visuais são 3/5 = 54 px e 4/6 = 60 px.

O relógio tem 17 imagens normalizadas: índice 0 vazio/pronto, índice 16 cheio/recarga; não contém segundos de jogo. A agulha do instrumento tem nove poses de estudo em escala normalizada, pivô inteiro e sem unidade/fórmula. `CONCEITO` é um layer/asset separado.

A fonte bitmap própria usa célula 5×11, corpo nas linhas 2–8, acentos nas linhas 0–1, cedilha nas linhas 9–10, baseline zero-based 8, avanço 6 e entrelinha 12. A lista de glyphs e seus retângulos estão em `export/font.json`. A composição usa amostras PT-BR, incluindo `0,3s`.

Retratos usam recortes do frame 0 dos sprites existentes sem escala ou recoloração: Player (20,8,24×24), Cospe-Rebite (20,24,24×24) e Tranca-Lata (15,8,32×28). A exceção 32×28 preserva a face/visor e o capacete da referência. Fontes dos sprites permanecem somente leitura; veja `export/portraits.json` para os crops e atlas.

## Layout e limites

`export/layout.json` registra posição, dimensões e âncoras da composição padrão e uma alternativa com Gauge no canto inferior direito. O alvo tem área de valor alinhada à direita, até 42 px; quando esse valor ocupar tudo, o nome deve ser limitado a nove glyphs (54 px). Campos de texto e exemplos não definem limites nem mecânicas do jogo.

A arte de fundo é uma referência, não parte do overlay transparente. O arquivo `export/hud-overlay-576.png` é a camada transparente de estudo. Não foi feita integração/importação Godot nem teste automatizado; a execução do Aseprite é a etapa de autoria e exportação.
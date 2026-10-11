# Protagonista — dash v1

Este asset acrescenta três poses laterais de dash à fonte Aseprite da caminhada
v3. A arte existente de idle e walk mantém os doze quadros, as camadas e as
tags originais; o script abre essa fonte e salva uma cópia combinada com o nome
`protagonista-dash-v1.aseprite`.

## Animação

- **Dash:** impulso, avanço e sustentação, nos índices zero-based 12–14.
- **Tempo:** 40, 40 e 60 ms, total de 140 ms; o tag Aseprite toca uma vez.
- **Tags:** `idle` permanece em frames 1–6, `walk` em 7–12 e `dash` em 13–15.
  O script restaura os intervalos originais após anexar quadros, pois Aseprite
  expande a última tag ao acrescentar frames no fim do sprite.
- **Pose:** inclinação para +X, braços recolhidos para trás e pernas flexionadas
  articuladas aos quadris, com um pé junto ao chão. `flip_h` espelha a direção.
- **Canvas e paleta:** 64×64 px por quadro; 27 cores herdadas do idle v2; alpha
  binário. Os novos quadros usam apenas translações inteiras de pixels existentes.
- **Atlas final:** quinze quadros em uma linha, 960×64 px. Idle ocupa 0–5, walk
  6–11 e dash 12–14.

## Gerar a fonte combinada

Use Aseprite 1.3.18.6 e caminhos absolutos. `out` é a pasta de saída,
`source_aseprite` aponta para o v3 existente e `base` é o nome da fonte nova.
O valor padrão de `base` é `protagonista-dash-v1`.

```powershell
$ase = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
$assetDir = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash'
$walkSource = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk/protagonista-walk-v3.aseprite'
& $ase -b --script-param "out=$assetDir" --script-param "source_aseprite=$walkSource" --script (Join-Path $assetDir 'protagonista-dash.lua')
& $ase -b (Join-Path $assetDir 'protagonista-dash-v1.aseprite') --sheet-type horizontal --sheet (Join-Path $assetDir 'protagonista-dash-v1-spritesheet.png') --data (Join-Path $assetDir 'protagonista-dash-v1-spritesheet.json')
```

A segunda chamada exporta o atlas e os metadados de frames/tags do Aseprite. A
folha de runtime copiada para `assets/player/player-animations.png` é gerenciada
pelo agente principal.

## Prévia horizontal demonstrativa

`protagonista-dash-preview.lua` cria uma fonte de prévia separada, lendo o atlas
já exportado. Ela mostra um hold, o dash de 140 ms avançando 50 px nativos para
+X, outro hold e o retorno espelhado para −X. As sete amostras de 20 ms em cada
sentido repetem as poses de impulso, avanço e sustentação. O último quadro volta
à posição e orientação do primeiro hold antes do loop reiniciar, sem teleporte
visual.

Esta translação existe somente na prévia. No jogo, as poses do atlas permanecem
ancoradas no pivot; o movimento de 720 px/s por 0,14 s é aplicado pela física do
personagem. Não use a prévia horizontal como atlas de runtime.

```powershell
$ase = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
$assetDir = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash'
& $ase -b --script-param "out=$assetDir" --script-param "source_sheet=$(Join-Path $assetDir 'protagonista-dash-v1-spritesheet.png')" --script (Join-Path $assetDir 'protagonista-dash-preview.lua')
& $ase -b (Join-Path $assetDir 'protagonista-dash-horizontal-v1.aseprite') --scale 6 --save-as (Join-Path $assetDir 'protagonista-dash-horizontal-v1-preview.gif')
```

O primeiro comando salva `protagonista-dash-horizontal-v1.aseprite` (136×64,
16 quadros). O segundo gera o GIF ampliado por seis vezes. A prévia usa apenas
quadros existentes do atlas, mantém alpha binário e não altera a fonte Aseprite
ou os PNGs de runtime.

## Estado

O script e o contrato de animação estão implementados. Exportação e inspeção
visual dos três quadros pelo agente principal, revisões estáticas e conferência
manual no Godot ainda estão pendentes. Nenhum teste, Godot ou `quality_audit`
foi executado por este incremento.

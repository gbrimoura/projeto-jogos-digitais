# Especificação incremental — balanço dos braços V6

## Estado

A correção dos braços V6 está integrada. O principal inspecionou o contact final e confirmou que as mãos estão mais coesas. Gemini/Muse/Grok concluíram revisão estática V6; Opus bloqueado por quota; aprovação visual do usuário não registrada. A V5 permanece preservada como base.

## Diagnóstico e alteração

Na V5, o balanço lateral de até ±2 px produzia deslocamentos de 2–3 px entre fases em 75 ms. A V6 limita o swing por eixo a 1 px e aplica follow-through vertical de até 1 px à mão, com ombros ancorados nas linhas 40–41 relativas ao torso.

A inspeção do atlas intermediário mostrou que follow-through +1 deslocava só os pixels da linha y=44, deixando pequenos grupos da mão separados do antebraço. A fonte adiciona pontes mínimas de punho na região do braço para conectar os clusters nos quatro quadros com follow-through positivo. O ajuste fica dentro do envelope de braços; não altera pixels de cabeça, torso/bob, pernas/botas, idle, dash ou lógica do jogo.

- Base: oito poses frontais V5, 64×64, paleta de 27 cores, alpha binário, 75 ms por quadro.
- Ombros estáveis; swing do braço esquerdo: [1,1,0,-1,-1,-1,0,1]; follow-through vertical: [0,-1,-1,0,0,1,1,0]. O braço direito usa sinais opostos.
- Swing lateral máximo ±1 px; follow-through vertical máximo ±1 px; body bob, pernas e botas mantidos da V5.
- A comparação RGBA com a referência congelada V5 mostra zero diferenças em idle 0–5 e dash 14–16. As 200 diferenças nos quadros walk estão dentro do envelope x=18–29 ou x=34–47, y=38–46; não há diferenças fora dele. Alpha permanece binário e não há cores fora da paleta da entrada.

## Artefatos

Diretório: GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk/.

- Lua: protagonista-walk-v6-bracos.lua.
- Entrada congelada 960×64: protagonista-walk-v6-input-atlas-960x64.png.
- Referência V5 1088×64: protagonista-walk-v6-v5-reference-atlas-1088x64.png.
- Fonte editável: protagonista-walk-v6-bracos.aseprite.
- Atlas PNG/JSON: protagonista-walk-v6-bracos-spritesheet.png / protagonista-walk-v6-bracos-spritesheet.json, PNG 1088×64.
- Contact V6 768×768 e comparativo 1536×768: protagonista-walk-v6-bracos-contact.png e protagonista-walk-v6-bracos-contact-comparativo.png; no comparativo V5 ocupa a linha superior e V6 a inferior.
- GIFs esquerda/direita em escala nearest 6×: protagonista-walk-v6-bracos-preview-esquerda.gif e protagonista-walk-v6-bracos-preview-direita.gif, 960×384.
- Metadata: protagonista-walk-v6-bracos-metadata.json.

## Reprodução

Aseprite 1.3.18.6. Comando Lua usa o input congelado; export horizontal e GIFs ficam em comandos separados.

    $ase = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
    $walkDir = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk'
    $base = Join-Path $walkDir 'protagonista-walk-v6-bracos'
    $inputAtlas = Join-Path $walkDir 'protagonista-walk-v6-input-atlas-960x64.png'
    & $ase -b --script-param "out=$walkDir" --script-param "atlas=$inputAtlas" --script (Join-Path $walkDir 'protagonista-walk-v6-bracos.lua')
    & $ase -b ($base + '.aseprite') --sheet-type horizontal --sheet ($base + '-spritesheet.png') --data ($base + '-spritesheet.json')
    & $ase -b ($base + '-preview-esquerda.aseprite') --scale 6 --save-as ($base + '-preview-esquerda.gif')
    & $ase -b ($base + '-preview-direita.aseprite') --scale 6 --save-as ($base + '-preview-direita.gif')

Os parâmetros Lua precedem --script. As exportações Aseprite terminaram com exit 0 e stderr vazio. Os GIFs são previews de movimento, não quadros de runtime.

## Integração e hashes

O PNG e a fonte Aseprite foram copiados para assets/player/player-animations.png e assets/player/source/player-animations.aseprite. SpriteFrames manteve idle 0–5, walk 6–13 e dash 14–16, com durações existentes. O comando Godot_v4.7.2-stable_win64.exe --headless --editor --path projeto-jogos-digitais --import --quit terminou com exit 0 e stderr vazio; foi uma importação de recurso, sem gameplay ou testes.

- PNG runtime: 9c69d9f03b97db69c4b74ef735008ad6dce8a0d463c68bffed26aff15389a143
- Aseprite runtime: 75668700cd1e1a65dfa2aa4226480455db30703d7fc2d29d6057a35d70ca8a4c
- Lua V6: 79032aad4d8bb57401d3788a9afcd4b4eac1910a0e100a918eac69c310c78834
- Metadata JSON: bea0bed29fb36937205fdcbf3c6af5bd87133e0f6edf86b9ca16fad2ec53cf07
- Input congelado V6: 19d218d2630eaac25d14fd2106b5298b1102de30475cbed05903a177a933a8e9

Nenhum teste, quality audit ou gameplay foi executado. Gemini/Muse/Grok concluíram revisão estática; decisões em pareceres/bracos-v6/README.md. Opus bloqueado por quota; avaliação visual do usuário não registrada.
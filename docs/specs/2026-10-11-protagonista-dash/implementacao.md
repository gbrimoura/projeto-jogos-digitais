# Implementação — dash do protagonista

## Dash escala V5 — 13/10/2026

O principal aprovou o fator uniforme **0,85** ao comparar idle, dash anterior e
candidatos 0,90/0,85/0,80. O diagnóstico mediu apenas o envelope casco+visor,
sem antena ou bounding box dos membros: idle0 = 18×19 px, dash original =
22×24 / 22×24 / 21×23 px e média do pulo V4 corrigido = 18,9×20,6 px. A média
linear do dash, 21,7×23,7 px, indicava fator aproximado 0,87 ante o pulo; a
comparação visual levou à escolha final 0,85.

A integração usou o snapshot corrente de 28 quadros, que inclui o pulo V4
corrigido (17–24) e hurt V1 (25–27), e aplicou a transformação nearest-neighbor
com pivô comum X=32, Y=56. Alterou somente pixels nos frames 14–16. Conferências
do integrador: 25/25 frames não-dash pixel-exatos (0–13, 17–27), 28/28 tempos,
8/8 tags, atlas 1792×64, paleta de 27 cores, alpha 0/255 e dash 40/40/60 ms.
Não alterou `.tres`, `.import`, scripts ou cenas. Godot 4.7.2 executou somente
`--headless --editor --recovery-mode --path <repo> --import --quit`, com exit 0.

| Arte runtime | SHA-256 final |
|---|---|
| `assets/player/player-animations.png` | `C87E5D07A4B375378330A56AD1307DED9A8464D95FFB53F9DC09C838E7E211E6` |
| `assets/player/source/player-animations.aseprite` | `59065A95A80E8F00EA8867CC42CDB780773F4F0BB9520CD5D014ED9173B9955F` |
| `assets/player/player-animations.png.import` (inalterado) | `FEB38B6EC7B49D4BC2C050E2012A688027825B08A9564A30853E842FBB8C5815` |
| `resources/player_sprite_frames.tres` (inalterado) | `38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164` |

O snapshot de entrada com hashes e o hash baseline de 74 arquivos `.tres`,
`.gd` e `.tscn` estão em
`historico/escala-v5-current-28-frames/`. Os 74 hashes não-artísticos foram
iguais após a importação. Comparação, medidas, fonte Lua e GIF demonstrativo
estão em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-escala-v5/`.
Gemini/Muse/Grok estão revisando os arquivos congelados; Opus
`claude-opus-5-5-high` bloqueado por quota. A interface não permite confirmar
Fast/priority. Sem gameplay, testes ou quality audit.

## Dash V4 — histórico (13/10/2026)

O principal gerou a referência final e aprovou o contact antes da integração.
O gerador Lua produziu três poses editáveis 64×64, direção nativa +X, paleta
limitada às 27 cores do personagem e alpha binário. O integrador trabalhou do
snapshot `historico/pre-dash-v4/`, substituiu apenas os frames 14–16 e confirmou
preservação pixel a pixel dos outros 22 frames, dos 25 tempos e das tags.

| Frame | Pose | Duração | Bounds 64×64 | Pixels opacos | Cores |
|---:|---|---:|---|---:|---:|
| 14 | impulso | 40 ms | x=9, y=9, 52×48 | 1195 | 24 |
| 15 | avanço | 40 ms | x=10, y=14, 50×43 | 1064 | 24 |
| 16 | recuperação | 60 ms | x=11, y=11, 46×46 | 1066 | 25 |

Arte e previews congelados em
`GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/`; o README da pasta
registra reprodução, hashes e o GIF horizontal demonstrativo (16 quadros, 50 px
para cada direção, 880 ms). O atlas runtime SHA-256 é
`b2d86e34b0782d9797ac3ab43d5b7144b87f033d7d32a1a7617aaff17fdb0fd6`; a fonte
runtime Aseprite é
`40955fd03dd782aa9188b765a83f00412761657c6788ea81736873dfe506c29a`.

Godot 4.7.2 executou somente a importação de recursos com
`--headless --editor --path <repo> --import --quit`: exit 0, stderr vazio e
`.ctex` presente. Gemini/Muse/Grok concluíram a revisão estática final; Opus bloqueado por quota. Nenhum teste,
gameplay ou quality audit foi executado nesta etapa.

As seções seguintes descrevem as versões v1–v3 e permanecem como histórico;
elas não substituem o estado atual acima.

Implementação pelo GPT-6 Luna xhigh: gerador Lua, PlayerVisual, SpriteFrames e documentação. Fast/priority não selecionável nem confirmável na interface. Principal executou exportações com Aseprite1.3.18.6 (exit0), inspecionou a arte e integrou o atlas PNG e a fonte editável.

## Resultado

Três poses de dash — impulso, avanço e sustentação — em 40/40/60ms, reprodução não cíclica. Atlas de quinze quadros 64×64, total960×64. Idle v2 e walk v3 preservados. Dash tem prioridade visual no chão e no ar, reinicia uma vez na entrada, mantém a última pose enquanto ativo e retorna ao estado apropriado ao sair. Morte interrompe a reprodução; trilha, física e controles preservados. As duas salas usam a mesma cena do jogador.

## Correção de exportação

Aseprite expandia automaticamente a tag walk ao acrescentar frames. O gerador restaura os intervalos originais após append e cria dash em seguida. Export final confirmou idle0..5, walk6..11, dash12..14/repeat1. R1 preservada em historico/ e pareceres/estado-r1.json.

## Revisão e limites

Gemini, Muse e Grok concluíram R2 sem bugs concretos pendentes nas fontes. Inspeção visual principal/Luna sem clipping ou fendas evidentes, com poses legíveis. Opus claude-opus-5-5-high bloqueado por quota; nenhum parecer, obrigação ainda pendente. Não foram executados Godot, testes ou quality_audit; o implementador fez revisão estática e git diff --check. Validar aparência/cadência manualmente no jogo. Pareceres completos em pareceres/README.md.

## Prévia horizontal corrigida

O GIF original mostrava poses estacionárias. O novo protagonista-dash-horizontal-v1.gif mostra deslocamento nos dois sentidos, com 16quadros e holds nos extremos. Fonte separada criada pelo Luna; export/inspeção pelo principal. Gemini/Muse/Grok concluíram revisão estática sem bugs concretos; Opus por quota. Runtime/atlasGodot intactos. Relatórios em pareceres/preview-horizontal/README.md.

## Pose lateral v2 — 11/10/2026

GPT-6 Luna xhigh redesenhou as três poses em perfil +X, corrigiu proporções e preservou visor, peito creme/amarelo e pernas escuras. Principal exportou fonte, atlas, contato e GIF no Aseprite1.3.18.6 (exit0); inspecionou contato e integrou assets/player/player-animations.png e source/player-animations.aseprite. Atlas960x64,15quadros; tags idle0..5, walk6..11, dash12..14/repeat1 confirmadas pelo metadata. Preview16quadros, deslocamento nos dois sentidos. Nenhum teste/Godot executado. Revisão v2: Muse concluído sem bloqueios; Gemini recebido, achados avaliados e descartados por evidência de API/export. Grok timeout10min sem parecer; Opus bloqueado por quota, sem parecer. Histórico das fontes/specs anterior em historico/pose-pre-v2.

## Postura compacta v3

GPT-6 Luna xhigh alterou somente gerador Lua, defaults da prévia e README de arte. Principal exportou no Aseprite1.3.18.6 (exit0) atlas960x64, fonte combinada15quadros, contato3poses e GIFpreview16quadros880ms; integrou assets/player/player-animations.png e source/player-animations.aseprite. Metadata confirma idle0..5/walk6..11/dash12..14/repeat1 e40/40/60ms. Inspeção visual principal e Luna: postura mais baixa, cabeça/ombro ligados, sem tesoura ampla ou clipping/desconexão evidente; apoio ainda diagonal pode receber polimento estético futuro. Gemini/Muse concluíram revisão estática sem regressões concretas; Grok timeout10min sem parecer; Opus quota bloqueado no preflight, sem substituição. Fast não confirmávelinterface. Sem testes/Godot/quality_audit.

## Correção de integração: atlas sem importação

Após captura de jogador invisível, log existente confirmou No loader found para PNG e falha do SpriteFrames. Luna xhigh executou Godot --headless --editor --path projeto --import (exit0), gerando .png.import/.ctex e cache. PNGhash antes/depois idêntico; código/arte preservados. Gemini/Muse/Grok revisaram metadados sem bugs concretos; Opus quota. Registro/hashes em pareceres/correcao-importacao-atlas. Gameplay não executado; usuário deve reiniciar execução para carregar textura importada.

## Correção de orientação ao andar

Usuário confirmou sprite após importação e apontou caminhada invertida. Idle/walk nativos apontam para esquerda; dash para direita. Luna xhigh ajustou _apply_facing para considerar a direção nativa da animação e conectou animation_changed, reaplicando flip ao entrar/sair do dash mesmo sem mudança de direção. Apenas scripts/player/player_visual.gd alterado; controles/física/arte/tempos preservados. Inspeção estática e git diff --check sem erros; sem testes/Godot. Revisões em pareceres/correcao-orientacao; Opus preflight quota bloqueado.

Revisão da orientação concluída por Gemini/Muse sem achados concretos; Grok timeout2min sem parecer, Opus quota. Apenas revisão estática, sem gameplay/testes.

## Encerramento da revisão de escala V5 — 13/10/2026

Gemini, Muse e Grok concluíram a revisão estática; achados avaliados pelo principal sem correção de runtime necessária. Opus bloqueado por quota, sem parecer. [Relatórios originais, decisões e hashes](pareceres/escala-v5/README.md). Integração e importação concluídas; avaliação estética do usuário em jogo pendente.

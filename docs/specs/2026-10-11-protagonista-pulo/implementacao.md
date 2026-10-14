# Implementação — ciclo de pulo V2, runtime V3 e escala V4

A implementação V2 responde à avaliação de que os três quadros congelados da V1 não davam movimento às pernas nem peso ao salto. O principal inspecionou o contact V2 e liberou a integração. O agente manteve física, controlador, colisor, combate, input e cenas fora das alterações.

## Alterações

- **scripts/player/player_visual.gd**: toca jump_rise, jump_apex e jump_fall por tempo e muda de clipe pela velocity.y atual. O ápice usa limite visual de ±80 px/s. Os três clipes aéreos repetem seus quadros enquanto a fase não muda; o runtime só chama `play()` na troca de fase, nunca para reiniciar um clipe concluído por tick.
- **scripts/player/player_visual.gd**: só arma pouso depois de já ter observado contato válido com o chão e uma fase aérea. Ao retornar ao chão toca jump_land uma vez, por 135 ms. Dash, novo salto, morte e reset cancelam a compressão; movimentação e input continuam livres.
- **scripts/player/player.gd**: continua passando velocity.y depois de physics_step e chama reset_air_state no reset ao spawn. Nenhum valor de física ou timing de movimento foi alterado.
- **resources/player_sprite_frames.tres**: mantém idle, walk e dash com as cadências anteriores e organiza nove quadros novos em quatro clipes temporizados: subida 85 ms/quadro, ápice 45 ms/quadro, queda 85 ms/quadro e aterrissagem 45 ms/quadro.
- **assets/player/player-animations.png**: atlas horizontal de 26 quadros, 1664×64. Os quadros 0–16 foram copiados do atlas de entrada; 17–25 contêm as nove poses V2. Refinamento final de aterrissagem: land_1 baixa o torso 2 px, land_2 1 px e land_3 recupera 0 px; os braços acompanham o torso e as solas seguem fixas.
- **assets/player/source/player-animations.aseprite**: fonte editável combinada de 26 quadros.
- **GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/**: script Aseprite Lua, fonte, entrada congelada, spritesheet PNG e manifest JSON, metadata, contact 3×3, detalhe ampliado das pernas e GIFs de arco nas duas direções.
- **historico/v1/**: snapshot dos scripts, SpriteFrames, PNG/Aseprite runtime, documentos e arte V1. O diretório continua sob docs/.gdignore para não ser importado como recurso do jogo.
- A importação regenerou assets/player/player-animations.png.import com as configurações de importação existentes. Nenhum outro recurso de jogo foi alterado.

## Timing e prioridade

A física mantém gravidade 1600 px/s². A janela visual de ápice ±80 px/s ocupa aproximadamente 100 ms, cobrindo os dois quadros runtime de 45 ms. O GIF segura cada uma das poses do ápice por 110 ms somente para facilitar a inspeção; a folha e os quadros runtime não recebem esse hold. Cada GIF tem 13 quadros demonstrativos e foi exportado a 4× nearest, 256×512.

A prioridade implementada é morte > dash > ar > aterrissagem > walk/idle. O registro de contato aéreo é limpo ao reset e exige chão observado antes de poder disparar aterrissagem. Os estados de morte e dash prevalecem sobre qualquer clipe aéreo/landing. Clipes aéreos em loop não são retomados se interrompidos enquanto a fase permanece igual; a transição de fase seleciona e inicia o próximo clipe.

## Validação executada

- Aseprite 1.3.18.6: geração do atlas/contact/GIF e exportação de ambos os GIFs a 4×; processos terminaram com exit 0.
- Godot 4.7.2: comando --headless --editor --path projeto-jogos-digitais --import --quit terminou com exit 0. O log registrou Player, PlayerVisual e reimportação de player-animations.png; stderr do Godot vazio.
- O JSON da spritesheet é manifest manual escrito pelo Lua. Não foi apresentado como metadado automático do exportador.
- Nenhum teste, gameplay ou quality audit foi executado. Revisão estática da V2 e conferência visual manual no jogo permanecem pendentes.
- Nenhum commit ou push foi feito.

## Snapshot e hashes

A V1 foi copiada para historico/v1/ antes da substituição. A pasta pitch-assets mantém os arquivos V1 originais; a versão V2 usa nomes com sufixo -v2.

| Arquivo estável | SHA-256 |
|---|---|
| scripts/player/player_visual.gd | 658871cf4587a797431104b7569da5293daf7ee86286d267cdb1b1807b556620 |
| scripts/player/player.gd | 2e86fdfc1040046b53e1d7ac3dd4f3d8bebf5d9278b765e693662744676c7099 |
| resources/player_sprite_frames.tres | 34224da2f32274641b8140a8d2dce6a78fd2cef1ebfbee6e4213e25d4f9735a8 |
| assets/player/player-animations.png | d04e34d9179070c2f5298fbc7490ef50d352917c3da5df457dc28af7803264cb |
| assets/player/source/player-animations.aseprite | 515cd891dd3a1129018bb1e81cfe2d3b3fcd3bee752b4904f9c0a6445077c42a |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2.lua | 3ea76aa16a3548f9af53c6d42c3291053ea4b475c5250f91e0797e4c82309aae |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2.aseprite | 515cd891dd3a1129018bb1e81cfe2d3b3fcd3bee752b4904f9c0a6445077c42a |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-spritesheet.json | b8272620616a26454d2127c6ae1a200f9a01d74313311ec58b9f36ed24dbf1f2 |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-spritesheet.png | d04e34d9179070c2f5298fbc7490ef50d352917c3da5df457dc28af7803264cb |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-contact.png | b0fc08f52199847d6a031f06b263d7e049e8b80dbb5b7a6e8ac5e1b9505aec10 |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-legs-detail.png | 591113ad755c703acf64af3c74aa3ee7059d668720f473ee9b57db4f9e8a6dc8 |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-preview-esquerda.gif | adf7c12b38a9e36c3586dda95ef1eb0f46d28ad84ff3809632a011e8e0e6b5e2 |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-preview-direita.gif | da2a3f3d56265d2c33ff339760e3745926f93b6152d259f17184ad1e6b46a188 |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-metadata.json | afd55cb411bdd1c6a0f016ef5b123365ceb7afad1ada7ee204d84eab18341574 |
| GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-input-atlas-1280x64.png | 73b4036c20934b9a3d3e7b9cd41ec7e4da4c92e2d4586c1710418fcf556af001 |
| assets/player/player-animations.png.import | feb38b6ec7b49d4bc2c050e2012a688027825b08a9564a30853e842fbb8c5815 |

O estado atual foi congelado após a importação de recursos. A revisão do principal e de revisores externos ocorre sobre esses arquivos estáveis.



## Pareceres finais V2

Gemini, Muse e Grok concluíram revisão estática delimitada sem achados reais no escopo. Opus claude-opus-5-5-high bloqueado por quota no preflight; sem parecer. Resultados originais, hashes e decisões em pareceres/v2/README.md. Nenhuma fonte ou imagem alterada após os pareceres. Importação final sem erros; nenhum teste/gameplay. Avaliação visual da sensação de peso pendente.

## Reprodução da prancha em Aseprite — 11/10/2026

O usuário rejeitou a direção artística V2 por falta de mobilidade e peso e pediu reproduzir a prancha de oito poses. A reprodução foi extraída da imagem com Aseprite 1.3.18.6 Lua: flood-fill do navy conectado às bordas internas, exclusão das linhas de chão, recortes delimitados e nearest 1:7, mantendo as proporções relativas. A saída 64×64 usa a paleta do protagonista de 27 cores e alpha binário. O principal aceitou o contact comparativo para esta etapa; isso não representa aprovação final do usuário. Os pareceres estáticos V2 cobrem código e não aprovação estética.

- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/referencia-pulo-poses-v1.png`: prancha original, preservada sem alteração.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/protagonista-pulo-v3-referencia-v2-estudo-mascaras.aseprite`: documento editável 1536×1024 com a referência e oito layers de máscaras.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/protagonista-pulo-v3-referencia-v2-poses-64px.aseprite`: oito frames editáveis a 64×64.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/protagonista-pulo-v3-referencia-v2-poses-64px.png`: sheet horizontal 512×64.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/protagonista-pulo-v3-referencia-v2-contact-comparativo-4x.png`: recortes da referência e resultados limpos lado a lado, ampliação nearest 4×.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/protagonista-pulo-v3-referencia-v2-animacao-4x.gif`: sequência de oito poses a 256×256; a composição fica parada, sem arco ou deslocamento demonstrativo.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/protagonista-pulo-v3-referencia-v2-manifest.json`: poses, bounds, escala e arquivos gerados.
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/extrair-referencia-v2.lua`: fonte Aseprite da extração. A geração Lua e a exportação GIF terminaram com exit 0.

Esta entrega é somente arte-fonte para revisão: nenhum script, SpriteFrames ou atlas do runtime foi alterado, e nenhum import Godot, teste, gameplay ou quality audit foi executado. V2 continua no runtime até uma tarefa posterior autorizada; a arte V2 e o draft V3 autoral rejeitado permanecem preservados, sem apagar históricos.

## Correções da reprodução

Os pareceres iniciais detectaram desalinhamento no contact, pixels da moldura nas máscaras e corte de pixels de bota. O Luna gerou arquivos separados com sufixo referencia-v2, preservando a reprodução inicial. Corrigiu clamp interior x=18..365, recuperação até y=385 observado na imagem, remoção de chão por pixel/cor e mappedYAnchor compartilhado nos dois lados do contact. O principal inspecionou o comparativo final. Exports Aseprite concluíram com exit 0; sheet 512×64 e GIF 256×256, oito quadros. Sem alteração Godot.

Pareceres e decisões: [reprodução V3](pareceres/reproducao-v3/README.md).
## Integração V3 — resultado de 12/10/2026

Substituí as nove poses runtime da V2 pelas oito poses aprovadas da reprodução de referência. A geração usa Aseprite Lua real e o snapshot V2 como entrada, verificando correspondência pixel a pixel entre a fonte Aseprite e seu PNG. O atlas final mede 1600×64, 25 quadros. Os primeiros 17 quadros e cadências permanecem preservados.

resources/player_sprite_frames.tres organiza jump_rise (110/95/110 ms, não-loop e mantém o último quadro), jump_apex (uma pose mantida), jump_fall (uma pose mantida) e jump_land (3×45 ms, não-loop, 135 ms). scripts/player/player_visual.gd não mudou: seleção por velocidade, prioridade e reset já atendiam aos requisitos. scripts/player/player.gd, física, movimento, colisor, combate, input e cenas não foram alterados por esta integração.

Registro de contato medido: sola idle em y=56; offset inteiro comum de Y=-5 nas oito poses. A compressão recebe +1 px de compensação exclusiva, net Y=-4, sem alterar sua composição. Direção nativa do jump é esquerda. Aseprite produziu fonte editável com tags, sheet PNG, contact 3×3 nearest 4× e metadata de bounds/base/timings/direção. A importação de recursos pelo Godot 4.7.2 --headless --editor --import --quit terminou com exit 0, sem saída de erro.

Nenhum teste, gameplay ou quality audit foi executado. Gemini, Muse e Grok concluíram a revisão estática desta integração sem defeitos concretos; Opus bloqueado por quota; a avaliação estética em runtime pelo usuário permanece pendente. V2 e os documentos vigentes antes da substituição foram copiados para historico/v2-pre-v3/; hashes e arquivos snapshot estão registrados no README dessa pasta. Nenhum commit ou push foi feito.

Pareceres integrais e decisão do principal: [integração Godot V3](pareceres/integracao-godot-v3/README.md).

## Correção de escala runtime V4 — 13/10/2026

**Aprovação visual:** o principal aprovou a contact sheet de 8 poses em três colunas (idle0, pose atual e pose em escala corrigida), ampliada 4×, antes da integração. O capacete ficou compatível com o idle considerando a inclinação das poses; as articulações, poses comprimidas/estendidas e contato das solas ficaram preservados.

**Arte/runtime:** a fonte foi o snapshot imutável do atlas atual de 28 quadros, 64×64 por quadro (1792×64), e não a antiga base de 25 quadros. A escala nearest-neighbor uniforme 0,85 foi aplicada somente nos frames 17–24. Frames 0–16 e 25–27 (incluindo hurt) estão pixel-exatos: 20/20 frames protegidos. Timings 28/28 e tags 8/8 foram validados por Lua Aseprite. O `.tres`, scripts, cenas e `.import` permaneceram inalterados. A paleta mantém 27 cores e alpha binário. Os pivots são X=32, Y=56 para 17 e 22–24 e Y=32 para 18–21.

**Importação:** Godot 4.7.2 recovery mode com `--headless --editor --recovery-mode --path <repo> --import --quit` concluiu com exit 0, reimportando `player-animations.png`. Não houve execução de testes, gameplay ou quality audit. Revisões estáticas Gemini/Muse/Grok foram solicitadas sobre a arte e fontes congeladas; os resultados ficam no [índice de pareceres da escala V4](pareceres/escala-v4/README.md). Opus 5.5 High não ficou disponível no preflight por quota.

| Arquivo | SHA-256 |
|---|---|
| `assets/player/player-animations.png` | `F03E8E500767603A29A3F2820B66D86ADF16CDE00DA1E94189768E16E4EA24C6` |
| `assets/player/source/player-animations.aseprite` | `B6987828456B17EACE9A66641ABC993C2E47849DBC560EFFBEF579C8B10B82CE` |
| `resources/player_sprite_frames.tres` (inalterado) | `38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164` |
| `scripts/player/player.gd` (inalterado) | `5C0EB27CA07F933DB71A3AA5A4B0368AA6C293C5B0810F488D715CFA6D344951` |
| `scripts/player/player_visual.gd` (inalterado) | `278B897A0CA12CAE987725B0FC25C609536E8D31B0CE747EC5F785FC6745153F` |
| `scripts/player/player_health.gd` (inalterado) | `1127F2E826C2DCFB04C6D9AD121B3802FA9504428FD4D3E6F6D727B299B8EE8E` |
| `scenes/player.tscn` (inalterado) | `A98540A71C4309C32136E39D3179F21A52E5463D88254B19BCBEA1BA8700B45E` |

Arte aprovada, Lua de geração/integração, folha PNG, contact e GIF 4× estão em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-escala-v4/`, fora do repositório. O snapshot original completo está em `historico/escala-v4-current-28-frames/runtime/`.

## Encerramento da revisão de escala V4 — 13/10/2026

Gemini, Muse e Grok concluíram revisão estática sem correções obrigatórias. Opus bloqueado por quota. [Pareceres originais, decisões e hashes](pareceres/escala-v4/README.md). Arte aprovada pelo principal e integrada/importada; avaliação estética do usuário no jogo pendente.

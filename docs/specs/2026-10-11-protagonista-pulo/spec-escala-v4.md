# Especificação — correção de escala do pulo V4

**Estado:** integrado e importado após aprovação visual do principal; revisão estática Gemini/Muse/Grok concluída sem correções obrigatórias. A inspeção manual do usuário no jogo permanece pendente.

## Base congelada

A base usada é o runtime atual de 28 quadros, não um snapshot antigo de 25 quadros: frames de 64×64, atlas horizontal de 1792×64, source Aseprite 28 frames. A cópia imutável está em `historico/escala-v4-current-28-frames/` e contém PNG, Aseprite, `.import` e `resources/player_sprite_frames.tres`.

Hashes SHA-256 antes da edição:

| Arquivo | SHA-256 |
|---|---|
| `assets/player/player-animations.png` | `FF8EDE966AB19A3395CAD1EA7B28E3B5920D7042736ED0D4EB965EF3FFF69FDA` |
| `assets/player/source/player-animations.aseprite` | `FAAD4270FC0A8B8CA08D2662BF1EB64FE84195BAF5483E3F5E9B11212A5DEBB3` |
| `assets/player/player-animations.png.import` | `FEB38B6EC7B49D4BC2C050E2012A688027825B08A9564A30853E842FBB8C5815` |
| `resources/player_sprite_frames.tres` | `38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164` |

Os frames 0–16 são idle, walk e dash V4; 17–24 são as oito poses atuais de pulo; 25–27 são hurt V1. O `.tres` mantém rise 110/95/110 ms, apex 45 ms, fall 85 ms, land 45/45/45 ms e hurt 80/80/100 ms. Tags correspondentes estão no Aseprite congelado; toda a cadência, tag e arte fora de 17–24 deve permanecer intacta.

## Diagnóstico de escala

A medição foi feita por Lua no Aseprite 1.3.18.6 diretamente sobre o `.aseprite` congelado. Para isolar a cabeça, medi o maior componente 8-conectado das cores creme do casco (`#CFC3B7`, `#F5E9D8`, `#F6ECDD`, `#FFFCF0`) e ampliei o envelope em 2 px para incluir visor e contorno. Inclinações da cabeça fazem a medida variar; por isso os valores servem para escolher um fator único, sem ajustar cada pose.

| Frame runtime | Pose | Envelope casco+visor | Fator contra idle em largura×altura (indicativo) |
|---:|---|---:|---:|
| 0 | idle de referência | 17×18 | 1,00×1,00 |
| 17 | impulso | 24×24 | 0,71×0,75 |
| 18 | subida | 21×20 | 0,81×0,90 |
| 19 | recolhimento | 21×25 | 0,81×0,72 |
| 20 | ápice | 20×19 | 0,85×0,95 |
| 21 | queda | 22×21 | 0,77×0,86 |
| 22 | contato | 22×22 | 0,77×0,82 |
| 23 | compressão | 21×23 | 0,81×0,78 |
| 24 | recuperação | 19×20 | 0,89×0,90 |

A média dos envelopes de pulo é aproximadamente 21,3×21,8 px contra 17×18 px no idle; o fator uniforme que equalizaria as duas dimensões fica perto de 0,81. Os bounds totais, por sua vez, variam de 26 a 46 px de largura e de 35 a 54 px de altura porque joelhos, botas e braços mudam de abertura; não são usados como medida de escala. A inspeção do núcleo do torso fica próxima ao idle, em torno de 13–14×13 px, o que confirma que membros estendidos distorcem a impressão do tamanho total.

## Transformação proposta

- Aplicar fator **0,85** igual a todos os oito frames 17–24, com amostragem nearest-neighbor e cópia direta dos pixels da paleta atual. A escolha arredonda o fator de equivalência (~0,81) para preservar peso, mobilidade e legibilidade após a redução pixelar.
- Manter todos os desenhos, expressão e anatomia; nenhum redesenho, auto-fit, escala por quadro ou alteração de timing.
- Usar centro horizontal X=32. No frame de impulso 17 e nos três quadros de pouso 22–24, manter o contato das solas no eixo Y=56. Nos frames aéreos 18–21, usar centro vertical Y=32.
- Permanecer em 64×64 por frame, paleta existente de 27 cores e alpha binário 0/255.

## Critérios de aceite e limite de integração

1. A prévia compara idle0, original e resultado redimensionado no mesmo contact 4×, em grade, para cada uma das oito poses; incluir também GIF demonstrativo 4×.
2. O principal aprova visualmente a escala antes de qualquer alteração nos arquivos runtime.
3. Depois da aprovação, alterar somente pixels 17–24 de `assets/player/player-animations.png` e `assets/player/source/player-animations.aseprite`. Preservar pixel a pixel 0–16 e 25–27; validar os 28 tempos/tags e a permanência do `.tres`.
4. Importar somente os recursos pelo editor Godot 4.7.2 em recovery mode (`--headless --editor --recovery-mode --path <repo> --import --quit`). Não executar jogo, testes ou quality audit.
5. Não alterar scripts, física, input, SpriteFrames, cenas ou addons.

## Resultado da integração — 13/10/2026

O principal aprovou o contact old/new em ampliação 4× antes de integrar. A comparação mostrou o capacete compatível com o idle, levando em conta a inclinação entre poses; as poses comprimidas e estendidas mantêm a articulação e o peso, com solas apoiadas nos quadros de contato. A equipe escolheu o fator uniforme 0,85 já especificado e não redesenhou anatomia, expressão ou timing.

A integração foi gerada pelo Aseprite Lua a partir do snapshot imutável de 28 frames, não do antigo atlas de 25 frames. Foram substituídos somente os pixels 17–24: 20/20 frames protegidos (0–16 e 25–27, incluindo hurt) ficaram pixel-exatos; 28/28 durações e 8/8 tags foram preservadas; o atlas continua 1792×64 e o SpriteFrames `.tres` não foi editado. A paleta final usa as 27 cores existentes e alfa binário 0/255. A importação de recursos no Godot 4.7.2 em recovery mode terminou com exit 0.

| Arquivo | SHA-256 após integração |
|---|---|
| `assets/player/player-animations.png` | `F03E8E500767603A29A3F2820B66D86ADF16CDE00DA1E94189768E16E4EA24C6` |
| `assets/player/source/player-animations.aseprite` | `B6987828456B17EACE9A66641ABC993C2E47849DBC560EFFBEF579C8B10B82CE` |
| `assets/player/player-animations.png.import` (inalterado) | `FEB38B6EC7B49D4BC2C050E2012A688027825B08A9564A30853E842FBB8C5815` |
| `resources/player_sprite_frames.tres` (inalterado) | `38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164` |
| `scripts/player/player.gd` (inalterado) | `5C0EB27CA07F933DB71A3AA5A4B0368AA6C293C5B0810F488D715CFA6D344951` |
| `scripts/player/player_visual.gd` (inalterado) | `278B897A0CA12CAE987725B0FC25C609536E8D31B0CE747EC5F785FC6745153F` |
| `scripts/player/player_health.gd` (inalterado) | `1127F2E826C2DCFB04C6D9AD121B3802FA9504428FD4D3E6F6D727B299B8EE8E` |
| `scenes/player.tscn` (inalterado) | `A98540A71C4309C32136E39D3179F21A52E5463D88254B19BCBEA1BA8700B45E` |

Arte de comparação e fontes reproduzíveis: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-escala-v4/` (fora do repositório). O contact aprovado, o GIF 4×, a folha 8×64×64 e os Lua de geração/integração permanecem congelados para revisão estática. Os três revisores foram acionados; seus resultados serão registrados em `pareceres/escala-v4/` sem alterar as fontes congeladas. Nenhum teste, gameplay ou quality audit foi executado; a revisão Opus 5.5 High não ficou disponível no preflight por quota.

## Encerramento da revisão de escala V4 — 13/10/2026

Gemini, Muse e Grok concluíram revisão estática sem correções obrigatórias. Opus bloqueado por quota. [Pareceres originais, decisões e hashes](pareceres/escala-v4/README.md). Arte aprovada pelo principal e integrada/importada; avaliação estética do usuário no jogo pendente.

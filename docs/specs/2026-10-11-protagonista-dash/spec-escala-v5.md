# Correção de escala do dash V5

**Estado:** contact e fator 0,85 aprovados visualmente pelo principal em 13/10/2026; integração feita a partir do snapshot de 28 quadros e importada em Godot 4.7.2 recovery mode (exit 0). Revisões estáticas por Gemini/Muse/Grok foram concluídas e avaliadas pelo principal; preflight Opus bloqueado por quota.

## Objetivo e limites

Reduzir moderadamente o volume do protagonista nas três poses de dash, preservando a postura lateral +X do V4. A alteração é uma transformação uniforme nearest-neighbor dos quadros 14–16; não redesenha partes, não ajusta cada pose de forma independente e não desloca o personagem na física.

A base é o snapshot atual de 28 quadros (atlas 1792×64), que já contém o pulo com escala V4 corrigida nos quadros 17–24 e hurt V1 nos quadros 25–27. O snapshot pré-V4 de 25 quadros não é usado. Arquivos e hashes de entrada estão em historico/escala-v5-current-28-frames/runtime/.

## Diagnóstico de escala

Medição feita com Aseprite 1.3.18.6 sobre o arquivo Aseprite atual antes da integração. Para excluir a antena, identifica-se o maior componente 8-conectado das cores creme do casco (#CFC3B7, #F5E9D8, #F6ECDD, #FFFCF0) e expande-se seu envelope em 2 px para incluir visor e contorno. O bounding box dos membros não participa da escolha.

| Frame runtime | Pose | Envelope casco + visor |
|---:|---|---:|
| 0 | idle de referência | 18×19 px |
| 14 | impulso | 22×24 px |
| 15 | avanço | 22×24 px |
| 16 | recuperação | 21×23 px |
| 17–24 | pulo V4 atual, média | 18,9×20,6 px |

A média do dash original é 21,7×23,7 px. Comparada ao pulo já corrigido, a equivalência linear é aproximadamente 0,87. O principal aprovou o fator uniforme 0,85: após o arredondamento de pixels, ele deixa o casco lateral próximo ao volume de idle/pulo e conserva a leitura de perfil, visor, ombros e anatomia compacta. O contact aprovado apresenta idle, original e candidatos 0,90/0,85/0,80 para cada pose.

## Transformação aprovada

- Aplicar escala uniforme **0,85** aos três quadros 14–16, usando amostragem nearest-neighbor e os pixels da paleta atual.
- Pivô comum: **X=32, Y=56**, preservando o registro de apoio das solas. Nenhum ajuste por quadro.
- Canvas continua 64×64 por pose; direção nativa continua +X e o espelhamento existente continua controlando o sentido oposto.
- Preservar timings 40/40/60 ms, duração total de 140 ms e animação não cíclica.
- Preservar a paleta de 27 cores e alpha binário 0/255.

## Critérios de integração

1. Usar exclusivamente o snapshot corrente historico/escala-v5-current-28-frames/runtime/ como entrada.
2. Substituir pixels dos quadros 14–16 em assets/player/player-animations.png e assets/player/source/player-animations.aseprite; manter 25 quadros não-dash (0–13 e 17–27) pixel-exatos.
3. Preservar os 28 timings e 8 tags. Não alterar .tres, scripts, cenas, física, controles, combate, addons, .import ou outros recursos.
4. Criar fonte Aseprite e previews em GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-escala-v5/. O GIF demonstrativo horizontal usa ambas as direções e a mesma ordem temporal de poses 1,1,2,2,3,3,3; apenas a demonstração translada a raiz.
5. Após integração, executar somente a importação de recursos pelo Godot 4.7.2 em recovery mode (--headless --editor --recovery-mode --path <repo> --import --quit). Sem jogo, testes ou quality audit.

Aprovação visual do contact registrada antes da integração. Gemini, Muse e Grok
estão revisando os arquivos congelados; a avaliação de aparência em gameplay
continua pendente.

## Resultado integrado

O integrador Aseprite confirmou 25/25 frames não-dash pixel-exatos (0–13 e
17–27), 28/28 durações, 8/8 tags, canvas 1792×64, 27 cores e alpha 0/255.
Somente pixels dos frames 14–16 foram substituídos. O recurso `.tres`, o arquivo
`.import`, scripts e cenas não foram alterados. O baseline de 74 arquivos
`.tres`, `.gd` e `.tscn` continuou idêntico após a importação.

Godot 4.7.2 foi executado somente para importar os recursos, usando
`--headless --editor --recovery-mode --path <repo> --import --quit`; exit 0.
Não houve execução do jogo, gameplay, testes ou quality audit.

| Arquivo | SHA-256 final |
|---|---|
| `assets/player/player-animations.png` | `C87E5D07A4B375378330A56AD1307DED9A8464D95FFB53F9DC09C838E7E211E6` |
| `assets/player/source/player-animations.aseprite` | `59065A95A80E8F00EA8867CC42CDB780773F4F0BB9520CD5D014ED9173B9955F` |
| Snapshot corrente `player-animations.png` | `F03E8E500767603A29A3F2820B66D86ADF16CDE00DA1E94189768E16E4EA24C6` |
| Snapshot corrente `player-animations.aseprite` | `B6987828456B17EACE9A66641ABC993C2E47849DBC560EFFBEF579C8B10B82CE` |
| `resources/player_sprite_frames.tres` (inalterado) | `38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164` |
| `assets/player/player-animations.png.import` (inalterado) | `FEB38B6EC7B49D4BC2C050E2012A688027825B08A9564A30853E842FBB8C5815` |

Os previews, a fonte de geração e as medições estão em
`GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-escala-v5/`. A escala V5
passa a ser a arte runtime atual; a referência V4 continua preservada como
histórico. A inspeção visual em gameplay ainda depende de execução manual.

## Encerramento da revisão de escala V5 — 13/10/2026

Gemini, Muse e Grok concluíram a revisão estática; achados avaliados pelo principal sem correção de runtime necessária. Opus bloqueado por quota, sem parecer. [Relatórios originais, decisões e hashes](pareceres/escala-v5/README.md). Integração e importação concluídas; avaliação estética do usuário em jogo pendente.

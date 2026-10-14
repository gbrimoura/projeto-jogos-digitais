# Animação dash do protagonista — plano

**Estado atual (13/10/2026):** escala V5 integrada nos quadros 14–16 do atlas
atual de 28 quadros (1792×64) e importada pelo editor Godot 4.7.2 em recovery
mode (exit 0). O fator uniforme 0,85 foi aprovado antes da integração. Os 25
quadros não-dash, 28 durações e 8 tags foram preservados; nenhuma física, input,
combate ou lógica de jogo foi alterada. Gemini/Muse/Grok estão revisando os
arquivos congelados; Opus bloqueado por quota. Nenhum gameplay, teste ou quality
audit foi executado. As seções v1–v4 abaixo são históricas.

## Incremento V5: correção moderada de escala — 13/10/2026

O principal aprovou a comparação de idle, dash anterior e candidatos 0,90/0,85/
0,80, escolhendo 0,85 para reduzir o volume do casco/visor sem redesenhar as
poses laterais +X. A transformação nearest-neighbor uniforme usa pivô comum
X=32, Y=56 e mantém a postura, a orientação, a paleta e os timings 40/40/60 ms.

A integração foi feita a partir do snapshot corrente de 28 quadros, que já
incluía o pulo com escala corrigida V4 em 17–24 e o hurt V1 em 25–27. Somente os
pixels dos quadros 14–16 mudaram; os 25 quadros não-dash permaneceram pixel a
pixel, assim como 28/28 durações e 8/8 tags. O recurso `.tres`, `.import`, scripts
e cenas não mudaram. Godot 4.7.2 executou apenas a importação em recovery mode
(`--headless --editor --recovery-mode --path <repo> --import --quit`, exit 0).

O diagnóstico, hashes, snapshot imutável, comparação visual, fontes e limites
estão em [spec-escala-v5.md](spec-escala-v5.md), no registro de
[implementação](implementacao.md#dash-escala-v5--13-10-2026) e nos previews
`GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-escala-v5/`. As revisões
estáticas foram concluídas e avaliadas pelo principal. Aparência em gameplay continua pendente.

## Objetivo original (v1; histórico)

Adicionar uma animação visual de dash em três poses, mantendo intactos o idle v2,
a caminhada v3 e a mecânica de dash já aprovada com duração de 0,14 s.

## Escopo

- Criar uma fonte Lua Aseprite que abra `protagonista-walk-v3.aseprite`, preserve
  seus doze quadros e acrescente três quadros de dash editáveis.
- Definir as poses de impulso, avanço e sustentação, com inclinação para +X,
  braços recolhidos para trás e pernas flexionadas conectadas ao quadril.
- Exportar no Aseprite, pelo agente principal, um atlas horizontal de quinze
  quadros 64×64 e copiar fonte/editável e PNG para os assets de runtime.
- Adicionar a animação `dash` ao recurso `SpriteFrames` com 40, 40 e 60 ms e
  reprodução não cíclica.
- Integrar a prioridade de apresentação em `PlayerVisual`: morte, dash, pose
  estática no ar e caminhada/idle no chão.
- Reiniciar o dash somente na transição de entrada; manter a última pose se o
  estado de dash durar além dos 0,14 s, e voltar imediatamente ao estado visual
  apropriado ao terminar.
- Registrar decisões e pendências sem alterar física, controlador, duração,
  input, combate, raquete ou animações idle/walk.

## Critérios de aceite

1. Os seis frames de idle e seis de caminhada do arquivo v3 de origem permanecem
   pixel a pixel e com as durações já aprovadas.
2. Os três frames novos ocupam os índices 12–14, têm 64×64 px e durações
   40/40/60 ms, totalizando 0,14 s.
3. As poses mantêm a identidade e as cores do protagonista, usam somente a
   paleta de 27 cores com alpha binário, não sofrem clipping e têm silhueta de
   corrida/dash legível.
4. `SpriteFrames` contém as regiões do atlas em x=768, 832 e 896, com `dash`
   não cíclico e velocidade base 1 fps.
5. `PlayerVisual` reinicia o quadro 0 uma vez ao iniciar dash; atualizações de
   chão/caminhada não reiniciam a animação já ativa ou concluída.
6. Ao terminar o dash, volta imediatamente à pose estática no ar ou à caminhada/
   idle no chão. Morte e reset param o dash e a trilha existente continua intacta.
7. Nenhuma física, cena, mecânica de dash, duração ou código fora da apresentação
   visual é alterado.

## Arquivos previstos

- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash/protagonista-dash.lua`
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash/README.md`
- `scripts/player/player_visual.gd`
- `resources/player_sprite_frames.tres`
- Esta pasta de especificação e o índice `docs/README.md`.

## Limites e validação

O agente principal executa a exportação do PNG e do Aseprite e registra os
pareceres. A integração descrita é estática. Não estão previstos testes, execução
do Godot ou `quality_audit`; a conferência de cadência e aparência no jogo fica
pendente de inspeção manual.

## Incremento v2: pose de movimento lateral

Pedido: durante o dash, o robô deve ficar de perfil, em postura de impulso lateral. Implementador Luna xhigh redesenha somente os três quadros de dash; preserva idle/walk, atlas64x64 por frame, paleta27 e timings40/40/60ms. Principal exporta e integra Aseprite/PNG, atualiza o GIF demonstrativo e conduz revisões de fontes estáveis por Gemini/Muse/Grok. Opus obrigatório teve preflight bloqueado por quota. Sem execução de testes/Godot. Pareceres e hashes em pareceres/pose-lateral-v2.

## Incremento v3: dash baixo e compacto

Corrigir leitura de corrida/lunge identificada pelo usuário e análise visual. Cabeça/peito baixos, braços recolhidos, pernas compactas atrás, pose sustentada durante os140ms. Luna xhigh implementa somente Lua/README; principal exporta/integra/vê contato, Luna faz análise visual read-only, Gemini/Muse/Grok revisam fonte congelada, Opus preflight obrigatório. Estado em pareceres/pose-compacta-v3.

## Incremento v4: nova referência lateral — 13/10/2026

A referência final gerada (`referencia-dash-v4-v2.png`) orienta três poses
laterais +X: impulso baixo, avanço curto e linear, e recuperação que continua
inclinada. O principal aceitou o contact de três poses e a comparação com idle
e dash anterior antes da integração. A fonte editável standalone, o gerador, o
integrador, metadata e previews estão preservados em
`GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/`.

Integração feita exclusivamente a partir do snapshot imutável
`historico/pre-dash-v4/`: substituídos os frames 14–16; frames 0–13 e 17–24
continuam pixel a pixel idênticos, assim como os 25 tempos e todas as tags.
Cadência 40/40/60 ms, total 140 ms, não-loop. O editor Godot 4.7.2 importou o
atlas em modo headless com exit 0 e stderr vazio. Não houve gameplay, testes ou
quality audit. A especificação completa, limites por quadro, hashes e estado das
revisões ficam em [spec-v4-referencia.md](spec-v4-referencia.md) e
[implementacao.md](implementacao.md#dash-v4--13-10-2026).

## Encerramento da revisão de escala V5 — 13/10/2026

Gemini, Muse e Grok concluíram a revisão estática; achados avaliados pelo principal sem correção de runtime necessária. Opus bloqueado por quota, sem parecer. [Relatórios originais, decisões e hashes](pareceres/escala-v5/README.md). Integração e importação concluídas; avaliação estética do usuário em jogo pendente.

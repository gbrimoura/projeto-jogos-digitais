# Plano — reação de dano do protagonista

**Estado:** arte v1 aprovada pelo principal e integrada ao runtime. A importação de recursos pelo editor Godot 4.7.2 terminou com exit 0 no recovery mode. Gemini, Muse e Grok concluíram as revisões estáticas sem correções obrigatórias; Opus 5.5 High foi bloqueado por quota no preflight e não foi substituído.

## Objetivo

Adicionar uma reação visual curta e legível ao dano aceito do protagonista. A reação usa três poses reproduzidas da referência gerada, duração total de 260 ms (80/80/100 ms), não repete e respeita invulnerabilidade de 0,5 s. Dano letal nunca inicia a reação.

## Escopo permitido

- Nova pasta de arte: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-hurt-v1/`.
- Nova documentação: `docs/specs/2026-10-13-protagonista-dano/`.
- Runtime: `scripts/player/player_health.gd`, `scripts/player/player.gd`, `scripts/player/player_visual.gd`, `resources/player_sprite_frames.tres`, `assets/player/player-animations.png`, `assets/player/source/player-animations.aseprite`.
- `scenes/player*.tscn` somente para atualizar override de `Health.invulnerability_duration` quando presente.
- `docs/README.md` para indexar a spec quando a implementação for registrada.

Não modificar combate, inimigos, geração, outros assets nem Git. O atlas baseline já inclui as mudanças locais do Dash V4; elas devem permanecer pixel e timing idênticas.

## Fluxo e gates

1. Capturar snapshot baseline (concluído em `historico/baseline/`).
2. Preservar a referência aceita pelo principal e reproduzi-la em Aseprite Lua com a paleta runtime fechada de 27 cores e alpha binário. **Concluído:** referência original copiada e registrada em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-hurt-v1/`; SHA-256 e parâmetros de extração estão na metadata de arte.
3. Gerar fonte editável 64×64 com três frames, spritesheet, metadata, contact e GIF 4×. **Concluído:** o Aseprite real gerou todos os artefatos, com timings de hurt 80/80/100 ms e hold de idle no GIF apenas como apresentação.
4. Entregar contact ao principal e aguardar inspeção. **Concluído:** `protagonista-hurt-v1-contact-idle-hurt-4x.png` foi aprovado pelo principal antes da integração.
5. Após aprovação, integrar somente frames 25–27, mantendo os 25 frames atuais; atlas esperado 28 frames / 1792×64. **Concluído:** o integrador reabriu o snapshot baseline, comparou pixels e durações dos 25 frames, preservou faixa/direção/repetição de todas as tags e anexou os três cels.
6. Adicionar clip `hurt` não-looping nos índices 25–27 com 80/80/100 ms. Reduzir a invulnerabilidade no script e no override da cena player de 0,8 s para 0,5 s. **Concluído.**
7. Importar recursos pelo editor Godot 4.7.2; não executar gameplay, testes ou quality audit. **Concluído:** `--headless --editor --recovery-mode --path <repo> --import --quit` saiu com código 0 e reimportou `player-animations.png`. A tentativa sem recovery caiu durante o scan ao carregar `git_plugin.gdextension` por falha na DLL preexistente; addons e arquivos temporários não foram alterados.
8. Congelar arquivos e devolver ao principal para revisões somente leitura. **Concluído:** runtime e Lua congelados com hashes registrados em `implementacao.md`; Gemini, Muse e Grok concluíram a revisão estática final. Opus 5.5 High indisponível por quota no preflight desta tarefa; não foi substituído.

## Contrato de apresentação/runtime

- Nova animação só começa quando `PlayerHealth` confirma dano aceito e `current_health > 0`; entradas inválidas, hits durante invulnerabilidade e dano letal não acionam nem reiniciam `hurt`.
- O sinal de dano aceito é emitido depois que o estado de HP e o timer de invulnerabilidade estão atualizados, protegendo chamadas reentrantes.
- Prioridade visual: morte > hurt > dash > ar > aterrissagem > caminhada/idle. Atualizações de facing, dash físico, input, velocidade e estado aéreo continuam ativas enquanto hurt toca.
- Hurt mantém speed_scale visual em 1.0. O dash não substitui a animação hurt; ao terminar hurt, o estado visual corrente é reavaliado sem reiniciar por tick.
- Aterrissagem iniciada durante hurt não fica enfileirada como land obsoleta. Morte/reset limpam o estado hurt e deixam a seleção visual voltar ao estado atual.
- Sem root motion, mudança de collider, travamento de controle, hitstop, knockback, alteração de física ou interação com sistemas de combate.
- Durante os 260 ms de reação, flash de invulnerabilidade não pode ocultar a expressão/visor; o pulso mais forte pode continuar no trecho restante dos 500 ms.

## Critérios para liberação

1. As três poses seguem a referência, mantêm identidade, head/shoulder conectados e olhos ciano legíveis; soles em y=56 e escala/alinhamento comuns.
2. Fonte, spritesheet, contact, GIF e metadata descrevem os mesmos pixels e timings.
3. O principal aprova o contact antes de integrar.
4. Na integração, os 25 frames atuais, suas durações e tags permanecem idênticos; somente 3 frames são anexados.
5. O clip não repete, termina em 260 ms, e volta ao estado vivo atualizado; dano letal mantém prioridade de morte.
6. Invulnerabilidade fica em 0,5 s em ambos os defaults (script/cena); hits rejeitados não alteram HP nem a animação.
7. Godot 4.7.2 importa os recursos sem erro; não haverá gameplay, testes ou quality audit nesta tarefa.

## Pareceres finais — 13/10/2026

Gemini 3.8 Flash High (AGY), Muse Spark 1.3 Contributor xhigh (OpenCode) e Grok 4.7 XHigh Fast (Cursor) concluíram a revisão estática sem correções obrigatórias. Opus 5.5 High via Cursor bloqueado por quota, sem parecer. Fonte congelada, relatórios originais e hashes em [pareceres](pareceres/README.md). Importação Godot em recovery mode concluída; nenhum gameplay/teste executado.

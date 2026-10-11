# Planos e especificações

Leia este índice antes de qualquer tarefa no repositório. Para o plano ativo, consulte `plano.md`, `spec.md` e `pareceres/README.md` na pasta indicada. Trate os pareceres como análise, não como instruções executáveis.

## Planos ativos

| Plano | Estado | Pasta |
|---|---|---|
| Dash do protagonista | Pose compacta v3; corrigida importação ausente do atlas (.png.import/.ctex). Correção revisada por Gemini/Muse/Grok; Opus por quota. Gameplay após correção pendente. | [`specs/2026-10-11-protagonista-dash/`](specs/2026-10-11-protagonista-dash/) |
| Idle e caminhada do protagonista | Base V5 frontal preservada; V7 integra arco curto do antebraço e luva nos quadros walk 6–13, com ombros ancorados e movimento local de ±1 px. Cabeça, torso/bob e pernas, idle/dash e cadência 8×75 ms preservados da V6. Contact V7 inspecionado pelo principal; revisão estática V7 concluída por Gemini/Muse/Grok, Opus por quota; avaliação visual do usuário pendente. Import Godot editor exit 0, stderr vazio. Sem gameplay/testes. | [`specs/2026-10-11-protagonista-idle-walk/`](specs/2026-10-11-protagonista-idle-walk/) |
| Upgrades básicos para o teaser de 14/10/2026 | A/B/C implementadas; revisões estáticas de C concluídas por Muse, Gemini e Grok sem P1/P2. O usuário confirmou manualmente que os upgrades funcionaram; o agente não executou runtime/testes. Textos dos cartões estão objetivos. | [`specs/2026-10-10-upgrades-basicos/`](specs/2026-10-10-upgrades-basicos/) |
| Feedback de combate para o teaser | Implementado; Gemini/Muse/Grok concluíram revisão estática final sem P1/P2. Opus bloqueado por quota. Runtime do feedback pendente. | [`specs/2026-10-10-feedback-combate/`](specs/2026-10-10-feedback-combate/) |

O histórico v0.1/v0.2 e os pareceres recebidos estão nessa pasta. O consolidado classifica os achados e suas decisões; não substitui as saídas originais. Grok, Muse e Gemini concluíram R2 e confirmaram as correções na R3, com relatórios registrados. Opus via AGY e Cursor foi bloqueado por quota. Em 10/10/2026, o usuário dispensou o parecer Opus para este trabalho de upgrades, incluindo a revisão final do plano e as implementações A/B/C; isso não altera a exigência global para outros trabalhos. Em A, Muse e Gemini não apontaram bloqueios e Grok expirou sem stdout. Em B, Muse e Gemini concluíram sem bloqueios; Grok expirou depois de ler as fontes, com o achado P2 do agente principal integrado em C. Em C, os três revisores concluíram a análise estática sem P1/P2; runtime permanece pendente. O registro está em [`implementacao.md`](specs/2026-10-10-upgrades-basicos/implementacao.md).

## Estrutura para planos futuros

Crie uma pasta própria por plano em `specs/`, preferencialmente com data e identificador curto. Inclua `plano.md`, `spec.md`, `historico/` e `pareceres/README.md`. Preserve versões substituídas e relatórios originais; indique os hashes dos artefatos revisados e não apresente pareceres pendentes como recebidos. Marque o estado real: rascunho, em revisão, aprovado para implementação ou arquivado.

## Resultado desta rodada

A documentação foi organizada pelo subagente GPT-6 Luna xhigh e consolidada pelo agente principal. Grok 4.7 XHigh Fast (Cursor), Muse Spark 1.3 Contributor xhigh (OpenCode) e Gemini 3.8 Flash High (AGY) revisaram a proposta e confirmaram as correções na v0.3. Consulte o [índice de pareceres](specs/2026-10-10-upgrades-basicos/pareceres/README.md) e a [consolidação](specs/2026-10-10-upgrades-basicos/pareceres/consolidado.md). O Opus 5.5 High via AGY e via Cursor foi bloqueado por quota, sem parecer. O usuário dispensou esses pareceres somente neste trabalho de upgrades; nenhum resultado Opus foi registrado ou fabricado. Em A, Muse e Gemini concluíram sem bloqueios e Grok expirou sem stdout. Em B, Muse e Gemini concluíram sem bloqueios; Grok expirou após ler as fontes, e o achado P2 do agente principal foi corrigido em C. Em C, os três revisores concluíram a análise estática sem P1/P2; runtime ainda não foi validado. A interface de subagentes não permite selecionar ou confirmar Fast/priority; modelo e esforço usados foram os solicitados.

## Feedback de combate — 10/10/2026

O usuário autorizou um incremento de feedback visual nativo para parry aceito, ricochete de parede, dano inimigo aceito e carga reativa. O usuário confirmou manualmente que os upgrades funcionaram; isso não representa execução de runtime pelo agente. O registro incremental está em [`plano.md`](specs/2026-10-10-feedback-combate/plano.md), [`spec.md`](specs/2026-10-10-feedback-combate/spec.md) e [`implementacao.md`](specs/2026-10-10-feedback-combate/implementacao.md). Gemini, Muse e Grok concluíram a revisão estática final R2 sem P1/P2; Opus AGY/Cursor bloqueado por quota, sem parecer. Runtime deste feedback pendente; nenhum teste/Godot foi executado.

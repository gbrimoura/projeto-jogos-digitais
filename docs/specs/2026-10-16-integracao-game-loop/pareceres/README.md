R1 concluída. O principal encaminhou os achados P1 (API de retorno ausente em RicochetBall) e P2 (configuração de spawn/preview ignorava multiplicadores), além de apontamentos de pausa e sobreposição do HUD. As correções foram implementadas e congeladas para revisão estática seguinte. Os stdout originais permanecem com o principal e não foram sobrescritos; hashes e resumo de disposição antes das correções estão em ../historico/revisao-r1-baseline.json.
## Consolidação final do principal — 16/10/2026

Integração preparada sobre main4047f6a e feature/game-loop-assets fc37fac; usuário autorizou merge e permanência na main. Implementador único GPT-6 Luna xhigh, Fast/priority não selecionável/confirmável. Principal coordenou, inspecionou os contratos, resolveu o índice Git, registrou os pareceres e conclui a publicação. Nenhum teste, Godot, importação ou QA executado, conforme AGENTS.

Preflight de autenticação/modelos uma vez nesta tarefa: AGY Gemini3.8FlashHigh, Cursor autenticado com identificadores e OpenCodeGo/Muse1.3xhigh. Todos os revisores somente leitura/plan; timeout10min por rodada. R1 pacote integral110099caracteres e diffs, R2 seis arquivos integrais49462caracteres com contexto, ambos lidos por ferramentas permitidas de leitura. R3 inline8897caracteres com funções completas relevantes do preview e physics da bola. Entradas e stdout originais preservados em review-package-r1/r2.txt, review-input-r3.txt e arquivos por modelo/rodada; native exits em *-exit.txt.

Resultados:
- Gemini3.8Flash(High)/AGY plan: R1 achadosP1/P2, R2 encerrou-os, R3 confirmou sincronização de preview; exit0 em todas.
- Muse opencode-go/muse-spark-1.3-contributor/OpenCode plan/xhigh: R1 achadosP1/P2, R2 sem bloqueios, R3 confirmou recorte; exit0 em todas.
- Grok cursor-grok-4.6-xhigh-fast/Cursor plan: R1 achadosP1/P2; R2 exit0 mas stdout apenasCRLF, sem parecer útil e sem alegação de aprovação; R3 parecer útil sem correção bloqueante, exit0.
- Opus claude-opus-5-5-high/Cursor plan: R1/R2/R3 exit1 ActionRequiredError por usage limit; nenhum parecer, não substituído. Revisão obrigatória indisponível por quota, registrada sem aprovação fictícia.

Decisões e correções:
1. Setter ausente set_return_target confirmado P1. Principal optou reintegrar a mecânica de retorno da branch, em vez de remover chamada/recurso como sugerido por alguns revisores. Bola retorna sem sweep/parry/dano após limite de ricochetes; collider deferred; guards de callbacks/finished/cancel preservados. R2 confirmou.
2. Raio e velocidade de recompensa agora vêm do snapshot derivado comum ao spawn, lançamento e preview, sem mutar Resource-base. R2 confirmou.
3. Vitória agora pausa como derrota. RunController ALWAYS permite R pressed não-echo e guard de reload; botões continuam disponíveis. Recompensa de chefe processa WHEN_PAUSED, salas PAUSABLE. R2 confirmou.
4. Root identificou sobreposição da HUD; posições da run movidas para canto direito sem alterar HUD das salas. R2 confirmou.
5. Root identificou segmento extra de preview após N-ésimo ricochete, incompatível com retorno imediato. R3 agora interrompe após registrar N, preservando limitezero/grazing. Três revisores confirmaram, sem novo código após a rodada.

Hipóteses rejeitadas como bugs atuais: R em gerenciado reinicia a run por intenção; build compartilhada limpa ao morrer porque a run termina; dano inteiro1×1.25=1 é limite documentado, sem inventar balanceamento; spark visual de180ms pode ultrapassar a troca de sala sem interferência física. UpgradeOffer process_mode WHEN_PAUSED e gates de feedback existentes foram conferidos pelo principal. Revisores não confirmaram compilação/runtime.

Preservados PlayerHealth, animações/parry e bloqueio de disparo, sentinela AoE, Cartoon V2, resources/assets, geração aleatória de plataformas, Main standalone com porta/snapshot. Boss permanece placeholder na mesma main.tscn, um andar na cena de protótipo. Arquivos de editor/plugin/DLL/TMP locais seguem fora do commit. Hashes finais em estado-final-runtime-sha256.json; baselines e pacotes anteriores imutáveis.

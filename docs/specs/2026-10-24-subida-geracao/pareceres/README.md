# Preflight e revisões
Preflight único desta tarefa24/10: Cursor autenticado, catálogo confirmou cursor-grok-4.6-xhigh-fast eclaude-opus-5-5-high; AGYG Gemini3.8FlashHigh disponível; OpenCodeGo autenticado eMuse1.3Contributor confirmado. Grok4.6globalprevalece sobre4.7local. Catálogo não confirmaquota; tentarOpusexato noestadointegradoestável, não substituir. Não repetir preflight semmudança.
Duas análises Luna6xhigh read-only concluídas, semalterararquivos: geração encontrou rejeição por orçamento +alturacap; salto encontrou retrysomente de descida e limitação de decolagem. Root conferiu fórmula do ápice e standoffs vs paredes.
Após as duas implementações sequenciais: revisões read-only Gemini AGYHigh/plan, Grok Cursor4.6xhigh-fast/plan, MuseOpenCode xhigh/plan, OpusCursorHigh/plan. Timeout10min; entrada/snapshot/SHA/stdout/stderr/exit preservados. Sem Godot/testes/import/parser/linter/QA; sembenchmark/alegação de gameplay.

## R1 integrado congelado
Entrada runtime-r1-input.txt SHA256 DF05807DC7BFFD13C8D9D56D87F4863B0AED00E661BABFCDDCA000896F3563A4 (159516bytes). Snapshot18arquivos em ../historico/runtime-r1/sha256.json;16protegidos intactos em ../historico/protected-r1.json. Modificados apenas training_target.gd e room_layout_generator.gd; diffs nav/gen preservados. Main, solver, perseguição-base, Run, cenas, avisoCospe/arte/background permanecem íntegros.
Revisões read-only iniciadas24/10 ~12:16SP, timeout10min: Gemini AGY3.8FlashHigh/plan, Grok Cursor4.6xhigh-fast/plan, MuseOpenCode1.3Contributor/xhigh/plan, OpusCursor5.5High/plan. Opus retornou exit1 por quota; stderr inclui também falha do auto-updater em .promote-lock, sem intervenção em locks/versões/autenticação. Semparecer/substituição. Muse concluiu semP1/P2 bloqueante; demais emandamento. Sem Godot/testes/import/parser/linter/QA/simulação/benchmark. Não atribuir aprovação pendente.

## Resultado e decisão final
| Revisor | Ferramenta/modelo/modo | Resultado fiel |
|---|---|---|
| Gemini | AGY Gemini3.8FlashHigh, plan | exit0, semP1/P2 concreto; três observações não bloqueantes |
| Grok | Cursor cursor-grok-4.6-xhigh-fast, plan | exit0, stdout em branco2bytes; semparecer útil, semaprovaçãoatribuída |
| Muse | OpenCode muse-spark-1.3-contributor, xhigh, plan | exit0, semP1/P2 bloqueante; observações de filtros/espera/revalidação |
| Opus | Cursor claude-opus-5-5-high, plan | exit1 porquota, semparecer; não substituído |

Saídas originais runtime-r1-{gemini,grok,muse,opus}.{stdout,stderr,exit}.txt preservadas. Não houve alteração de runtime após as revisões, nem novo preflight. Nenhuma aprovação Opus/Grok inexistente foi atribuída. A falha do auto-updater .promote-lock no stderr Cursor foi preservada sem intervenção; a causa final da indisponibilidade Opus foi quota.

Avaliação do principal:
1. Navegação mantém limites/casts/gravidade/apex originais. Até7 candidatos de subida/equal são finitos e deduplicados; uma lista por aresta, avançada em falhas, termina antes de bloquear. Descidas mantêm uma alternativa. Planos antecipados são filtro: arrival ePREPARE recalculam/revalidam de acordo com posição/obstáculos/Player atuais. Não há garantia de atravessar Player, underside ou ocupar pouso sem espaço; essa recusa permanece correta.
2. O standoff teórico76 junto da parede pode continuar sendo a primeira escolha e aguardar stuck timeout antes do retry físico atual/offsetseguro. Gemini descreveu a espera como observação, não travamento permanente. Não foi adicionado ajuste geométrico que ignorasse paredes para eliminar essa espera.
3. A geração respeita orçamento por construção: extra<=folga/capacidades, mínimos por slot a partir da capacidade sufixa e máximo pela capacidade/extra restante. Isso mantém budget viável em cada etapa. Fisher-Yates usa RNGlocal, não Array.shuffle/global. Vertical mantém soma0..64, primeira440 e monotonicidade; Main e índices continuam compatíveis. Configuração inviável mantém fallback validado ou erro.
4. Reserva de1unidade8quando háfolga é margem local e evita saturação. Diferente da descrição aproximada do Gemini, coordenadas de grade8 já impedem fim exato980; o máximo alinhado é976, e a unidade extra pode reduzir a ocupação máxima quando hábudget. Sem nova regra final doGDD.
5. Fallback técnico2/4/5 continua fixo e validado, não é novo perfil procedural ou contagem final. Nenhum benchmark/FPS/alcance real foi medido. Custo da busca de decolagem segue limitado, preservando queries de segurança; não se afirma ganho de FPS por essa busca.
6. Não há P1/P2 concreto a corrigir no estado lido por Gemini/Muse/principal. Não registrar unanimidade: Grok não devolveu parecer útil e Opus não pôde revisar.

Decisão: R1 integrado. Integridade final18/18 arquivos revisados estáveis e16/16 protegidos intactos; entradaSHA inalterado, evidência em ../historico/stable-final.json e protected-final.json. Mudanças somente em training_target.gd e room_layout_generator.gd. Sem testes/simulações/Godot/import/parser/linter/QA, commit/push/troca de branch. Revisão estática não confirma jogabilidade ou desempenho real.

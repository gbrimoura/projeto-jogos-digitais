# Preflight e revisão
Preflight único desta tarefa24/10: Cursorstatus autenticado; cursor-grok-4.6-xhigh-fast eclaude-opus-5-5-high presentes; Gemini3.8FlashHigh viaAGY disponível; OpenCodeGo autenticado/Muse1.3Contributor disponível. Grok4.6globalprevalecesobre4.7local. Catálogo não garantequota; tentarOpusexato noestadoestável, semsubstituição. Não repetirpreflight.
Apósimplementação: GeminiAGYHigh/plan, GrokCursor4.6xhigh-fast/plan, MuseOpenCode xhigh/plan, OpusCursorHigh/plan, somenteread-only10min. Saídasoriginais/stdout/stderr/exit/entradaSHA/snapshotpreservados. Sem Godot/testes/import/parser/linter/QA. Ainda não iniciadas.

## R1/R2 congelados e revisão
R1: entrada runtime-r1-input.txt SHA256010C24CA5B55DB8651102BAD4BD49C9362995989A0BCFE5B7BF64EE408E83D87,99358bytes; snapshot12arquivos em ../historico/runtime-r1/sha256.json,11protegidos intactos. Revisões read-only iniciadas24/10 ~12:44SP: Gemini semP1/P2; Muse apontou P2baixo de centrostale no novo fallback; Grok exit0 stdoutem branco; Opus exit1 porquota, semparecer/substituição. Saídas runtime-r1-* preservadas. Nenhum preflight repetido.

R2: Luna corrigiu apenas uma linha: a consulta de fallback usa global_position+attack_center_offset pós-movimento, emvezdo attack_center calculado naentrada da função. SnapshotR1/diff preservados. O principal avaliou que o drift anterior efetivo no fallback seria<0.1px (movimento>=0.1reseta stuck), mas aceitou refinamento de precisão. A consulta agora usa o mesmo centro atual que será travado no início do golpe. Não alterou guardas, danos, distância, velocidade, timing ou novosestados.
Entrada delta runtime-r2-input.txt SHA256371492FC72D424D3AAB17DD67DF6A27A71EC7A389D1949756F666B1BD5C515F2,6518bytes; snapshotfinal em ../historico/runtime-r2. Gemini/Muse confirmaram P2 resolvido, semnovo defeito concreto. Grok delta emandamento. Opus não repetido nesta mesma tarefa apósquota jádemonstrada; indisponibilidade não significa aprovação e não houve substituição. R2 é revisão de delta sobre as demaisfontes inalteradasdoR1, não novo preflight. Sem engine/test/parser/linter/QA.

## Resultado e decisão final
| Revisor | Ferramenta/modelo/modo | R1 | DeltaR2 |
|---|---|---|---|
| Gemini | AGY Gemini3.8FlashHigh, plan | exit0, semP1/P2; tuning/stuck comoobservações | exit0, confirma correção do centrosemnovodefeito |
| Grok | Cursor cursor-grok-4.6-xhigh-fast, plan | exit0, stdout em branco2bytes; semparecer útil | exit0, stdout em branco2bytes; semparecer útil |
| Muse | OpenCode muse-spark-1.3-contributor, xhigh, plan | exit0, P2baixo centrostale; observaçõesopcionais | exit0, P2resolvido; semnovodefeito concreto |
| Opus | Cursor claude-opus-5-5-high, plan | exit1 porquota; semparecer/substituição | não repetido após indisponibilidade demonstrada na mesma tarefa |

Saídas originais runtime-r1-* e runtime-r2-{gemini,grok,muse}.* preservadas, incluindo P2original e confirmação posterior; entradas/SHA/snapshots completos. Nenhuma aprovação Grok/Opus atribuída. Os nomes4.7 no encerramento textual do Gemini são boilerplate: comandos/preflight reais foram4.6 conformepreferênciaglobal. Sem novo preflight ou alteração apósR2.

Avaliação crítica:
1. Tuning120/96é provisório: aplica perseguição, não patrulha/voo/escape ou dano. Gate central não substituiqueryreal deárea/LOS e é consistente nos3pontosde início. Estadoativo deataque permanece parado comcentrotravado.
2. Margeminterna8restaurada antesR1 mantémalvodeparada dentrodopreferido. Distância2Dfora96 mantémnecessidade deaproximação mesmo dxalinhado, evitando que Yinacessível zerecontadorcontinuamente.
3. Fallback sóexecutaapósstuck0.65 e replan<=0 comoverlap/LOS reais; é consumido em_begin_windup. QuandoPlayer está fora140 ousemLOS, contador podeficarmaduro econsultaritmado0.45; aoapareceremalcancereal livre podeatacar. Gemini tratoucomportamentocomo observação segura, nãovazamentodedano. Nãoforçaataquesatravés deWorld ou ignoracorpos.
4. R1reutilizava centropré-movimento. Drift dofallbacknessa passagem era<0.1px porque moved>=0.1 zera_stuck; root aceitou corrigirprecisão. R2consultaposiçãoatual, idênticaaocentrotravado em_begin_windup, e ambosrevisores confirmaram. Nãohouveoutraalteração entreR1/R2.
5. Muse citou detour herdado [bound,candidate,bound] para contornar LOS ecasos alinhados dx<=5/LOSbloqueada como dívidas opcionais; não são regressões da troca de centro nem exigem novo sistema de navegação. Mantidos no escopo mínimo. Duplicação da expressão global_position+offset é estilo sem divergência atual.
6. SemnovodefeitoP1/P2pendente noR2 porGemini/Muse/principal. Não háunanimidade fabricada: Grok semretorno útil e Opus indisponível.

Decisão: manter R2 integrado. Integridadefinal12/12 arquivos revisados estáveis e11/11 protegidos intactos, em ../historico/stable-final.json e protected-final.json. Runtimealterado somente training_target.gd. SemGodot/import/parser/linter/teste/simulação/QA/benchmark, commit/push/troca debranch. Revisãoestática não confirma gamefeel ou frequência realdeacerto.

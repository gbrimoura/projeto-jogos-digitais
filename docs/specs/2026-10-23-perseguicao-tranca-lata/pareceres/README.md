# Revisões e preflight — 23/10/2026
Implementação R3 integrada sobre baseline local, porGPT-6Luna xhigh, escritorúnico, timeout30min; Fast/priority não confirmável. Incremento da navegação já existente, plano/spec prospectivos nesta pasta. Principal registra pareceres fiéis e examina achados.
Preflight único desta tarefa executado: agent status autenticado; agent --list-models confirma cursor-grok-4.6-xhigh-fast e claude-opus-5-5-high; agy models confirmaGemini3.8FlashHigh; opencode auth list confirmaOpenCodeGo e catálogoMuse1.3Contributor. Sem ler/alterarsegredos. A disponibilidade em catálogo não garantequota; revisãoOpusserátentadasobreestadoestável e indisponibilidaderealseráregistrada. GlobalGrok4.6 prevalece sobrelocal4.7.
Evidência real do usuário em historico/godot-user-before.log: helpernewclassnãoidentificada ePNGnewatlas nãoimportados, bloqueandoTrainingTarget/layout. Não desligarvalidadorMain.
Revisão arquitetural limitada do algoritmo BFS/seleçãoFloor peloGemini emparallel read-only; não autorizaescrita nem substitui revisãofinal de implementação. Apóscongelar: Gemini/Grok/Muse/CursorOpus somenteleitura, timeout10min, stdout/stderr/exits/entradaSHA preservados. SemGodot/testes/import/gdlint/QA conformeAGENTS.
## R1 — estado estável
Entrada runtime-r1-input.txt: SHA256 EDA8F76DD78F5DB1A32145D88B7388A5AC5CFB41ABDF6A620AD08895C37E0CBC. Snapshot integral e hashes em ../historico/runtime-r1/sha256.json; arrays das duas texturas omitidos apenas do input textual. Escopo: perseguição/helper, nome/cena Worker, recursos e gerador. Nenhum teste/motor/import/parser/linter/QA.

| Revisor | Ferramenta/modelo | Resultado atual | Evidência fiel |
|---|---|---|---|
| Muse | OpenCode opencode-go/muse-spark-1.3-contributor, variante xhigh, plan | Concluído exit0, sem P1/P2 bloqueante; limita verificação do payload RGBA por estar omitido do input. | runtime-r1-muse.stdout.txt, .stderr.txt, .exit.txt |
| Opus | Cursor claude-opus-5-5-high, plan | Bloqueado por ActionRequiredError: quota Opus; sem parecer. Reset informado pelo provedor03/11/2026. Não substituído. | runtime-r1-opus.stdout.txt vazio, .stderr.txt, .exit.txt |
| Gemini | AGY Gemini 3.8 Flash (High), plan | Concluído exit0, sem P1/P2. | runtime-r1-gemini.* |
| Grok | Cursor cursor-grok-4.6-xhigh-fast, plan | Concluído exit0, achados avaliados abaixo; correção R2. | runtime-r1-grok.* |

Avaliação do principal: Muse confirmou contrato sem bloqueios. A observação sobre detour conservador não altera o escopo; Floor é aceito como destino na busca dirigida principal. Não equivale a confirmação de gameplay. Integridade dos arquivos protegidos confirmada em protected-integrity-r1.json; código mantém snapshot R1 conforme stable-review-r1.json. O stdout Gemini arquitetural anterior é consulta limitada, não aprovação do runtime.

## Encerramento dos pareceres R1 e decisão do principal
Gemini concluiu exit0 sem P1/P2; Muse concluiu exit0 sem P1/P2 bloqueante. Grok concluiu exit0 com achados de perseguição; stdout integral mantido. Opus não produziu parecer por quota. Todos se referem à entrada R1 imutável e ao snapshot histórico.

Aceitos: fallback de aproximação segura no apoio atual quando não há rota/plano, e limpeza do estado de detour quando falha ou fica sem rota. São defeitos reais de cobertura/estado, tratados na R2 pelo mesmo implementador Luna. Também aceita correção correlata de escolher o ponto de decolagem do lado mais próximo, evitando exigir caminhar sob a plataforma de destino antes do salto, e conservação de sucessores válidos no pouso se aplicável.

Não aceitos como defeitos: aumento de MAX_RISE144 para alcançar400/376 diretamente do chão560 (limite físico deliberado; usar440 intermediária); remoção da histerese do último apoio aéreo (exigência explícita do contrato); alegação especulativa de que Array tipada retornada por call poderia falhar (nenhum caso concreto ou incompatibilidade demonstrada). Exclusão de Floor apenas no detour intermediário é conservadora e não impede Floor como destino no grafo principal. Tentativas alternativas de salto continuam limitadas pela validação física; não se amplia este incremento para navegação genérica.

R1 permanece preservada integralmente. R2 será nova entrada/snapshot; revisores somente leitura recebem a correção e o contexto integral do actor. Sem execução de Godot/testes/QA.

## Revisão delta R2
Entrada runtime-r2-input.txt SHA256 D8E1AB5E01B14BB95CB7F249327D939CAB049731ED27BD99ED382B2B36BA56BA, diff e actor completo. Snapshot integral em historico/runtime-r2; somente training_target.gd mudou. Gemini/Grok/Muse em andamento sobre estado congelado, mesmos modelos/ferramentas/modos e timeout10min. Opus permanece indisponível pela tentativa real R1 desta tarefa (quota), sem parecer substituto. Preflight não repetido.

Grok R2 concluiu exit0: confirma correção do freeze, sem novo P1/P2 bloqueante; recomenda encerrar sem R3. Muse R2 concluiu exit0: confirma fallback, ausência de recursão, bounds e limpeza do detour, sem P1. Observações Muse P2 foram avaliadas pelo principal como não bloqueantes: parada de um tick após falha se recupera na física seguinte (também reconhecida por Grok); deadzone de5px evita jitter e não representa navegação vertical; guard do fallback com alvo morto/suporte ausente é apropriado, com limpeza anterior em refresh/fluxo de pouso. Não se altera código para remover pausas de decisão de um frame. Gemini R2 ainda em andamento. Saídas fiéis runtime-r2-{grok,muse}.{stdout,stderr,exit}.txt.

Gemini R2 concluiu exit0 com dois P2 pontuais: acumulação de stuck suprimida sem LOS dentro da distância de parada e guarda defensiva para rota de detour com origem desatualizada. O principal aceitou ambos, apesar de a segunda não ter caminho concreto pelas transições atuais, por serem duas guardas locais de baixo impacto. R2 preservada; Luna corrigiu somente actor na R3: `elif needs_horizontal_approach` após a verificação de progresso, e limpeza do path obsoleto antes do cooldown. Nenhum redesenho ou outro arquivo alterado.

## Revisão delta R3
Entrada runtime-r3-input.txt SHA256 D92395D907E55E96AED69E8C45D4B540A195CE947A0BC7D8255D4973EF869A76. Diff R2/R3 e funções completas de perseguição, mais contrato/manifesto; corpo integral preservado no snapshot historico/runtime-r3. Actor SHA256 EBBDC2443C71DEB91100793D50FE5D37882A16068E91DC45A0EB68769BE1C6BE. Gemini/Grok/Muse em andamento somente leitura, mesmos modelos, ferramentas, modos e timeout10min. Opus segue indisponível por quota comprovada nesta tarefa, sem substituição. Sem Godot/testes/import/parser/linter/QA.

## Encerramento R3
| Revisor | Estado real | Evidência |
|---|---|---|
| Gemini 3.8 Flash High / AGY plan | exit0, confirma as duas guardas e nenhum P1; observações P2 avaliadas abaixo. | runtime-r3-gemini.stdout.txt, .stderr.txt, .exit.txt |
| Muse Spark1.3 Contributor xhigh / OpenCode plan | exit0, aprova delta sem bloqueios; observações não bloqueantes. | runtime-r3-muse.stdout.txt, .stderr.txt, .exit.txt |
| Cursor Grok4.6 XHigh Fast / plan | exit0, stdout só quebra de linha (0 caracteres úteis), stderr vazio: sem parecer R3, não é aprovação. R2 teve parecer útil confirmando correção anterior. | runtime-r3-grok.stdout.txt, .stderr.txt, .exit.txt; runtime-r2-grok.stdout.txt |
| Cursor Opus5.5High / plan | indisponível pela quota comprovada R1, exit1; nenhum parecer, sem substituição. | runtime-r1-opus.stderr.txt e .exit.txt |

Decisão do principal: integrar R3 e encerrar este incremento sem R4. As guardas corrigem os casos concretos. A possível origem desatualizada no ramo geral é uma defesa hipotética: os únicos fluxos de troca do apoio passam por queda/pouso, sem perseguição no ar e com `_clear_pursuit_route()` no vínculo; não foi demonstrada transição que preserve rota antiga e volte a GROUND com suporte diferente. Deadzone5px é intencional; não se exige busca de deslocamento horizontal quando o Player está alinhado nesse intervalo e sem suporte alternativo escolhido. Repetir tentativa de detour a cada450ms após falha é o replanejamento limitado do contrato, não a cada tick; preservar o timer de stuck enquanto bloqueado evita inserir um atraso adicional de650ms sem progresso. O limiar de progresso0,1px é seguro no physics padrão60Hz (48px/s gera0,8px/tick), sem configuração de physics de1000Hz no projeto. São observações defensivas/tuning futuro, sem defeito atual concreto que justifique novo incremento.

Conferência final por hashes: runtime R3 estável em historico/stable-review-r3.json; arquivos protegidos intactos em historico/protected-integrity-final.json. Revisões são estáticas; não houve Godot/testes/import/parser/linter/QA. Saídas originais e snapshots R1/R2/R3 preservados. Alterações locais anteriores, branch e estado Git preservados, sem commit/push.

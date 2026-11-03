# Plano prospectivo — valley e recuperação de HUD

01/11/2026. Usuário enviou imagem do erro técnico de sala2, andar1, família valley, runseed4162699858 e roomseed3353966537. Candidato e fallback canônico recusados por suporte primário não alcançável. Log existente confirma o erro e traz falha adicional da HUD ao recuperar: Trying to cast a freed object, run_hud_bridge.gd:428 em _restore_legacy_visibility.

Trabalho complexo de geometria e recuperação. Luna gpt-6-luna xhigh fez diagnóstico read-only; root avaliou criticamente sem executar engine/simulações. Fast/priority não confirmável. Toda mudança local anterior deve ser preservada. Plano fechado antes da escrita, préflight único e revisões de plano/código somente leitura. Um único escritor por vez.

## Causa e decisão de geração

Valley mantém forma400/448/448/400 no canônico e índice primário0 na ala mais alta, fallback1. A ala não é alcançável diretamente do chão (subida160>128), porém isso NÃO torna o índice errado: Main usa busca em grafo de apoios, permitindo Floor→apoio1→apoio0. Principal rejeita a sugestão inicial de alterar primary para1: poderia apenas enfraquecer o requisito e mudar o encontro. Manter primary0/fallback1 e o validador físico integral.

O problema concreto de geometria é a folga horizontal de56px entre alas altas e apoios baixos (centros216 apartados, largura160). O validador usa pontos de lançamento finitos e direção horizontal constante; o lançamento ao apoio448 pode colidir com a ala alta ou underside antes de limpar o topo. O fallback repete essa geometria independentemente da seed.

Proposta escopada em room_layout_generator.gd: somente valley aleatório usa gaps80/88/96 no lugar de48..96; outras famílias preservam exatamente seus intervalos. Canônico valley centros[216,456,696,936], widths160, tops[400,448,448,400]. Gaps80 e bounds136..1016, todos em grade8; espelhamento1152-x existente preservado. Não mudar contagem, shape, alturas, largura da patrulha, seleção de família, primary/fallback, physics, validações, seeds da run ou fluxo de retry. Valley muda seus layouts desejadamente para corrigir colisão; a mesma seed continua determinística nesta versão, não se promete geometria idêntica à versão defeituosa.

Evidência matemática manual, não simulação executada: com movimento real speed260/accel1600/gravity1600/jump640 e60Hz, Floor560→apoio1[376,536]top448 pode partir x312 (amostra left-64), velocidade inicial0. Corpo começa em298..326, já após ala0 acabar296. No passo14, deslocamento horizontal≈41,67, borda direita367,67<376 e pés451,11; passo15 pés446,67 já acima do topo. Aterrissagem por volta do passo34..35 emx441,6, dentro398..514. Depois apoio1→ala0 top400 é subida48; saindo x390, a descida cruza y400 emx217,9, dentro158..274. Reflexão horizontal dá o caso RIGHT. LEFT/RIGHT/DOWN de valley têm spawn no chão contínuo; UP usa famílias de teto e não é alterado. Essa leitura demonstra rota amostrada possível sem aumentar salto, mas não substitui verificação da seed em runtime.

## Recuperação de HUD

A HUD salva referências a CanvasItems legados para restaurar visibilidade. Algumas são liberadas durante troca/rollback. Hoje faz cast `node_variant as CanvasItem` antes de is_instance_valid, e o cast já lança erro. Em run_hud_bridge.gd, validar a Variant crua antes de qualquer cast de chaves dos caches _visibility_before e _enemy_cache; ignorar/remover entradas inválidas com segurança, restaurar apenas nós vivos. Cobrir _restore_legacy_visibility, _restore_visibility_for_subtree, _ensure_legacy_hidden, _unbind_room e _update_target onde há padrão equivalente. Não redesenhar HUD, não mexer na compactação/anchors/escala, não reescrever lifecycle/tokens/sinais, não criar novo sistema de WeakRef/ID ou alterar gameplay.

## Escopo e aceite

Escrita exclusiva dos dois arquivos: scripts/world/room_layout_generator.gd e scripts/ui/hud/run_hud_bridge.gd, somente regiões acima. Main, RoomRunLayout, RunController, Player/movimento, cenas, HUDRoot, portas/assets/project.godot e antigo fix allowed_steps.assign ficam protegidos. Sem commit/push/stage/reset/troca de branch. Baseline dirty preservada antes da escrita.

Não executar Godot, testes, parser, linter, auditoria, benchmark ou simulação Python/JS transcrita. User enviou falha, mas não dispensou a proibição expressa do AGENTS sobre execução. Diagnóstico usa imagem/log existente e leitura/cálculo manual. Falha técnica/retry deve continuar preservando a run; não silenciar erro nem aceitar sala inválida.

Plano complexo passa por Gemini3.8High/AGY, Grok cursor-grok-4.6-xhigh-fast/Cursor, Muse1.3Contributor/OpenCode xhigh e Opus claude-opus-5-5-high/AGY. Código estável será revisado pelos três primeiros e Opus exato via Cursor. Preflight uma vez; Grok global do usuário4.6 prevalece sobre4.7 local. Quota/retorno vazio não é aprovação; não substituir modelos. Timeout revisão10min, writer15min após liberação; handoffstdout STATUS/SUMMARY/CHANGED_FILES/TESTS/RISKS/NEXT_STEP sem relatórios extras do implementador.

## Refinamento prospectivo — apoios de acesso do valley

Além do gap80..96 e do canônico ampliado, fixar somente os dois apoios internos valley(indices1/2) em top448. O jitter dos apoios internos432/440 permite ainda a colisão underside na amostra lateral64: no passo16 a borda do corpo alcança o alvo mas pés442,67 ainda não passaram top440/432. Em448 essa mesma trajetória já limpou o topo no passo15. Manter as chamadas RNG existentes de jitter para preservar sua contagem, aplicar o top de acesso448 depois do cálculo; alas altas e larguras/posições/vãos permanecem variáveis. Não mudar outras famílias nem primary0.

Esta decisão é anterior à implementação, matematicamente derivada do validador, não um resultado de execução. Candidatos ainda precisam passar as mesmas validações; fallback canônico não muda índices para mascarar erro. O texto de diagnóstico original de Luna será preservado como parecer com a parte do índice rejeitada pelo principal, já que o grafo permite caminhos indiretos.

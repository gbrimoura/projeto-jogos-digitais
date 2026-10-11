# Consolidação dos pareceres — upgrades básicos

**Avaliação do agente principal:** 10/10/2026.  
**Artefatos revisados:** v0.1 congelada; SHA-256 do plano `AB4220380AEAEF630E6FA4C1DCB54C238DFC66626AE915259804701555ECCF63`; SHA-256 da spec `4B753A6905461FBE6E6C9FF86880A7E9E7C69813F84934843C7090F57807AE07`. Cópias preservadas em [`historico/`](../historico/).

## Limites da revisão

Gemini revisou os documentos fornecidos inline e não inspecionou o código. Grok e Muse compararam o plano/spec com código e cenas do commit `e2855c2`; nenhum executou Godot ou testes. O Muse não conseguiu localizar o GDD irmão durante a leitura (glob retornou zero); portanto, seus comentários sobre compatibilidade com o GDD não são verificação independente desse arquivo. O GDD foi consultado pelo agente principal: o snapshot de 03/10 registra build temporária perdida na morte, slots/economia ainda pendentes e não contém estes upgrades.

As prioridades P1/P2 abaixo identificam riscos/contratos necessários no plano e na implementação futura. **Não são bugs de uma implementação de upgrades entregue**: esta tarefa é documental e nenhum código de gameplay foi alterado.

## Decisões por achado

| Fonte e severidade original | Achado | Avaliação do agente principal |
|---|---|---|
| Gemini P1; Grok P1; Muse P1 | Timer de 2,2 s da carga confundido com lifetime da bola. | **Aceito.** A v0.2 remove timer próprio: uma carga por vida da bola, consumida no primeiro dano aceito ou descartada ao terminar/cancelar a mesma bola. Parry preserva lifetime restante. |
| Gemini P1; Grok P1; Muse P1 | Estado local se perderia em troca de cena sem Autoload; payload de HP/build não estava definido. | **Aceito com arquitetura definida.** `Main` guarda `RunBuild` da sala; `RoomTransition` `RefCounted` usa seu dicionário estático one-shot para snapshot deep-copy simples, sem objetos `RunBuild`/`Resource` vivos. |
| Grok P1; Muse P1; Gemini P2 | `take_damage` sem retorno não permite saber se dano foi aceito. | **Aceito; requisito obrigatório.** `RivetWorker` e `TrainingTarget` retornam `bool`: `true` somente com redução de HP (inclusive letal); `false` para dano inválido ou inimigo já derrotado/sem HP. Sem i-frames novos. |
| Grok P1; Muse P1 | Callback letal pode reentrar no sweep/parry; pausar ou `queue_free()` no callback não interrompe a função corrente. | **Aceito.** Vitória só marca estado pendente no callback. Depois do flush, revalidar vivo/clear/elegibilidade, cancelar a bola de forma adiada e abrir UI. A bola testa `_has_finished` após callbacks externos e encerra o loop. |
| Grok P1; Muse P1 | Oferta pode travar sob pausa ou vazar clique/tecla ao gameplay. | **Aceito.** UI em `PROCESS_MODE_WHEN_PAUSED`; `Main` guarda a pausa anterior e só remove a que possui. Estados incluem vitória pendente e cancelamento por morte. Seleção é registrada antes de aplicar efeito. Ações discretas ficam gated após fechar até soltura e 0,25 s configuráveis sem entrada; entrada durante a guarda reinicia-a. Movimento pode voltar ao fechar. |
| Grok P1; Muse P1 | Snapshot raso/consumido cedo e ordem de restauração incompatível com `_ready` dos filhos. | **Aceito com regra one-shot explícita.** Pré-validar recurso, caminho canônico e payload antes da troca; na origem, falha limpa pending e mantém HP/build jogáveis. No destino, sempre copiar e limpar pending exatamente uma vez, inclusive path mismatch/payload inválido; rejeitar o snapshot e iniciar fixture segura. Restaurar depois que filhos estiverem prontos, substituir contagens e reconfigurar controllers antes de checar sala já limpa. |
| Grok P1; Muse P1 | Configuração `.tres` pode ser compartilhada e mutada por upgrade. | **Aceito.** Duplicação profunda das bases por jogador/bola, derivação idempotente e cópia própria por bola. **Parcial:** não adotar a sugestão específica de refatorar para campos float-only; o contrato exige bases intactas, não essa forma interna. |
| Gemini P2; Grok P1; Muse P1 | Bola ativa pode continuar durante vitória/oferta. | **Aceito com ajuste de fase.** Cancelar a bola própria depois do callback/flush, não dentro da mutação síncrona de física. |
| Grok P2; Muse P1 | Oferta pode abrir em sala indevida ou sala já limpa. | **Aceito.** `reward_enabled` exportado em `Main`, true na Sala 01 e false na Sala 02; não identificar a sala por string/path embutido na lógica. |
| Grok P2; Muse P1/P2 | Rebuild poderia acumular contagens; carga poderia rearmar depois de consumida. | **Aceito.** Contagens 0/1 são substituídas no restore. Carga tem estados `INATIVA → CARREGADA → CONSUMIDA` e nunca rearma na mesma vida de bola. |
| Gemini P3; Grok P2; Muse P2 | F6 poderia ser confundido com input de runtime. | **Aceito.** F6 é somente o comando do editor “Run Current Scene”; não mapear tecla runtime nem herdar payload em execução isolada. |
| Grok P1/P2; Muse P2 | E pode ficar enfileirado durante oferta; morte durante oferta precisa precedência. | **Aceito.** Consumir E na oferta e exigir nova entrada após a guarda; morte simultânea vence e cancela oferta. |
| Grok P2 | Queda em `y > 760` chama `reset_to_spawn`; definir destino da bola/carga. | **Aceito.** Queda mantém HP/build; o reset cancela bola, portanto descarta a carga com ela. **Rejeitado como afirmação factual:** o Muse disse que o reset não cancela a bola; isso contradiz a confirmação do agente principal sobre o `BallLauncher.reset()` chamado pelo fluxo atual. |
| Grok P3; Muse P3 | Resultado futuro 2 + 2 = 4 poderia parecer critério da v1. | **Aceito.** Mantido apenas como hipótese futura; não é combinação testada nem permitida na aquisição única desta versão. |
| Muse P3 | Visual da carga não tinha contrato observável. | **Aceito.** Usar visual nativo de arco/Polygon2D/Line2D sem nova colisão nem mudança física. |
| Gemini P1 | Quatro revisões concentradas em 13/10 tornam correção/re-revisão inviável. | **Aceito.** Revisar depois de cada incremento substantivo A/B/C; 13/10 fica com buffer de correções, re-revisão, GDD e validação/captura autorizadas. Sem horário inventado de code freeze. |
| Gemini P3; Grok/Muse | Recorte e números poderiam parecer regra geral do jogo. | **Aceito.** Separar mecânicas confirmadas pelo usuário dos recortes e valores temporários; manter slots, economia, raridade, stacks e balanceamento pendentes do GDD. |
| Gemini, recomendações opcionais | Gerenciador raiz persistente ou payload estático; recursos imutáveis; preflight. | **Decisão do principal:** escolher snapshot one-shot no dicionário estático de `RoomTransition` `RefCounted`, cópias profundas de recursos e preflight por tarefa. Não adotar o `WorldContainer` persistente sugerido. |
| Grok P1, alternativa de mismatch | Manter payload se o caminho de destino não corresponder. | **Rejeitado.** O payload é one-shot: mismatch/invalid no consumidor é rejeitado e limpo para impedir aplicação futura acidental; origem permanece jogável quando a falha é detectada antes da troca. |
| Muse P2, F6 | Criar ação/keycode F6 em runtime ou deixar manual sem contrato. | **Rejeitado.** O contrato explícito de v0.2 cobre somente execução isolada pelo editor, sem captura de tecla. |

Outras sugestões opcionais que não alteram o contrato não foram transformadas em requisitos. As saídas integrais dos revisores permanecem inalteradas nos arquivos originais e `.stdout.json` desta pasta.

### Refinamentos definidos pelo coordenador para v0.2

- Só uma bola lançada com a melhoria `carga_reativa` pode ser energizada; parry válido sem essa melhoria mantém a bola inalterada.
- `reward_enabled=false` não deixa a sala presa em `VITÓRIA_PENDENTE`: depois do restore/flush e da checagem de morte, pula a oferta, limpa projéteis, libera uma porta se houver e termina como `CONCLUÍDA` se a sala for terminal. Uma cena que já inicia limpa é avaliada após restore uma vez; sinais duplicados ou já processados não abrem outra oferta.

Esses refinamentos são decisões do coordenador para tornar o contrato executável, não alegações atribuídas a um revisor.

## Resultado documental

As decisões aceitas foram incorporadas ao plano/spec v0.2. A v0.1 permanece disponível no histórico e os pareceres originais continuam preservados. A v0.2 está arquivada como versão histórica. Nenhum código, teste, execução do Godot ou atualização do GDD foi feito nesta frente.

## Avaliação da releitura v0.2 e consolidação v0.3

**Estado:** revisão final incompleta; v0.3 não aprovada para implementação. Gemini e Muse entregaram pareceres R2 inline. O parecer R2 do Grok e sua saída original estão registrados nesta pasta. Opus via AGY e Cursor foi bloqueado por quota, sem parecer; não houve substituição. As saídas R2 disponíveis foram fornecidas inline, sem inspeção de código nesta rodada. Os status são documentos de planejamento, não achados de uma implementação entregue.

### Achados aceitos e incorporados

| Fonte/severidade original | Achado ou polimento | Decisão do coordenador para v0.3 |
|---|---|---|
| Gemini R2, risco médio | Rebites/projéteis podem ficar pausados durante a oferta e reaparecer ao retomar. | **Aceito.** Depois do flush, antes de abrir UI/pausar, encerrar bola própria e remover todos os nós do grupo `hostile_projectile`, inclusive rebites redirecionados. Aplicar a mesma limpeza quando `reward_enabled=false`; não deixar projéteis pausados voltarem após a seleção. |
| Gemini, baixo; Muse, baixo; Grok, alto | Guarda de input sem dono/nome e sem semântica única para entradas discretas versus movimento. | **Aceito.** `Main.post_upgrade_input_guard_seconds`, export proposta com default 0,25 s. Quiet window começa após soltar launch/parry/dash/jump/interact; cada nova entrada discreta é consumida e reinicia. Movimento e mira voltam normalmente e não contam/reiniciam a guarda. |
| Muse, baixo; Grok, médio | Snapshot sem schema/valores estritos e inconsistências de IDs/counts. | **Aceito.** Schema versão 1; caminho canônico `res://`; tipos, HP, IDs conhecidos e únicos, contagens 0/1 consistentes, total de aquisições ≤1. Validar tudo antes de aplicar qualquer estado. Cópia e limpeza one-shot também para versão/tipo inválido e mismatch; destino seguro fresco. |
| Muse, baixo | Terminologia “terminal Sala 02” pode sugerir porta que não existe. | **Aceito.** Nomear o caso como Sala 02 (terminal sem porta), mantendo `reward_enabled` como regra exportada e sem universalizar o recorte. |
| Muse, risco médio de calendário | Revisões por incremento e prazo do teaser podem não caber com filas externas. | **Aceito.** B e C são metas sequenciais para 12/10; C só começa após revisões de B. Dia 13 é buffer/re-revisão/GDD/validação solicitada e captura, sem incremento planejado. Datas 11–14 são metas condicionadas à aprovação e disponibilidade; Opus pendente impede início da etapa A. 13–18 h técnicas não incluem fila nem edição. |
| Gemini, baixo | A interação pode depender de novo `body_entered` embora o jogador já esteja sobre a porta. | **Aceito.** Novo E após a guarda consulta o overlap já registrado pela porta e revalida vivo/em alcance; não exige novo evento de entrada. |
| Grok R2, alto; refinamento do coordenador | `queue_free()` ou pausa no callback letal não interrompe o sweep. | **Aceito com ajuste.** O Grok sugeriu marcar `_has_finished` imediatamente. O coordenador preferiu uma flag separada, porque forçar o lifecycle guard pode pular `_finish` e seu sinal/cleanup. Callback de vitória/morte registra pending e só sinaliza parada síncrona. Após callbacks de dano/parry/`bounced`, sweep sai se `_has_finished` ou stop-request. Cleanup e remoção efetiva ficam pós-flush. |
| Grok, alto | UI sem regra de fechamento pode ser dispensada antes da escolha e deixar pausa/porta em estado ambíguo. | **Aceito.** Sem botão de fechar ou dispensa por Esc: tentativa antes da seleção é ignorada e oferta permanece aberta/pausada. Fecha só após seleção válida, morte ou teardown. Morte não libera a porta e segue R; teardown não retoma sala em saída. |
| Grok, médio | Bônus carregado precisa integrar com cálculo de dano e retorno booleano. | **Aceito.** Calcular base +2 antes de `take_damage`; consumir a carga exatamente uma vez após retorno `true`, antes de retornar do acerto; `false` não consome. Somente caminho da própria bola pode usar a carga. |

### Limites e status das fontes

- O Gemini R2 confirmou coerência documental, mas seus riscos de projéteis e overlap foram mantidos como requisitos para implementação futura. Os links `file:///` no corpo do relatório são texto do revisor, não navegação criada pela documentação.
- O Muse R2 não inspecionou código nesta rodada. Na R1, não conseguiu localizar o GDD irmão; essa limitação não prova ausência do arquivo. A referência relativa foi conferida pelo coordenador e aponta ao GDD externo indicado.
- O Grok R2 foi entregue inline, seus achados foram consolidados e os arquivos `.md` e `.stdout.json` estão registrados. Não atribuir a ele validação de código nesta rodada.
- Os bloqueios Opus via AGY e Cursor indicam ausência de parecer, não aprovação. Opus AGY informou reset relativo de 54h34m na execução; Cursor informou ciclo reiniciando em `11/3/2026`. O formato de data Cursor é mantido como recebido, sem interpretação. Não iniciar implementação antes das revisões exigidas, salvo alteração explícita do usuário.

As alterações R2 estão incorporadas em [`plano.md`](../plano.md) e [`spec.md`](../spec.md) v0.3, com v0.2 e v0.1 preservadas em `historico/`. Índices e registros de resultados não criam novas rodadas recursivas de revisão. Esta frente continuou somente documental; não alterou gameplay, não rodou testes/Godot e não atualizou o GDD.

## Confirmação R3 e conclusão do coordenador

Grok, Muse e Gemini confirmaram as correções na v0.3 sem novos achados documentais no material recebido. Os pareceres integrais e suas saídas originais estão em [grok-r3-v0.3.md](grok-r3-v0.3.md), [muse-r3-v0.3.md](muse-r3-v0.3.md) e [gemini-r3-v0.3.md](gemini-r3-v0.3.md). A spec foi fornecida integralmente; no plano foram omitidas apenas decisões/ofertas e roteiro visual, inalterados da v0.2, para respeitar o limite de argumentos do Windows. As afirmações favoráveis dos modelos se limitam à análise documental recebida; não são evidência de gameplay testado ou aprovação do usuário.

A referência do Muse R3 a “HP 5/5” não exige cura na transição: o contrato preserva o HP atual válido do snapshot, com base de 5 HP; somente entrada fresca, payload inválido ou R restauram a fixture de 5 HP. Títulos, IDs e números candidatos não se tornam decisões do usuário pelo vocabulário dos relatórios.

**Resultado:** pasta documental e instruções organizadas; correções incorporadas e confirmadas pelos três revisores disponíveis. Opus 5.5 High via AGY e via Cursor recusaram a execução por quota, sem parecer recebido e sem substituição. A revisão obrigatória está incompleta; a etapa A e as datas do cronograma permanecem condicionadas à obtenção desses pareceres ou a uma mudança explícita de exigência pelo usuário. Nenhuma implementação de gameplay, execução do Godot, teste, commit ou push foi feita nesta tarefa.

Validação documental do coordenador: links locais dos sete documentos autorais atuais conferidos; históricos v0.1 e v0.2 preservam os hashes de suas fontes; AGENTS.md não mudou após R2. Os links e textos históricos dos relatórios originais foram preservados como dados. Fast/priority não pode ser selecionado ou confirmado pela interface disponível de subagentes; GPT-6 Luna xhigh foi usado sem troca de modelo/esforço.

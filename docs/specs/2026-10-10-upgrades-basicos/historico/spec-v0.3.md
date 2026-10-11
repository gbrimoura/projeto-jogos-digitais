# Especificação v0.3: upgrades básicos

**Plano relacionado:** [`plano.md`](plano.md)  
**Estado:** v0.3 consolidada em revisão final; não aprovada para implementação. Opus via AGY e Cursor permanece bloqueado por quota.  
**Escopo:** contrato proposto para o teaser de 14/10/2026. Não atualiza nem fecha regras gerais do GDD.

## 1. Dados e configuração

`UpgradeDefinitionResource` é uma definição somente leitura com `id`, título, ícone, texto e efeitos tipados. IDs: `impacto_reforcado`, `motor_acelerado`, `carga_reativa`.

`RunBuild` é estado transitório próprio da run, mantido por `Main`, raiz da sala. Não usar Autoload ou disco. A v1 tem aquisição única e contagens por ID apenas 0/1. O snapshot de transição sempre **substitui** a build; nunca incrementa contagens existentes.

As configurações-base de movimento e projétil são duplicadas profundamente (`duplicate(true)`) por jogador/bola. Os recursos-base e definições não são alterados. Cada cálculo parte das bases e da build, é idempotente e configura explicitamente o controller. Cada bola recebe sua própria cópia no lançamento. Não é exigida uma refatoração para campos float-only.

| ID | Candidato temporário para teste |
|---|---|
| `impacto_reforcado` | Dano-base da bola 1 → 2. |
| `motor_acelerado` | Recarga-base de dash 0,55 s → 0,40 s. |
| `carga_reativa` | Após parry válido da própria bola, bônus candidato de +2 no próximo dano aceito. |

Os valores acima não são balanceamento confirmado. A v1 não combina upgrades; 2 + 2 = 4 só descreve uma possibilidade futura, fora do aceite.

## 2. Máquina de estado da oferta

Estados: `INATIVA → VITÓRIA_PENDENTE → OFERTA_ABERTA → SELECIONADA → SAÍDA_LIBERADA`, ou `CANCELADA`/`CONCLUÍDA`.

- `Main` recebe `reward_enabled` exportado: `true` na Sala 01, `false` na Sala 02 (terminal sem porta). A lógica não identifica cenas por nome/caminho fixo.
- O primeiro `room_cleared` registra `VITÓRIA_PENDENTE`, mantém a porta bloqueada e solicita apenas uma flag síncrona de parada do sweep da bola própria. Não mutar física/shape/nós, não chamar `queue_free()` nem marcar `_has_finished` nesse callback. Sinais duplicados ou já processados não geram nova oferta. Uma sala que já começa limpa é avaliada uma vez, depois do restore. Após o flush de física, revalidar estado, elegibilidade e jogador vivo. Morte simultânea vence; não oferecer upgrade.
- Após o flush, finalizar/remover a bola própria e limpar todos os projéteis do grupo `hostile_projectile`, incluindo rebites redirecionados, antes de abrir UI ou assumir pausa; isso também vale com `reward_enabled=false`. Se falso, pular a oferta, liberar a porta se existir e marcar `CONCLUÍDA` quando terminal; Sala 02 é terminal sem porta. Nunca deixar `VITÓRIA_PENDENTE` preso. Morte vence: executar cleanup pós-flush e seguir fluxo de morte.
- UI roda em `PROCESS_MODE_WHEN_PAUSED`; gameplay é pausável. `Main` guarda o estado de pausa anterior e só despausa se foi quem pausou. Não há botão de fechar nem dispensa por Esc: tentativa de fechar antes da seleção é ignorada, mantendo `OFERTA_ABERTA` e pausa. A UI fecha somente após seleção válida, morte ou teardown. Morte fecha sem liberar a porta e segue R; teardown fecha sem retomar a sala que está saindo. Limpar somente gate/pausa pertencentes à oferta.
- A seleção precisa estar na lista da oferta, com jogador vivo e estado `OFERTA_ABERTA`. Registrar `SELECIONADA` antes de mudar build ou emitir sinal. Seleção inválida/duplicada é ignorada. Fechar a UI não escolhe.
- Porta E só libera em `SAÍDA_LIBERADA`. E recebido durante a oferta é consumido, não enfileirado; depois da guarda, exige novo pressionamento. Se o jogador já está registrado no overlap da porta, a interação usa esse registro e revalida jogador vivo/em alcance no novo E, sem exigir novo `body_entered`.

`Main` expõe `post_upgrade_input_guard_seconds`, proposta exportada e configurável com padrão de 0,25 s. Após fechar, movimento e mira podem voltar. Somente launch, parry, dash, jump e interact ficam bloqueados: o intervalo quieto começa quando todas essas ações discretas são soltas; cada nova entrada discreta durante a guarda é consumida e reinicia o intervalo. Movimento e mira não contam nem reiniciam. Isso cobre input segurado e clique duplo dentro da guarda sem bloquear para sempre entradas futuras. O valor deve ser observável/configurável.

## 3. Carga da bola

Cada instância de `RicochetBall` tem estados `INATIVA`, `CARREGADA` e `CONSUMIDA`. O snapshot de configuração do lançamento precisa conter `carga_reativa`; uma bola sem esse upgrade nunca energiza, mesmo com parry válido. No máximo uma carga durante toda a vida da bola: um parry aceito da própria bola arma se estiver `INATIVA`; parry durante `CARREGADA` não acumula; parry depois de `CONSUMIDA` não rearma.

A carga termina no primeiro `take_damage` aceito ou quando essa bola termina, expira, é cancelada ou destruída. Não existe timer da carga. Lifetime-base de 2,2 s (valor atual, provisório para balanceamento) conta do lançamento e não reinicia no parry. Bônus, velocidade, ricochetes, colisão e lifetime são campos independentes; a carga não modifica os quatro últimos. Parede/alvo que rejeita dano não consome. Um rebite hostil não arma nem consome carga, ainda que o fluxo compartilhado de parry o redirecione.

Feedback usa visual nativo (arco/Polygon2D/Line2D, conforme a cena), sem nova colisão ou alteração de raio/forma física.

## 4. Contrato de dano e ordem de callbacks

Ambos os inimigos (`RivetWorker` e `TrainingTarget`) implementam:

```gdscript
take_damage(amount: int, source: Node = null) -> bool
```

Retorna `false` para amount não positivo, inimigo derrotado ou HP zero; `true` somente se o HP diminuiu, inclusive dano letal. Emitir `defeated` uma vez. Não introduzir i-frames de inimigos.

Só `RicochetBall` usa esse retorno para consumir sua carga, uma vez e somente em `true`. Se estiver `CARREGADA`, o dano passado é base +2; calcular antes de chamar `take_damage`. Após retorno `true`, consumir a carga exatamente uma vez antes de retornar do acerto; `false` não consome. O hook de carga é o parry aceito no ramo específico da bola, não o callback compartilhado da raquete. Após callbacks externos de `take_damage`, parry e `bounced`, o sweep retorna se `_has_finished` ou `_stop_sweep_requested` estiver ativo. A parada é uma flag síncrona separada do lifecycle guard; não forçar `_has_finished`, que pode pular `_finish`/sinal/cleanup. Callback de vitória ou morte apenas registra pending e pede parada, sem mutar física/nós ou chamar `queue_free()`. Cleanup/cancelamento/remoção efetiva ocorre depois do flush.

## 5. Snapshot e entrada na sala

`RoomTransition` é `RefCounted` e mantém o dicionário estático one-shot que atravessa troca de cena. É o único consumidor. Payload é cópia simples/deep copy, não contém `RunBuild`/`Resource` vivo:

```text
{
  version: 1,
  canonical_destination: String, # res:// canônico de PackedScene.resource_path
  hp_current: int,
  hp_max: int,
  upgrade_ids: Array[String],
  counts_by_id: Dictionary[String, int]
}
```

Validação integral antes de aplicar qualquer estado: `version` inteiro igual a 1; caminho String igual ao `PackedScene.resource_path` canônico `res://`; HP inteiro positivo e `hp_current <= hp_max` (v1 começa com base 5 HP e nenhum upgrade altera HP); IDs String conhecidos e únicos entre `impacto_reforcado`, `motor_acelerado`, `carga_reativa`; dicionário com apenas IDs conhecidos e valores inteiros 0/1; `upgrade_ids` corresponde exatamente aos IDs com contagem 1; soma das aquisições ≤1. Tipos, versão, caminho, ID ou consistência inválidos rejeitam o payload inteiro.

Na origem: pré-carregar/validar `PackedScene`, caminho canônico e conteúdo do snapshot antes de trocar. Se a validação/carga/transição falhar, limpar pending e manter origem jogável com HP/build atuais. Retry faz um payload novo da origem.

No destino: obter uma cópia e limpar o dicionário pending exatamente uma vez, mesmo quando caminho não combina ou payload é inválido (inclusive tipos/versão inválidos). Rejeitar snapshot incompatível; não o manter para uma troca futura. Se não houver snapshot válido, iniciar estado seguro fresco (5 HP, build vazia). Em snapshot válido, restaurar HP e substituir IDs/contagens depois de todos os filhos estarem prontos; reconfigurar explicitamente movimento e lançador a partir das bases duplicadas; somente então verificar se a sala já começa limpa.

## 6. Morte, editor e queda

- Morte descarta build temporária. R limpa pending e reinicia a sala atual com 5 HP/build vazia.
- F6 é o comando do editor “Run Current Scene”, não input de runtime. Uma execução isolada da cena começa sem payload residual, com fixture de 5 HP/build vazia.
- Queda abaixo de `y = 760` chama reset de spawn que cancela a bola. HP e build da run permanecem; carga é descartada junto com a bola.

## 7. Recorte da oferta

Para esta demonstração, somente vitória elegível da Sala 01 abre uma escolha entre três cartões; a Sala 02 demonstra a build e é terminal sem porta, sem recompensa. Aquisição única e rota principal são recortes temporários para o teaser, não decisões gerais de salas, slots ou progressão.

## 8. Matriz de aceite futura

| Dado | Quando | Resultado esperado |
|---|---|---|
| Sala elegível venceu e jogador está vivo | `room_cleared` retorna e o flush termina | Callback só pede stop do sweep; pós-flush finaliza bola própria e limpa todo `hostile_projectile` (inclui rebite redirecionado) antes de abrir oferta/pausar; porta segue bloqueada. |
| Sala não elegível, vitória duplicada/processada ou jogador morto | Evento de conclusão | Nenhuma nova oferta; nenhuma seleção. |
| Sala já começa limpa | Restore terminou; primeira avaliação pendente | Segue uma vez a mesma regra de `reward_enabled` após restore; não é descartada como sinal duplicado. |
| Sala com `reward_enabled=false` conclui | Pós-flush | Mesmo cleanup da bola e de todo `hostile_projectile`; pula oferta, libera a porta se existir; Sala 02 terminal sem porta encerra como `CONCLUÍDA`. |
| Oferta aberta | ID atual válido selecionado | Estado muda para `SELECIONADA` antes do efeito; efeito uma vez; porta libera. |
| Oferta aberta | Botão de fechar/Esc antes de seleção | Tentativa ignorada; oferta permanece aberta e pausada. Só seleção válida, morte ou teardown fecha. Morte não libera porta; teardown não retoma sala em saída. |
| Oferta fechada | Duplo clique/tecla segurada/nova ação discreta; jogador já no overlap da porta | Guarda de `Main.post_upgrade_input_guard_seconds` (padrão 0,25 s) só conta após soltar launch/parry/dash/jump/interact; nova ação discreta consome/reinicia. Movimento/mira não reiniciam. E precisa ser pressionado de novo e consulta overlap já registrado, revalidando vivo/em alcance. |
| Vitória e morte no mesmo flush | Callbacks de combate | Morte prevalece; sem oferta ou aplicação de upgrade. |
| Snapshot de destino válido | Filho já executou `_ready` | Apenas schema v1 integralmente validado é aplicado; HP e build substituídos; controllers reconfigurados antes do teste de sala limpa; pending consumido uma vez. |
| Carga ou caminho do destino inválido antes da troca | Tentar transição | Pending limpo; origem conserva estado e continua jogável. |
| Versão/tipos/HP/IDs/contagens inválidos, pending ausente ou caminho diferente | Entrada da cena | Validar tudo antes de aplicar; pending copiado e limpo uma vez mesmo inválido/mismatch; destino inicia fixture segura 5 HP/build vazia. |
| R / F6 / queda | Reinício, Run Current Scene ou reset abaixo de y=760 | R limpa build/pending e restaura 5 HP; F6 não captura tecla runtime nem herda pending; queda preserva HP/build, cancela bola/carga. |
| Alvo que aceita, recusa, parede ou rebite hostil | Bola própria com upgrade e carga atinge | Só retorno `true` após redução de HP consome bônus; parede/recusa/rebite não. Sem upgrade, parry não arma carga. Uma carga por bola. |
| Parry repetido e callbacks letais | Bola já carregada/consumida ou último inimigo morre | Sem stack/rearme; dano carregado é base+2 antes de `take_damage` e só retorno true consome; parada imediata por flag separada; loop checa `_has_finished`/stop-request e cleanup pós-flush; `defeated` e oferta no máximo uma vez. |
| Build aplicada/recalculada duas vezes | Recriar jogador/bola, transicionar ou reiniciar | Bases `.tres` intactas; saída corresponde à base + IDs, sem drift de configuração. |

Esta rodada só atualiza documentos. Não houve implementação, teste, execução do Godot ou atualização do GDD.

## 9. Fora de escopo e pendências

Sem moeda, loja, raridade, seleção aleatória, slots finais, compra, equipamento permanente, stacks, multiball ou balanceamento final. O [GDD — Combate e Builds](../../../../GDD_Dieselpunk_Noir/04-combate-e-builds.md), snapshot de 03/10, registra build temporária perdida na morte, deixa slots/economia abertos e ainda não inclui esses upgrades. Manter todos os novos valores e o recorte de sala como temporários até revisão e atualização autorizada do GDD. Esta v0.3 aguarda revisão final; não está liberada para implementação.

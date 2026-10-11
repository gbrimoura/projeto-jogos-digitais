# Especificação v0.2: upgrades básicos

**Plano relacionado:** [`plano.md`](plano.md)  
**Estado:** v0.2 congelada para revisão dirigida; não aprovada para implementação.  
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

- `Main` recebe `reward_enabled` exportado: `true` na Sala 01, `false` na Sala 02. A lógica não identifica cenas por nome/caminho fixo.
- O primeiro `room_cleared` registra `VITÓRIA_PENDENTE` e mantém a porta bloqueada. Sinais duplicados ou já processados não geram nova oferta. Uma sala que já começa limpa é avaliada uma vez, depois do restore. Após o flush de física, revalidar estado, elegibilidade e jogador vivo. Morte simultânea vence; não oferecer upgrade.
- Se `reward_enabled=true` e a sala for elegível, só então abrir UI, assumir pausa e cancelar a bola própria de modo adiado. Se `reward_enabled=false`, pular a oferta, limpar projéteis de forma adiada, liberar a porta se existir e marcar `CONCLUÍDA` se a sala for terminal; nunca deixar `VITÓRIA_PENDENTE` preso. Não mutar estado de física dentro do callback/flush. O loop da bola verifica `_has_finished` depois de callbacks de `take_damage`, parry e `bounced`; `queue_free()` não interrompe a função corrente.
- UI roda em `PROCESS_MODE_WHEN_PAUSED`; gameplay é pausável. `Main` guarda o estado de pausa anterior e só despausa se foi quem pausou. Cleanup por saída, morte ou cancelamento fecha a oferta e limpa apenas o gate/pausa de sua propriedade.
- A seleção precisa estar na lista da oferta, com jogador vivo e estado `OFERTA_ABERTA`. Registrar `SELECIONADA` antes de mudar build ou emitir sinal. Seleção inválida/duplicada é ignorada. Fechar a UI não escolhe.
- Porta E só libera em `SAÍDA_LIBERADA`. E recebido durante a oferta é consumido, não enfileirado; depois da guarda de input, exige novo pressionamento em alcance.

Após fechar, movimento pode voltar. Launch, parry, dash, jump e interact ficam bloqueados até as entradas estarem soltas e passar 0,25 s configuráveis sem entrada discreta. Entradas discretas recebidas durante a guarda são consumidas e reiniciam o prazo. Isso cobre input segurado e duplo clique dentro da guarda sem bloquear para sempre entradas futuras. O valor deve ser observável/configurável.

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

Só `RicochetBall` usa esse retorno para consumir sua carga, uma vez e somente em `true`. O hook de carga é o parry aceito no ramo específico da bola, não o callback compartilhado da raquete. Revalidar `RicochetBall._has_finished` após cada callback externo e encerrar o sweep se a bola terminou, a sala venceu ou o jogador morreu. Limpeza de bola pela vitória ocorre depois do callback/flush.

## 5. Snapshot e entrada na sala

`RoomTransition` é `RefCounted` e mantém o dicionário estático one-shot que atravessa troca de cena. É o único consumidor. Payload é cópia simples/deep copy, não contém `RunBuild`/`Resource` vivo:

```text
{ version, canonical_destination, hp_current, hp_max,
  upgrade_ids, counts_by_id }  # contagem por ID: 0 ou 1
```

Na origem: pré-carregar/validar o `PackedScene`, caminho canônico e conteúdo do snapshot antes de trocar. Se a validação/carga/transição falhar, limpar pending e manter origem jogável com HP/build atuais. Retry faz um payload novo da origem.

No destino: obter uma cópia e limpar o dicionário pending exatamente uma vez, mesmo quando caminho não combina ou payload é inválido. Rejeitar snapshot incompatível; não o manter para uma troca futura. Se não houver snapshot válido, iniciar estado seguro fresco (5 HP, build vazia). Em snapshot válido, restaurar HP e substituir IDs/contagens depois de todos os filhos estarem prontos; reconfigurar explicitamente movimento e lançador a partir das bases duplicadas; somente então verificar se a sala já começa limpa.

## 6. Morte, editor e queda

- Morte descarta build temporária. R limpa pending e reinicia a sala atual com 5 HP/build vazia.
- F6 é o comando do editor “Run Current Scene”, não input de runtime. Uma execução isolada da cena começa sem payload residual, com fixture de 5 HP/build vazia.
- Queda abaixo de `y = 760` chama reset de spawn que cancela a bola. HP e build da run permanecem; carga é descartada junto com a bola.

## 7. Recorte da oferta

Para esta demonstração, somente vitória elegível da Sala 01 abre uma escolha entre três cartões; a Sala 02 demonstra a build e não oferece recompensa no terminal. Aquisição única e rota principal são recortes temporários para o teaser, não decisões gerais de salas, slots ou progressão.

## 8. Matriz de aceite futura

| Dado | Quando | Resultado esperado |
|---|---|---|
| Sala elegível venceu e jogador está vivo | `room_cleared` retorna e o flush termina | Oferta abre uma vez; porta ainda bloqueada; bola própria cancelada sem mutação durante flush. |
| Sala não elegível, vitória duplicada/processada ou jogador morto | Evento de conclusão | Nenhuma nova oferta; nenhuma seleção. |
| Sala já começa limpa | Restore terminou; primeira avaliação pendente | Segue uma vez a mesma regra de `reward_enabled` após restore; não é descartada como sinal duplicado. |
| Sala com `reward_enabled=false` conclui | Pós-flush | Pula oferta, limpa projéteis, libera a porta se existir; sem porta, encerra como `CONCLUÍDA`. |
| Oferta aberta | ID atual válido selecionado | Estado muda para `SELECIONADA` antes do efeito; efeito uma vez; porta libera. |
| Oferta aberta/fechando | Fechar, E, clique duplo, botão/tecla segurado | Sem seleção fantasma, sem transição E enfileirada, sem ação de gameplay durante a guarda. |
| Vitória e morte no mesmo flush | Callbacks de combate | Morte prevalece; sem oferta ou aplicação de upgrade. |
| Snapshot de destino válido | Filho já executou `_ready` | HP e build são substituídos; controllers reconfigurados antes do teste de sala limpa; pending consumido uma vez. |
| Carga ou caminho do destino inválido antes da troca | Tentar transição | Pending limpo; origem conserva estado e continua jogável. |
| Pending ausente, inválido ou destinado a outro caminho no destino | Entrada da cena | Pending limpo mesmo assim; destino inicia fixture segura 5 HP/build vazia. |
| R / F6 / queda | Reinício, Run Current Scene ou reset abaixo de y=760 | R limpa build/pending e restaura 5 HP; F6 não captura tecla runtime nem herda pending; queda preserva HP/build, cancela bola/carga. |
| Alvo que aceita, recusa, parede ou rebite hostil | Bola própria com upgrade e carga atinge | Só retorno `true` após redução de HP consome bônus; parede/recusa/rebite não. Sem upgrade, parry não arma carga. Uma carga por bola. |
| Parry repetido e callbacks letais | Bola já carregada/consumida ou último inimigo morre | Sem stack/rearme; loop para após `_has_finished`; `defeated` e oferta no máximo uma vez. |
| Build aplicada/recalculada duas vezes | Recriar jogador/bola, transicionar ou reiniciar | Bases `.tres` intactas; saída corresponde à base + IDs, sem drift de configuração. |

Esta rodada só atualiza documentos. Não houve implementação, teste, execução do Godot ou atualização do GDD.

## 9. Fora de escopo e pendências

Sem moeda, loja, raridade, seleção aleatória, slots finais, compra, equipamento permanente, stacks, multiball ou balanceamento final. O [GDD — Combate e Builds](../../../../GDD_Dieselpunk_Noir/04-combate-e-builds.md), snapshot de 03/10, registra build temporária perdida na morte, deixa slots/economia abertos e ainda não inclui esses upgrades. Manter todos os novos valores e o recorte de sala como temporários até revisão e atualização autorizada do GDD.

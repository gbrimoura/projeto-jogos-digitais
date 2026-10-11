# Plano v0.2: upgrades básicos para o teaser

**Estado:** v0.2 congelada para revisão dirigida; não aprovada para implementação.  
**Data:** 10/10/2026. **Entrega-alvo confirmada pelo usuário:** teaser de aproximadamente 60 segundos na quarta-feira, 14/10/2026.  
**Estimativa:** 13–18 horas técnicas, sem incluir filas de revisão externa nem edição do vídeo; pode mudar após as revisões e validações.

## Objetivo e decisões

O usuário confirmou o formato de teaser, uma escolha entre três após a vitória de uma sala e a mecânica de energizar a própria bola depois de um parry bem-sucedido. A magnitude numérica do bônus e a distribuição de recompensas descritas abaixo são propostas de teste, não regras gerais do jogo.

### Recorte temporário proposto para o teaser

- Somente a Sala 01 abre a oferta; a Sala 02 demonstra a escolha. Nesta v1, a aquisição é única por run e o terminal da Sala 02 não oferece recompensa. Esse recorte não define progressão universal.
- A porta E só libera depois de uma seleção válida. A porta não controla nem aplica upgrades.
- Os valores candidatos permanecem provisórios:

| Cartão | Valor de teste proposto | Limite |
|---|---|---|
| Impacto Reforçado | Dano-base da bola 1 → 2. | Não muda velocidade, ricochete, colisão nem raio. |
| Motor Acelerado | Recarga do dash 0,55 s → 0,40 s. | Recalcular da base; nunca aplicar sobre valor já modificado. |
| Carga Reativa | Parry da própria bola a energiza; candidato de +2 no próximo dano aceito. | Bônus +2 é número de teste. Uma carga no máximo por vida daquela bola; não rearma depois de consumida. |

Não permitir aquisições combinadas na v1. Se uma versão futura as combinar, 2 de dano-base mais bônus 2 resultaria em 4; isso é hipótese futura, fora do aceite atual. Não inventar slots adicionais, moeda, raridade, escolha aleatória ou stacks.

## Contrato da bola energizada

Estado por instância da bola: `INATIVA → CARREGADA → CONSUMIDA`. Só uma bola cuja configuração de lançamento inclui `carga_reativa` pode armar; parry válido de bola sem esse upgrade não energiza. Um parry aceito da própria bola pode armar uma única carga enquanto está `INATIVA`. Enquanto `CARREGADA`, novo parry não acumula nem rearma. Depois de `CONSUMIDA`, outro parry não reativa a carga naquela bola.

A carga termina no primeiro dano aceito pelo inimigo ou quando a própria bola acaba, expira, é cancelada ou destruída. **Não há timer separado para a carga.** O lifetime-base da bola (2,2 s no protótipo atual) é contado desde o lançamento; o parry preserva o tempo restante e nunca reinicia o lifetime. A carga não altera velocidade, colisão, ricochetes ou lifetime. Parede e alvos que rejeitem dano não consomem. Rebites hostis não ganham nem consomem a carga, mesmo se forem redirecionados.

## Arquitetura e fluxo propostos

### Build e configuração

- `Main`, raiz da cena de sala, mantém `RunBuild` transitório da run; sem Autoload e sem gravação em disco. `RunBuild` guarda IDs próprios e contagens 0/1.
- `UpgradeDefinitionResource` contém somente ID, título, ícone, texto e efeitos tipados. Não guardar estado de run nem mutar definições.
- Duplicar profundamente (`duplicate(true)`) recursos-base de movimento e projétil por jogador/bola. Derivar parâmetros sempre da base e da build, com recálculo idempotente; não exigir refatoração para campos float-only.
- Atribuir cópia de configuração a cada bola no lançamento. Bases permanecem intactas após reaplicação, morte e reload.

### Snapshot one-shot entre cenas

`RoomTransition` é `RefCounted` e usa o dicionário estático de transferência entre mudanças de cena. É o único consumidor do snapshot. O snapshot é cópia profunda e simples, nunca uma instância viva de `RunBuild` ou `Resource`:

```text
{ version, canonical_destination, hp_current, hp_max,
  upgrade_ids, counts_by_id }  # cada contagem é 0 ou 1
```

Antes da troca, carregar e validar `PackedScene`, caminho canônico e payload. Se a validação ou a troca falhar, limpar o pending e manter a sala de origem jogável com HP e build atuais. Em qualquer leitura de destino, copiar o pending e limpá-lo exatamente uma vez, inclusive se o caminho não corresponder ou o payload for inválido; não reter payload incompatível. Destino com payload inválido inicia em estado seguro fresco (5 HP, build vazia).

Depois que os filhos estiverem prontos, restaurar HP e **substituir** IDs/contagens (não incrementar), reconfigurar explicitamente movimento e lançador com as bases duplicadas, e só então avaliar uma sala que já comece limpa. Essa ordem cobre o `_ready` dos filhos que já configurou o jogador. Uma entrada direta pelo editor sem payload usa fixture padrão.

### Vitória, oferta e pausa

Usar `reward_enabled` exportado em `Main` (`true` na Sala 01, `false` na Sala 02), sem codificar um caminho de cena na lógica de oferta. Estados: `INATIVA → VITÓRIA_PENDENTE → OFERTA_ABERTA → SELECIONADA → SAÍDA_LIBERADA`, com saída alternativa para `CANCELADA` ou `CONCLUÍDA`.

`room_cleared` pode ser síncrono dentro do callback do golpe letal. Nesse callback, apenas registrar a primeira vitória pendente e manter a porta bloqueada. Depois do flush de física, revalidar jogador vivo, sala limpa, configuração de recompensa e estado. Vitória duplicada ou já processada não abre oferta. Uma sala que já começa limpa é avaliada uma vez, só depois do restore. Se elegível e sem oferta anterior, cancelar a bola própria, abrir UI/pausa e congelar gameplay. Se `reward_enabled` for falso, pular a oferta, limpar projéteis de forma adiada, liberar a porta se houver e marcar a sala `CONCLUÍDA` quando for terminal (a Sala 02 atual não tem porta). Não deixar `VITÓRIA_PENDENTE` sem saída. Não mutar física durante o flush. A bola deve verificar `_has_finished` após callbacks externos de dano, parry ou `bounced` e parar o loop corrente; `queue_free()` por si só não interrompe a função. Se morte e vitória coincidirem, morte vence e não há oferta.

A UI usa `PROCESS_MODE_WHEN_PAUSED`; gameplay é pausável. `Main` registra o estado de pausa anterior e só despausa se ele próprio iniciou a pausa. Morte, saída ou cancelamento fecham a UI e limpam apenas o estado de pausa/input que pertencem à oferta. Se a árvore já estava pausada por outro dono, a oferta não a despausa.

Registrar a seleção válida e mudar para `SELECIONADA` **antes** de aplicar efeito ou emitir sinais. IDs inválidos/fora da oferta são ignorados. Fechar a UI não escolhe. Porta só libera em `SAÍDA_LIBERADA`; E durante a oferta é consumido e não fica enfileirado.

O evento de seleção/fechamento não pode virar arremesso, parry, dash, pulo ou E. Ao fechar, movimento pode voltar; bloquear essas ações discretas até os botões/teclas serem soltos e haver 0,25 s configuráveis sem nova entrada discreta. Qualquer entrada durante essa guarda é consumida e reinicia a espera. Após a guarda, uma entrada nova é intencional; não prometer bloqueio ilimitado de cliques futuros. Testar clique duplo de seleção, tecla/botão segurado, segunda entrada durante a guarda e E durante a oferta.

### Dano e callbacks

Refatoração obrigatória para ambos os inimigos (`RivetWorker` e `TrainingTarget`): `take_damage(amount: int, source: Node = null) -> bool`. Retornar `false` para amount não positivo, inimigo já derrotado ou HP já zero; `true` somente quando o HP diminuiu, inclusive no golpe letal. Emitir `defeated` uma única vez. Não adicionar i-frames aos inimigos.

Somente o caminho de acerto de `RicochetBall` consome a sua carga, e apenas uma vez após retorno `true`. Armar no ramo de parry aceito da própria `RicochetBall`, nunca no callback de sucesso compartilhado da raquete que também atende rebites hostis. Revalidar o estado da bola depois de callback externo. Vitória cancela a bola própria de forma adiada, depois do callback/flush.

### Arquivos candidatos

Novos: `UpgradeDefinitionResource`, `RunBuild`, três recursos de definição e uma cena/script nativo da escolha. Existentes a inspecionar durante implementação: `Player`, `BallLauncher`, `MovementController`, `Main`, `RoomTransition`, `CombatRoom`, `ExitDoor`, `RacketController`, `RicochetBall` e sua cena, `RivetWorker`/`TrainingTarget` e suas cenas, e HUD. A lista é proposta, não autorização para tocar todos os arquivos; fechar o escopo após inspeção. A frente de geração procedural permanece separada e requer coordenação para qualquer integração.

## Reinício e queda

- Morte descarta build temporária. R limpa o pending estático e recarrega a sala atual com 5 HP/build vazia.
- F6 significa apenas “Run Current Scene” do editor Godot: entrada direta em nova execução deve começar com fixture fresca (5 HP, build vazia). Não mapear nem capturar F6 como tecla de runtime.
- Cair abaixo de `y = 760` chama o reset de spawn já usado, que cancela a bola e descarta sua carga. Preservar HP e build da run.

## Etapas, revisões e cronograma

Cada incremento A/B/C deve ser estabilizado e passar pelas três revisões externas e Claude Opus 5.5 High via Cursor antes de avançar sua entrega. Não concentrar todas as revisões no dia anterior ao vídeo.

| Data | Etapa e saída |
|---|---|
| Sáb. 10/10 | Revisão do plano v0.2 e síntese dos pareceres v0.1. |
| Dom. 11/10 | A — recursos, `RunBuild`, snapshot/transição; revisão após estabilizar A. |
| Seg. 12/10 | B — UI, pausa, input e porta; revisão após estabilizar B. |
| Ter. 13/10 | C — carga e integração; revisão após estabilizar C. Buffer para correções e re-revisões, atualizar o GDD, validação autorizada no Godot e preparação/captura. |
| Qua. 14/10 | Edição e entrega do teaser. |

Estimativa de 13–18 horas cobre trabalho técnico inicial, não filas das revisões nem edição. Ajustar o escopo e a estimativa se revisões ou validação excederem a janela; não inventar horário de code freeze.

## Roteiro visual proposto (não é critério funcional)

| Tempo | Cena |
|---|---|
| 0–6 s | Gancho: parry e bola própria energizada atingindo um inimigo. |
| 6–20 s | Movimento, dash, ricochete e aviso de ataque. |
| 20–30 s | Vitória da Sala 01 e três cartões. |
| 30–36 s | Seleção e abertura da porta. |
| 36–52 s | Demonstração da build na Sala 02. |
| 52–60 s | Título e “em desenvolvimento”. |

Não apresentar moeda, lojas, raridade, slots finais, seleção aleatória ou ideias futuras como recursos já implementados.

## Aceite futuro e validações planejadas

Esta rodada altera só documentação; nada foi implementado nem executado no Godot. Para implementação futura, validar:

- Uma única oferta para vitória válida e elegível com `reward_enabled`; não abrir por vitória duplicada/processada ou jogador morto. Uma sala já limpa só é avaliada após restore. Com `reward_enabled=false`, pular oferta, limpar projéteis e liberar porta existente (ou concluir sem porta).
- Seleção válida é aplicada exatamente uma vez antes do efeito. Invalidar IDs fora da oferta. Fechar não seleciona, clique duplo não repete seleção nem lança, e E não transiciona automaticamente.
- Morte durante oferta cancela seleção, fecha UI e respeita propriedade da pausa; morte vence se coincide com vitória.
- Snapshot deep-copy aplica HP/build uma vez, substitui contagens e reconfigura controllers após `_ready` dos filhos e antes do caso sala já limpa. Falha anterior à troca mantém origem; snapshot inválido/mismatched no destino é limpo e resulta em fixture segura.
- R/reload limpa pending, HP volta a 5 e build fica vazia. F6 executa cena isolada com fixture fresca. Queda preserva HP/build e cancela a bola/carga.
- Duplo clique, tecla pressionada, novas entradas na guarda de 0,25 s e E durante oferta; movimento retoma após fechar, ações discretas só depois de soltar e passar a guarda.
- `take_damage` retorna false sem perda de HP, true após redução e `defeated` uma vez; carga consome uma vez em hit aceito, não em parede/alvo que recusa/rebite hostil.
- Só bola lançada com upgrade `carga_reativa` pode energizar; parry repetido não empilha nem rearma após consumo. O lifetime da bola continua desde lançamento e seus speed/bounces/colisões/lifetime não mudam. Callback letal não deixa o sweep continuar após `_has_finished`.
- Configurações-base intactas e derivação idempotente após escolha, transição, R e nova instância; recurso visual de carga não cria/edita colisão.

## Dependências e pendências

- v0.2 aguarda revisão dirigida e síntese; não autoriza implementação.
- Fazer validações de runtime e atualizar o GDD apenas na frente de implementação autorizada.
- O snapshot do GDD de 03/10 descreve build temporária que se perde na morte, deixa slots e economia em aberto e ainda não registra estes upgrades. O recorte e os valores do teaser devem permanecer identificados como proposta até atualização/revisão do GDD.
- Referência: [GDD — Combate e Builds](../../../../GDD_Dieselpunk_Noir/04-combate-e-builds.md).

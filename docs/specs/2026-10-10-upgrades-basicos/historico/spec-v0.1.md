# Especificação: upgrades básicos

**Plano relacionado:** [`plano.md`](plano.md)  
**Estado:** proposta v0.1 em revisão; números e regras de recorte ainda não são decisões gerais do jogo.

## 1. Modelo de dados

### `UpgradeDefinitionResource`

Recurso de definição somente leitura, com no mínimo:

- `id` estável e único;
- título, ícone e texto curto para o cartão;
- lista de efeitos tipados, sem lógica de estado da run dentro do recurso.

Definições iniciais: `impacto_reforcado`, `motor_acelerado` e `carga_reativa`. A oferta apresenta três IDs distintos; a seleção deve corresponder a um ID da oferta atual.

### `RunBuild`

Estado transitório da run, mantido pela raiz da partida, sem Autoload ou gravação em disco. Guarda as melhorias próprias e contagem por ID. Na v1, cada ID pode aparecer no máximo uma vez e o jogador escolhe somente uma melhoria na oferta da Sala 01.

## 2. Efeitos e ordem de cálculo

| ID | Regra candidata |
|---|---|
| `impacto_reforcado` | Cada bola lançada com essa build recebe dano-base 2 em vez de 1. |
| `motor_acelerado` | Dash usa recarga 0,40 s em vez da base provisória de 0,55 s. |
| `carga_reativa` | Parry bem-sucedido da própria bola concede uma carga de dano +2 por 2,2 s. O primeiro dano aceito por inimigo recebe o bônus; a carga então termina. |

Configurações devem ser derivadas das bases, sem escrever valores modificados de volta nas definições ou nos objetos-base. Cada bola recebe uma cópia de configuração no lançamento. Se futuras versões combinarem as duas melhorias de dano, a proposta dá 2 + 2 = 4 no primeiro acerto carregado; a v1 não permite adquirir ambas.

## 3. Ciclo da oferta

Estados sugeridos: `inativa` → `oferta_aberta` → `selecionada` → `saída_liberada`.

1. `Main` confirma que o jogador está vivo e que a Sala 01 emitiu conclusão uma única vez.
2. `Main` pausa/congela o gameplay e bloqueia inputs de movimento, pulo, dash, arremesso e raquete.
3. A interface mostra três cartões. Mouse e foco/teclado podem selecionar; nenhuma seleção ocorre por fechamento.
4. Ao receber um ID presente na oferta, estando vivo, com sala concluída e na fase correta, `Main` aplica o efeito uma única vez, fecha a oferta e libera a saída.
5. Inputs de clique ou tecla iniciados durante a oferta não podem vazar para gameplay no frame de fechamento.

`ExitDoor` não cria nem aplica melhorias. A porta só recebe a liberação e solicita a transição por E quando o jogador está no alcance.

## 4. Carga de parry

- Origem válida: somente bola própria, após parry aceito pelo fluxo normal de parry.
- Uma carga por bola. Outro parry durante a carga mantém o valor e o prazo atuais; não acumula nem renova a duração.
- Alvo válido: primeiro inimigo que aceitar dano. Sugere-se retorno `bool` na API de dano para distinguir aplicação de rejeição.
- Parede, alvo inválido, dano recusado e rebite hostil não consomem carga.
- Carga acaba após o dano aceito ou quando a bola termina/é destruída. A duração de 2,2 s também a expira.
- Efeito visual: brilho/aro nativo da cena; não alterar forma, raio, colisão, velocidade ou número de ricochetes.

## 5. Transição, morte e reinício

- `RoomTransition` é o consumidor único do snapshot de HP e build, associado a `PackedScene.resource_path` canônico para aceitar cena referenciada por UID.
- Validar e reconstruir a build antes de recalcular configuração e só consumir o payload quando a carga de destino puder ser aplicada. Em falha, preservar a origem jogável e remover o payload de uso único; uma nova tentativa não duplica os efeitos.
- Ao entrar na Sala 02, restaurar a build a partir do snapshot antes da configuração de movimento/projéteis e antes de processar sala que já comece limpa.
- Morrer descarta a build temporária. R recarrega a sala atual com 5 HP e build vazia. F6 inicia a fixture com 5 HP/build vazia.
- Queda abaixo de `y = 760` reposiciona o jogador no spawn atual, preservando HP e build.

## 6. Proposta de recompensa por sala

Para o teaser e a v1 deste recorte, a seleção acontece depois da Sala 01 e é demonstrada na Sala 02. A recompensa aparece apenas pela rota principal; o terminal da Sala 02 não oferece recompensa. Isso é uma exceção de escopo para esta demonstração, não uma decisão sobre todas as salas ou progressão futura.

## 7. Casos de aceite e borda

- Oferta não abre em sala não concluída, jogador morto ou segunda emissão de conclusão.
- ID não oferecido, seleção duplicada ou seleção recebida em outra fase não altera a build.
- Fechar/tentar fechar, clicar duas vezes, manter botão pressionado ou apertar ação de gameplay não escolhe novamente nem executa a ação depois da oferta.
- Morte durante a oferta fecha a UI e limpa estado de pausa/input antes do reinício.
- Falha ao carregar destino não perde o HP/build corrente nem duplica a aplicação no retry.
- Carga respeita alvo que rejeita dano, parede, expiração, múltiplos parries, fim da bola e limpeza ao vencer/morrer.
- Efeitos só mudam os parâmetros especificados; parry, ricochete, colisão e rebite hostil mantêm seu comportamento vigente.

## 8. Fora de escopo e decisões abertas

Sem implementação de moeda, lojas, raridade, escolha aleatória, slots finais, compras, equipamento permanente ou acúmulos. A quantidade de slots e outras pendências do GDD seguem abertas. Validar no Godot valores, pausa, persistência durante transição, brilho e timing antes de tratar a proposta como balanceamento fechado.

# Especificação — geração coordenada de salas

**Estado:** implementação autorizada em 18/10/2026; runtime não verificado.  
**Base de trabalho:** estado local de `corrigir-sprites-salas-plataformas`, incluindo alterações sem commit da tarefa anterior.

## Contrato de layout

- Viewport: 1152×648. Paredes físicas e visuais: x=0..64 e x=1088..1152. Piso: centro (576,604), tamanho 1152×88, topo y=560.
- Teto: uma única linha de 18 colunas de 64 px (32 px da fonte) cobre x=0..1152, y=0..64. Usa `terrain_top_mid` do atlas da fábrica em nearest e espelhado verticalmente, com a face acabada para baixo. `CeilingBand` usa shape físico 1152×64 em (576,32), encostado ao teto existente y=-32..0. O visual é desenhado depois das duas paredes para fechar os cantos.
- As fixtures atuais mantêm três plataformas, sem instituir contagem final. O helper aceita tecnicamente 2..5 plataformas. Largura por plataforma é múltipla de 8, limitada a 104..216; espessura 24. Na fixture atual, os sorteios buscam 160..216; o fallback visual de três plataformas usa posições (324,452)/(596,412)/(860,388) e dimensões 200×24/184×24/184×24.
- A rota é ordenada por X. A primeira plataforma tem topo y=440. Cada etapa pode manter a altura ou subir; a subida acumulada de toda a rota é limitada a 64 px, até y=376. Vãos entre bordas são 56..96 px. A primeira borda fica entre x=208..256 e pelo menos 24 px depois do limite direito do collider do spawn. A última borda termina até x=980, antes da área da saída. Nenhuma plataforma cruza paredes x=64..1088 ou se sobrepõe positivamente a outra.
- Bottom de todas as plataformas é no máximo y=464; a folga até o piso é pelo menos 96 px. A primeira plataforma fica 120 px acima do piso. A cápsula do Player tem 76 px de altura e o bounds de patrulha móvel do RivetWorker tem 64 px conforme as cenas atuais; a folga é margem geométrica, não promessa de navegação. A rota sem dash é uma intenção de layout, não um teste de salto: a primeira subida de 120 px fica 8 px abaixo do limite teórico de salto 128, sem garantia de alcançabilidade real.

## Seed, aplicação e validação

`room_layout_seed = 0` cria um RNG local randomizado uma vez por instância. Um valor diferente de zero define a seed diretamente e reproduz posições, larguras e alturas. O helper mantém um único RNG para todo o layout. O preparo acontece em `_enter_tree` standalone ou por `configure_run_managed` antes de adicionar a sala ao container; posições, `size` e shapes locais são aplicados antes de `_ready`. Quando a sala managed entra na árvore, o preparo idempotente não sorteia novamente. O seed usado fica registrado no Main.

O gerador limita tentativas a 32 e então retorna fallback seguro declarado. As três posições de fallback são as posições do preview acima. Se ainda não houver layout válido, managed recebe falha de configuração antes de adicionar a sala; standalone desativa gameplay e mostra overlay de erro, preservando os gates existentes.

A validação lê os shapes físicos e AABBs após a aplicação, inclusive a forma local sincronizada pelo setter `SolidPlatform.size` → `_sync_geometry`; shapes retangulares compartilhados são duplicados para a cena local quando necessário. Os AABBs são construídos em coordenadas locais à raiz `Main`, por composição de transforms, sem queries físicas globais. As exports `randomize_position` e `randomize_width` já existentes são desligadas nas instâncias; as cenas serializam ambas como `false`. Confere limites, margens de spawn, corredor do chão, gaps, subida acumulada máxima, ausência de sobreposição, spawns do Player e RivetWorker, patrulha, teto e suporte do alvo. O primário do `TrainingTarget` é o último suporte na ordem X (o mais alto quando há subida; empates permanecem no último elemento); fallback é o primeiro à esquerda. Ambos são conferidos quanto a contato e margem lateral de 8 px. O posicionamento continua determinístico e não usa o RNG deferido do alvo.

As fixtures `Main` e `SecondRoom` usam ambas `scripts/world/main.gd`. A resolução da porta de saída é pelo caminho exato `ExitDoor`; não usa grupo ou procura por tipo que possa selecionar a `EntranceDoor`.

## Portas

Cada fixture contém `EntranceDoor` e `ExitDoor`. A entrada reutiliza `exit_door.tscn`, fica em (112,522), possui sensor desativado, não interage e não conecta sinal de transição; sua apresentação informa entrada bloqueada. A saída reutiliza a mesma cena em (1040,522), conserva o sensor em x=992..1088 e não abre a parede.

`ExitDoor` libera apenas após sala limpa e recompensa concluída. A guarda pós-recompensa mantém a saída fechada até terminar; seleção de recompensa E não aciona porta. Main valida E com estado liberado, clear, jogador correto/vivo, guarda encerrada e jogador no sensor, e repete as condições no deferred. Falha deferred limpa a ocupação para nova interação, sem emitir progressão; se o jogador morreu ou a sala deixou de estar limpa, a porta volta a trancar.

Em modo managed, Main mantém a porta visível e emite `run_progression_ready` no máximo uma vez depois das validações; RunController avança a run preservando HP/build. Falha de layout managed retorna erro antes de adicionar a instância: RunController a libera e chama `_fail_run`, que atualiza o HUD com erro e opção de reinício existente. Não remover a porta nem trocar a cena diretamente. Em Main standalone, manter `RoomTransition` e snapshot explícito de HP/build ao ir para SecondRoom. Em SecondRoom standalone, a saída finaliza a etapa e apresenta `ETAPA CONCLUÍDA`, sem destino vazio, estado `ABRINDO SAÍDA...` permanente ou loop; em managed, segue a progressão normal do controlador.

## Compatibilidade e limites

Preservar spawns, patrulha, parede contínua, colisões/layers/masks, fluxo de recompensa, HP/build, lançamento/parry/movimento e RoomController. O atlas não é alterado. O usuário confirmou em 18/10 que os sprites voltaram a funcionar; import de sprites de inimigos permanece fora da tarefa.

A especificação do GDD em `GDD_Dieselpunk_Noir/04-combate-e-builds.md` §§1, 3, 9 e 11 descreve o papel de portas, fluxo e integração futura da geração no controlador; não define algoritmo nem quantidade final. A proposta de 16/10 permanece histórica, sem reescrita.

Nenhum Godot, import, teste ou QA foi executado. Permanecem sem comprovação: alcance real dos saltos, leitura do teto/portas em jogo e comportamento integrado no runtime.

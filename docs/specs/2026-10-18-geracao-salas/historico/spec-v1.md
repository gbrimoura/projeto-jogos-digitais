# Especificação — geração coordenada de salas

**Estado:** implementação autorizada em 18/10/2026; comportamento de runtime não verificado.  
**Base de trabalho:** estado local de `corrigir-sprites-salas-plataformas`, incluindo alterações sem commit da tarefa anterior.

## Contrato de layout

- Viewport: 1152×648. Paredes físicas e visuais: x=0..64 e x=1088..1152. Piso: centro (576,604), tamanho 1152×88, topo y=560.
- Teto: faixa visual x=0..1152, y=0..64, usando o tile repetível `terrain_top_mid` do atlas da fábrica em nearest e espelhado verticalmente para terminar na face inferior. A colisão nova ocupa exatamente y=0..64 e conecta ao teto existente em y=-32..0.
- Plataformas do conjunto atual: largura gerada em múltiplos de 8, entre 160 e 216; espessura 24. A primeira tem topo y=440. As seguintes não descem em relação à anterior e podem subir em passos de 8 até 64 px, nunca excedendo 80 px por etapa nem o topo y=376.
- A rota em x é ordenada. Vãos entre bordas ficam entre 56 e 96 px. A primeira borda começa pelo menos 24 px depois do limite direito da cápsula no marcador de spawn; a última borda termina até x=980, antes da área da saída. Nenhuma plataforma cruza x=64..1088.
- Bottom de todas as plataformas é no máximo y=464; a folga até o piso é pelo menos 96 px. Isso mantém o corredor contínuo no chão. A rota do piso à primeira plataforma sobe 120 px. A estimativa balística não comprova alcançabilidade real; sem runtime, o requisito “sem dash” permanece pendente de conferência manual.
- A contagem é lida das plataformas presentes nas salas; três por fixture são uma escolha provisória da composição atual, não a contagem final. Layouts com contagem não suportada pelo fallback são rejeitados com erro explícito, sem alterar a composição das salas nesta tarefa.

## Seed, aplicação e validação

`room_layout_seed = 0` cria e randomiza um RNG local uma vez por instância. Um valor diferente de zero define a seed diretamente e reproduz posições, larguras e alturas. Um único RNG coordena todos os sorteios daquele layout. O helper limita tentativas; ao esgotá-las, retorna um layout seguro fixo e validável. Se o fallback falhar, a sala é inválida antes do combate.

O gerador retorna dados locais por plataforma. Main aplica posição, tamanho e `RectangleShape2D` local antes de `add_child`/`_ready`, desligando `randomize_position` e `randomize_width` nas instâncias gerenciadas. O preparo idempotente registra seed usada, retângulos e posição do alvo. A validação usa shapes físicos e AABBs reais, rejeita interseções positivas entre plataformas, invasão de limites, obstrução dos spawns/patrulha e suporte do alvo sem margem lateral de 8 px ou contato vertical. O alvo continua fixo no suporte escolhido, sem RNG deferido. O suporte primário usa a plataforma mais alta da rota; fallback usa a primeira.

## Portas

Cada fixture contém `EntranceDoor` e `ExitDoor`. A entrada reusa o visual existente, fica em (112,522), tem collider do sensor desativado e nunca conecta `transition_requested`; sua função é somente marcar a extremidade de entrada. A saída reutiliza `exit_door.tscn`, fica em (1040,522), conserva o sensor em x=992..1088 e não abre a parede.

`ExitDoor` só é liberada depois da limpeza da sala e da conclusão da recompensa. A guarda de input pós-recompensa mantém a porta bloqueada até acabar, impedindo que o mesmo E escolha recompensa e atravesse a saída. Main revalida no pedido e na chamada deferred: estado de saída liberada, sala limpa, jogador correto e vivo, guarda encerrada e jogador ainda no sensor.

Em modo managed, Main marca a porta ocupada e emite `run_progression_ready` no máximo uma vez; RunController continua sendo responsável por avançar a run e preservar HP/build. Não remover a porta nem trocar a cena diretamente. Em standalone Main, manter `RoomTransition` e o caminho para SecondRoom. Em standalone SecondRoom, interação finaliza a etapa e atualiza a apresentação para `ETAPA CONCLUÍDA`, sem tentar carregar caminho vazio; em managed, a mesma saída segue a progressão normal do controlador.

## Compatibilidade visual e de combate

Preservar spawns de Player e RivetWorker, patrulha, geometria de parede/piso, colisões, layers/masks, fluxo de recompensas, HP/build, lançamento/parry/movimento e parede contínua atrás da saída. A entrada fica visualmente distinta e sem trigger, mesmo com o jogador surgindo perto dela. O atlas não é alterado; nenhuma investigação ou import de sprites faz parte desta tarefa. O usuário confirmou em 18/10 que os sprites voltaram a funcionar.

## Referências e limites

`GDD_Dieselpunk_Noir/04-combate-e-builds.md` §§1, 3, 9 e 11 descreve o papel da porta, o fluxo de sala e a integração futura da geração no controlador; algoritmo, quantidade final de plataformas e regras procedurais continuam pendentes. Este incremento não os fecha. A spec/plano de 16/10 permanece histórica, sem reescrita.

Não executar Godot, import, testes ou QA neste incremento. Permanecem sem comprovação: alcance real dos saltos, conforto do corredor com bounds visuais, leitura do teto/portas em jogo e comportamento integrado no runtime.

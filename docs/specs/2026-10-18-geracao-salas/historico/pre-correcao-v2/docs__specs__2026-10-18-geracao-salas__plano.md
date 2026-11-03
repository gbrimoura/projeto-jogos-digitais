# Geração coordenada de salas

**Data:** 18/10/2026  
**Estado:** implementação autorizada; validação de runtime não autorizada nesta etapa.  
**Branch:** `corrigir-sprites-salas-plataformas`; preservar a branch e o trabalho local existente.

## Objetivo

Substituir a tabela fixa da proposta de 16/10 por uma geração aleatória coordenada das plataformas presentes nas fixtures atuais, sem determinar a quantidade final de plataformas do jogo. Manter uma faixa contínua de chão, incluir teto visível e conservar portas distintas de entrada e saída.

O usuário confirmou em 18/10 que os sprites voltaram a funcionar. Esta tarefa não reabre a investigação nem a importação dos sprites de inimigos. A leitura de `GDD_Dieselpunk_Noir/04-combate-e-builds.md` confirma o papel da porta e a integração futura da geração no controlador da sala; algoritmo, quantidade final e regras procedurais continuam pendentes. Os limites desta alteração não são regras gerais do jogo.

## Contrato geométrico e algoritmo

Manter viewport 1152×648, paredes sólidas/visuais em x=0..64 e x=1088..1152 e piso 1152×88 com topo y=560. A primeira plataforma tem topo y=440, espessura 24 e fica ao menos 24 px além do bounds horizontal do spawn. As plataformas seguintes formam uma rota em x ordenada e não descendente: vãos de 56–96 px e subidas de 0–64 px por etapa. A rota inteira pode subir no máximo 64 px, de y=440 a y=376. Todas terminam até y=464, deixando pelo menos 96 px entre plataformas e piso; isso mantém o corredor de chão contínuo. O alcance real dos saltos não é garantido sem runtime.

O helper local, sem `class_name`, mantém um `RandomNumberGenerator` por layout. Seed zero randomiza uma vez por instância; seed explícita diferente de zero reproduz posição, largura e altura. As instâncias de plataforma desativam seus sorteios independentes. O gerador faz até 32 tentativas e retorna fallback explícito validado; uma falha final invalida a sala antes do combate. As fixtures atuais contêm três plataformas cada; o helper aceita layouts de 2..5 como limite técnico de suporte, sem fechar a contagem de design.

Main prepara o layout em `_enter_tree` standalone ou por `configure_run_managed` antes de `add_child`/`_ready`. Aplica `size`, que sincroniza o shape local, e posição antes de os filhos entrarem em `_ready`; o preparo é idempotente ao entrar depois em modo managed. A validação inspeciona retângulos das formas físicas aplicadas, limites, vãos, subidas, sobreposição positiva, corredor, spawns, patrulha, teto e suporte primário/fallback do `TrainingTarget`. O alvo permanece em um suporte gerado: o da direita é o mais alto pela ordem vertical não descendente; em empate, usa-se o último da rota. O fallback é o da esquerda. Ambos preservam posicionamento determinístico, sem RNG deferido.

## Portas e teto

Main e SecondRoom contêm entrada visual em (112,522), bloqueada, sem sensor e sem interação, e saída reutilizável em (1040,522), com sensor x=992..1088. A parede continua fechada. A saída managed permanece na sala e só emite `run_progression_ready` uma vez após limpeza e recompensa, com guarda de input encerrada, jogador correto e vivo e alcance confirmado na requisição e no deferred. Se a validação deferred falhar por alcance, limpa o estado ocupado e permite nova tentativa sem emitir sinal; morte/limpeza inválida mantém a saída trancada.

Main standalone mantém `RoomTransition` e snapshot explícito de HP/build ao ir para SecondRoom. SecondRoom standalone conclui visualmente com `ETAPA CONCLUÍDA` e não tenta carregar caminho vazio. Managed deixa a progressão e preservação de HP/build sob responsabilidade do RunController. Nenhuma porta escreve diretamente HP, build ou recompensa.

O teto usa o tile `terrain_top_mid` do atlas da fábrica, nearest, em uma única faixa de 18 colunas de 64 px por 32 fontes; o tile é ampliado para cobrir x=0..1152 e espelhado verticalmente, sem repetição vertical, terminando com a face acabada para baixo. A forma visível e física ocupa y=0..64 e toca o teto existente y=-32..0. A faixa é desenhada após os visuais de parede para fechar os cantos.

## Escopo e validação

Runtime permitido: `scripts/world/main.gd`, `scripts/world/run_controller.gd`, `scripts/world/training_target.gd`, `scripts/world/exit_door.gd`, `scenes/main.tscn`, `scenes/second_room.tscn`, `scenes/exit_door.tscn` e helpers locais de geração/teto. Preservar `solid_platform.gd`, spawns, patrulha, combate, movimento, recursos, assets/imports e `run_root.tscn`.

Antes das edições de runtime, foram guardados snapshots locais e hashes SHA-256 dos arquivos existentes, incluindo as alterações sem commit já presentes. A versão inicial deste plano/spec também foi copiada para `historico/plano-v1.md` e `historico/spec-v1.md` antes dos esclarecimentos após revisão.

Nenhum Godot, import, teste ou QA será executado nesta entrega. O resultado fica sem confirmação de alcance real de salto, leitura das portas/teto em jogo e integração final em runtime.
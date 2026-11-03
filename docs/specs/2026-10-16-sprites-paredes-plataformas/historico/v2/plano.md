# Sprites dos inimigos, paredes laterais e plataformas

**Versão:** V2, consolidada após revisão R1; pronta para nova revisão documental.  
**Estado:** plano; sem autorização de implementação runtime.  
**Branch:** corrigir-sprites-salas-plataformas, base main em 90b2e59.  
**Escopo desta entrega:** documentação somente. Os arquivos de entrada e hashes dos pareceres R1 permanecem congelados.

## Objetivo

Responder ao relato de sprites de inimigos invisíveis, falta de paredes nas salas e distribuição frágil das plataformas. A proposta cobre somente as fixtures atuais main e second_room. Não altera o GDD nem fixa regras finais de sala, piso, run ou chefe.

A investigação estática não prova a causa da invisibilidade. Para o cenário, propõe paredes laterais visíveis e plenamente sólidas, sem abertura física. A saída de main é uma área de interação que carrega outra cena, não um vão por onde o jogador atravessa. Para as plataformas, a proposta troca aleatoriedade por fixture por posições autorais reproduzíveis e atribui suporte fixo ao TrainingTarget.

## Fatos relevantes

- Ambas as cenas usam viewport 1152×648, com piso até y=648. As laterais atuais têm shape 32×648 nos centros x=-16 e x=1168; o teto físico ocupa y=-32..0. Não existem faixas visuais laterais dentro do quadro (project.godot:21–25, scenes/main.tscn:13–20,244–254, scenes/second_room.tscn:12–19,110–120).
- Cada lado pode ser coberto com faixa de 64 unidades de mundo usando uma célula de 32×32 do atlas da fábrica em escala 2×. As células laterais do atlas são (0,1) e (2,1), TileSetAtlasSource id 0, source rects (0,32,32,32) e (64,32,32,32) (resources/environment/factory_tileset_v1.tres:5–23; docs/specs/2026-10-14-tileset-fabrica/plano.md:17–25).
- ExitDoor é um Area2D de interação. Só aceita E após a sala ser liberada e com o jogador dentro do sensor; então emite transition_requested e Main carrega next_room_scene_path (scripts/world/exit_door.gd:46–69, scripts/world/main.gd:325–360). Managed RunRoot remove a instância da porta por completo (main.gd:63–73).
- TrainingTarget usa colisão 72×96 centralizada, mas seu spawn atual escolhe uma plataforma aleatória e uma coordenada X aleatória, em vez de usar a posição serializada na cena (scenes/training_target.tscn:8–23, scripts/world/training_target.gd:318–375).
- O collider físico do RivetWorker mede 46×64 e está deslocado (0,-32) em relação à origem do worker (scenes/rivet_worker.tscn:8–10,38–40). A patrulha e seus limites estão em main.tscn e second_room.tscn.

## Decisão proposta

1. **Diagnóstico visual dos inimigos:** preservar atlases e recursos; reproduzir primeiro idle e depois apenas os estados realmente selecionados pelo código. Isolar em sequência conteúdo alfa do PNG, regiões/UID, frame e animação, CanvasItem/transforms, shader/material e oclusão/posição. Corrigir só a primeira divergência observada; causa continua pendente.
2. **Laterais físicas e visuais:** substituir apenas os dois colliders laterais existentes em cada sala por retângulos 64×648 centrados em x=32 e x=1120. As faixas físicas serão x=0..64 e x=1088..1152. Sem buraco, segunda linha de colisão ou cutout na porta. Desenhar laterais existentes do atlas em nodes dedicados atrás do piso e atores; o piso segue 1152×88 e sobrepõe deliberadamente a representação visual no trecho y=560..648. Manter o collider do teto existente: topo sem parede visual, porém fisicamente bloqueado.
3. **Saída standalone:** mover ExitDoor de x=1080 para x=1040, mantendo y=522. Seu sensor passa a x=992..1088, todo no lado jogável; painel, 48 unidades de largura, ocupa x=1016..1064. A transição continua dependendo de E e da área, sem atravessar fisicamente a parede. Managed mantém a porta removida e não cria recorte visual.
4. **Plataformas:** fixar os layouts da spec nas duas fixtures e desligar randomize_position/randomize_width nessas instâncias. Não redesenhar ou projetar agora o gerador procedural geral.
5. **Suporte do alvo:** exportar um caminho fixo e um caminho fallback determinístico no TrainingTarget. Usar PlatformC/PlatformA em main e UpperPlatform/WestPlatform em second_room. Centralizar X no suporte e alinhar o retângulo de colisão ao topo. Nunca sortear. Se ambos os suportes falharem, restaurar e validar a tabela autoral base antes de criar inimigos; se ainda falhar, rejeitar a sala com erro explícito, sem entrar em combate com alvo flutuando ou oculto.

## Etapas futuras e dependências

**Etapa 1 — sprites.** Só abrir/importar/executar Godot ou testar visibilidade caso o usuário peça explicitamente verificação/testes. Pedido de implementação sozinho não autoriza esses passos. Quando autorizado, registrar a primeira divergência do pipeline para os dois inimigos e corrigir localmente.

**Etapa 2 — limites e apresentação.** Ajustar colliders existentes, adicionar WallVisuals e helper local sem class_name, desenhar source rects do atlas a nearest; z=-1 entre SandboxVisual (-10) e Floor (0). Mover a saída standalone para o interior jogável. Confirmar o acionamento da Area/interação sem interromper as paredes sólidas. Managed e second_room mantêm seus contratos atuais de porta.

**Etapa 3 — layouts e suporte.** Aplicar tabela da spec, flags fixas por instância e NodePaths primário/fallback do alvo. A validação do suporte ocorre antes do início do combate; quaisquer bounds visuais reais devem ser inspecionados com os offsets/escala atuais.

A geração procedural é pendência do GDD e fica fora deste plano. Não projetar validador geral, novas regras de sala ou variação de encontros nesta tarefa.

## Arquivos previstos para uma futura implementação autorizada

- scenes/main.tscn e scenes/second_room.tscn: shapes laterais existentes, grupo WallVisuals, posições das plataformas e overrides aleatórios por instância; main também move ExitDoor para x=1040.
- scripts/world/factory_wall_visual.gd: helper de desenho local sem class_name, se a implementação usar a repetição e recorte especificados.
- scripts/world/training_target.gd, scenes/main.tscn, scenes/second_room.tscn: NodePaths dos suportes, centralização determinística e fallback sem sorteio.
- Cenas/recursos/atlas/shader dos inimigos: só se a reprodução futura localizar a causa. Não alterar arte como tentativa inicial.
- Não alterar scripts/world/solid_platform.gd para implementar geração procedural nesta frente; não editar GDD ou redefinir TileSet.

## Invariantes

- Paredes laterais únicas e sólidas, sem abertura, em layer World; manter teto físico existente.
- Preservar o floor de 1152×88; sobreposição de colisores de parede e piso nos cantos é intencional, sem encurtar o piso.
- Preservar RunRoot: managed remove a porta; Main standalone continua usando interação para troca de cena; second_room não ganha próxima saída.
- Preservar movimento, salto, parry, bola, ricochete, retorno, AoE, colisões e cadência dos inimigos; sem dash obrigatório nas rotas propostas.
- Paredes ficam atrás do floor e dos atores; nenhuma correção visual pode ocultar sprite, projétil ou HUD.
- Não canonizar layouts, pisos por run, chefes ou geração procedural.

## Critérios de aceite

- Sprites de TrainingTarget e RivetWorker legíveis nos estados listados na spec, sem alteração de arte sem causa observada. Cada um tem ao menos uma linha de visão válida durante a condição de combate prevista; o bloqueio por parede/plataforma não causa ataque através de obstáculo. Não definir contagem ou frequência nova de ataques.
- Faixas visuais usam o atlas atual e alinham às faixas físicas sólidas x=0..64 e x=1088..1152. Colisões de jogador, worker e bola permanecem coerentes; ricochete e retorno seguem funcionando.
- A saída standalone pode ser acionada de dentro do sensor, com sala liberada, sem exigir que o jogador atravesse a parede; managed segue sem porta.
- Layout é reproduzível. Rotas Floor→PlatformA→B→C e Floor→West→Upper→East são avaliadas nos dois sentidos; retorno East→Upper tem margem teórica explicitada na spec, sem garantia de movimento antes da verificação autorizada.
- O alvo aparece centrado no suporte nomeado, com fallback fixo suportado e sem randf_range; layout inválido não inicia combate com entidade flutuante/invisível.
- Trechos sob plataformas baixos são tratados como obstáculos contornáveis; passagens nominais são explicitadas e confirmadas pelos bounds reais.

## Validação futura, autorização e rollback

A conferência estática dos arquivos tocados acompanha qualquer futura implementação autorizada. Abertura/importação do Godot, execução de gameplay e testes somente se o usuário pedir explicitamente verificação/testes; pedido de implementação não basta. Não foi executado Godot, importação ou teste nesta etapa documental.

Antes de cada etapa futura, salvar SHA-256 por arquivo runtime tocado e comparar com baseline 90b2e59; registrar os arquivos protegidos e preservar mudanças alheias. Reverter apenas arquivos da etapa se os critérios falharem. Esta V2 preserva o plano/spec anteriores sem modificar as entradas imutáveis R1.
# Especificação V3 — sprites, paredes e distribuição de plataformas

**Escopo:** fixtures existentes `main` e `second_room`, proposta provisória. Sem edição do GDD ou implementação runtime nesta tarefa.  
**Revisão:** V3 incorpora as decisões de R2; V1 e V2 estão preservadas em `historico/`. Inputs e hashes dos revisores permanecem imutáveis.

## 1. Diagnóstico: fatos, hipóteses e inventário

### Fatos estáticos

- Viewport fixo em 1152×648 (`project.godot:21–25`). As laterais atuais medem 32×648, centros x=-16 e x=1168; o teto físico mede 1152×32, centro y=-16 (`scenes/main.tscn:13–20,244–254`; `scenes/second_room.tscn:12–19,110–120`).
- Main inicia o jogador em (160,560), second_room em (128,560). A cápsula do player tem 28×76, então os AABBs iniciais são x=146..174 e y=484..560 em main; x=114..142 e y=484..560 em second_room (`scenes/main.tscn:290–295`; `scenes/second_room.tscn:161–165`; `scenes/player.tscn:19–25`). A primeira borda de A fica 20 unidades à direita do centro do marcador, com 6 unidades entre capsule e borda; a primeira borda de West fica 92 do centro, 78 da capsule. Estes são afastamentos do spawn até a primeira plataforma, não vãos entre plataformas.
- As duas fixtures, a cena do player e a composição de RunRoot não instanciam Camera2D nem pickups; viewport permanece fixo. Não adicionar câmera nesta proposta.
- ShotOrigin do jogador está em (0,-38) relativo ao player (`scenes/player.tscn:141–142`). BallLauncher cria snapshot da configuração, preserva collision_mask e faz `cast_motion`/consulta `intersect_shape` para escolher um spawn livre (`scripts/player/ball_launcher.gd:62–70,123–188`). Não mudar origem, lançamento, máscara, cast ou comportamento do lançador por causa das paredes.
- TrainingTarget tem collider 72×96, centralizado na origem. O atual spawn escolhe plataforma e X aleatórios; a posição serializada na fixture não é a final (`scenes/training_target.tscn:8–23`; `scripts/world/training_target.gd:318–375`).
- TrainingTarget está na layer 8 e Player tem mask 9, que inclui essa layer: alvo vivo é obstáculo sólido ao player. Derrotado, TrainingTarget emite `defeated` e usa `queue_free` (`scenes/player.tscn:24–25`; `scripts/world/training_target.gd:60–73`).
- Collider do RivetWorker é 46×64, offset local (0,-32). Em main, marker de patrulha x=420..920 dá corpo x=397..943; em second_room, x=760..1040 dá x=737..1063. Ambos cabem entre futuras faces x=64 e x=1088 (`scenes/rivet_worker.tscn:8–10,38–40`; `scenes/main.tscn:299–315`; `scenes/second_room.tscn:170–190`).
- ExitDoor é Area2D com sensor, layer 0/mask 2 e sem corpo físico. Após sala limpa e interação E em alcance, emite a troca de cena (`scenes/exit_door.tscn:5–14`; `scripts/world/exit_door.gd:46–81`; `scripts/world/main.gd:325–360`). Managed RunRoot remove a porta toda (`scripts/world/main.gd:63–73`).

### Fatos visuais dos inimigos

- As cenas configuram BodySprite em escala 2; TrainingTarget é centralizado; RivetWorker usa offset y=-48; ambos usam shader de flash (`scenes/training_target.tscn:27–34`; `scenes/rivet_worker.tscn:44–52`).
- TrainingTarget tem clips `disabled`, `idle`, `impact`; o script seleciona idle/impact. `disabled` existe no recurso, mas não é selecionado pelo código atual. Fases do ataque `hidden/windup/active/recovery` são do efeito separado, não novos clips de corpo (`resources/enemy/training_target_sprite_frames.tres:17–42`; `scripts/world/training_target.gd:252–277,288–293`).
- RivetWorker tem `idle/walk/aim/fire/recovery`, selecionados conforme estado (`resources/enemy/rivet_worker_sprite_frames.tres:25–69`; `scripts/enemy/rivet_worker.gd:589–607`).

- O limite alfa agregado dos frames analisados alcança a linha fonte y=55 inclusive; o pixel dessa linha ocupa até a borda y=56. Com frame 64×64, escala 2 e sprite centrado, isso dá TrainingTarget em y=392: 392 + 2×(56−32) = 440, exatamente o topo de C; RivetWorker em root y=560, offset -48: 560−48 + 2×(56−32) = 560. Não há o gap de 2 unidades inferido anteriormente. É uma estimativa de borda agregada do atlas; confirmar a pose renderizada, sem mover arte/colisor por essa conta.
### Hipóteses ainda sem confirmação

O relato de sprites invisíveis é fato; a causa não foi localizada estaticamente. Atlas/alpha, região/UID, clip/frame, CanvasItem/modulate/transform, material/shader, z, clipping, oclusão ou posição final podem ser investigados, sem escolher culpado antes da reprodução. O alpha existe nos atlases, mas isso não comprova carregamento/renderização no Godot.

## 2. Validação autoral e fluxo de falha

Ativar o modo autoral somente nas duas fixtures deste plano, por uma flag explícita como `authored_layout_enabled` no Main e `authored_support_enabled` no TrainingTarget. Em instâncias fora do escopo, com modo autoral desligado e NodePaths não definidos, preservar a lógica atual.

Implementar `Main.prepare_authored_layout() -> bool` como validação idempotente da tabela fixa, em coordenadas locais das fixtures, usando dados estáticos locais sem depender da árvore ou do espaço físico; Managed chama antes de `add_child`, e standalone chama em `Main._enter_tree` antes dos filhos entrarem/prontos. Não usar `@onready`, transform global dependente da árvore nem consulta ao espaço físico. Examinar shapes e transforms declarados na cena e testar AABBs derivados da geometria.

- Os caminhos exportados do alvo chamam-se exatamente `fixed_support_path` e `fallback_support_path`, relativos ao próprio TrainingTarget. Como o alvo e as plataformas são filhos diretos da sala, os caminhos são `../PlatformC`, `../PlatformA`, `../UpperPlatform` e `../WestPlatform` conforme a tabela da seção 6. Caminho vazio ou inválido é falha quando o modo autoral está ativo.
- Para cada suporte, exigir largura da plataforma ≥88 (72 do collider + 8 de margem em cada lado), contenção horizontal do collider com margem de 8 e contato vertical: bottom do alvo igual ao top da plataforma dentro de tolerância de 0,5 unidade. O contato com a plataforma escolhida é permitido e excluído da checagem de obstrução.
- Contra outros corpos estáticos na World layer 1, rejeitar AABB com interseção de área positiva >0,01 unidade²; mero toque de borda não é interseção. Areas de sensores/patrulha não são obstáculos. Validar separadamente AABB dos spawns do player e worker e o intervalo de patrulha do worker; ignorar Areas como obstáculos. Preservar a consulta atual da bola sem alterar o lançador.
- Tentar suporte primário e, se inválido, somente o fallback fixo. Não restaurar tabela em runtime, não criar outro alvo e não sortear. Se ambos falharem, a sala é inválida.

**Managed:** RunController chama a configuração/validação antes de `room_container.add_child` (diretamente ou por `configure_run_managed`). Se retornar false, descartar a instância com `free_room`, chamar `_fail_run` e não adicionar a sala; não emitir nem contar `room_cleared`.

**Standalone:** Main chama `prepare_authored_layout` em `_enter_tree`, antes de os filhos executarem `_ready`. Sucesso deixa o alvo na posição fixa já calculada; o `_ready` dele usa essa posição e não agenda o spawn aleatório. Falha marca a sala inválida antes dos filhos, bloqueia ativação/combate dos inimigos, bloqueia input/jogabilidade e mantém a saída bloqueada. Depois de a árvore estar pronta, mostrar erro e ação de reinício; não liberar porta, não emitir/contar vitória, não mover o alvo para posição aleatória nem criar inimigos duplicados. A flag de resultado deve ser acessível aos inicializadores do TrainingTarget e RivetWorker para que não ativem uma sala inválida.

## 3. Isolamento da invisibilidade

Somente se o usuário pedir explicitamente verificação/teste no Godot, reproduzir primeiro idle e depois os estados de corpo realmente selecionados. Registrar o primeiro estágio que falha:

1. PNG em disco: dimensão, alfa e pixels do frame usado.
2. Resource: UID/path e source region de cada AtlasTexture.
3. AnimatedSprite2D: SpriteFrames, clip, frame, autoplay e chamadas de play.
4. CanvasItem: visible, modulate, self_modulate, scale, offset, facing, z, canvas e posição final.
5. Shader/material: bypass local de diagnóstico, comparar sem alterar material compartilhado.
6. Oclusão/posição: ordem cenário/plataformas/corpos, clipping, transform pai e spawn final.

Critério visual do corpo: TrainingTarget em idle/impact e RivetWorker em idle/walk/aim/fire/recovery; verificar hit flash sem apagar corpo. Clip `disabled` do alvo não é requisito até ser selecionado pelo código. Verificar à parte a área de ataque do alvo e que os efeitos não cubram o corpo. Corrigir a primeira divergência demonstrada; preservar arte se a causa for composição/carregamento.

## 4. Paredes laterais totalmente sólidas

Reusar os dois colliders laterais existentes por fixture, sem duplicar:

| Parede | Centro | Dimensão | Cobertura física | Face interior |
|---|---:|---:|---:|---:|
| esquerda | (32,324) | 64×648 | x=0..64, y=0..648 | x=64 |
| direita | (1120,324) | 64×648 | x=1088..1152, y=0..648 | x=1088 |

Cada lado é um único retângulo sólido de cima a baixo. Sem abertura física ou visual na parede direita. Teto atual permanece colisor y=-32..0: topo sem parede visual, mas fisicamente bloqueado. Centro seguro do Player com cápsula raio14 fica x=78..1074; viewport continua 0..1152.

Manter Floor 1152×88, topo y=560 e base y=648 (`scenes/main.tscn:256–258`; `scenes/second_room.tscn:122–124`). Shapes de parede e piso se sobrepõem nos cantos para não deixar fresta; não encurtar o piso.

Adicionar por fixture Node2D `WallVisuals` em z=-1, entre SandboxVisual (-10) e Floor (0), com `LeftWallVisual` e `RightWallVisual`. Helper obrigatório `scripts/world/factory_wall_visual.gd`, sem `class_name` global; desenha as regiões atuais do atlas com nearest e sem colisão. Posição esquerda x=0, direita x=1088. A face acabada deve apontar para o interior; usar flip/mirror das células existentes se orientação visual do atlas exigir, sem criar arte.

Usar atlas source id 0, grade 32×32: célula lateral esquerda id (0,1)/alt 0, sourceRect Rect2(0,32,32,32); célula lateral direita id (2,1)/alt 0, sourceRect Rect2(64,32,32,32). Esses tiles representam laterais, com preenchimento (1,1) (`resources/environment/factory_tileset_v1.tres:3–23`; `docs/specs/2026-10-14-tileset-fabrica/plano.md:17–25)). Cada célula escala a 64×64. Repetir dez segmentos desde y=0 até y=640; fechar y=640..648 com recorte de 4px de altura no source (x da célula, y=32..36), desenhado em 64×8, ancorado ao topo. Floor z=0 cobre deliberadamente o visual da parede entre y=560..648; os colliders seguem contínuos.

## 5. ExitDoor em Main standalone

Reposicionar ExitDoor para (1040,522), sem escala nova. Sensor local 96×108 ocupa x=992..1088, todo no lado jogável até a face interna direita; DoorPanel tem 48 de largura e ocupa x=1016..1064. A porta só usa Area e E após a sala limpa; não tem Body e não é passagem literal. Manter parede sólida atrás do sensor e não cortar o tile visual. Managed remove a porta inteira; second_room continua sem próxima saída.

## 6. Layouts e travessia

Desativar `randomize_position` e `randomize_width` somente nas seis instâncias de plataforma dessas fixtures. Não alterar nem redesenhar o gerador geral. Tamanhos e espessuras se mantêm; estes centros/topos/bounds são proposta provisória:

| Fixture | Plataforma | Centro | Tamanho | Topo | X esquerdo..direito |
|---|---|---:|---:|---:|---:|
| main | Floor | (576,604) | 1152×88 | 560 | 0..1152 |
| main | PlatformA | (290,480) | 220×24 | 468 | 180..400 |
| main | PlatformB | (615,468) | 190×24 | 456 | 520..710 |
| main | PlatformC | (915,452) | 190×24 | 440 | 820..1010 |
| second_room | Floor | (576,604) | 1152×88 | 560 | 0..1152 |
| second_room | WestPlatform | (340,480) | 240×24 | 468 | 220..460 |
| second_room | UpperPlatform | (615,385) | 190×24 | 373 | 520..710 |
| second_room | EastPlatform | (900,452) | 170×24 | 440 | 815..985 |

Vãos entre plataformas (arestas): Main A→B =120 e B→C=110; second West→Upper=60 e Upper→East=105. Subidas: A→B=12, B→C=16, West→Upper=95; East→Upper no retorno sobe67. Floor se estende sob as plataformas; não existe vão geométrico chão-plataforma. Os 20 (main) e 92 (second) são somente distância horizontal do centro de PlayerSpawnMarker à primeira borda A/West, como discriminado na seção 1.

East→Upper: com jump_velocity=640 e gravidade=1600, subida de 67 dá raiz descendente de ~0,676s; usando move_speed=260 imediatamente constante, alcance ideal ~176 versus vão105, margem teórica ~71. A conta ignora aceleração e colisão; não garante alcançabilidade jogável até a verificação autorizada. Não exigir dash.

### Passagem sob plataformas no piso

Folga entre piso y=560 e bottom da plataforma; capsule Player tem 76 de altura. Herói visual é estimado em ~88 e precisa ser confirmado. Não obrigar passagem sob A, B ou West:

| Plataforma | Bottom | Folga | Leitura da rota |
|---|---:|---:|---|
| main / A | 492 | 68 | capsule não passa; contornar/subir por A |
| main / B | 480 | 80 | capsule passa fisicamente com 4 de folga, mas passagem visual é apertada; não contar como rota obrigatória |
| main / C | 464 | 96 | passagem prevista, ~8 acima do visual estimado |
| second / West | 492 | 68 | capsule não passa; contornar/subir por West |
| second / Upper | 397 | 163 | passagem ampla |
| second / East | 464 | 96 | passagem prevista; confirmar bounds visuais |

Rotas primárias: Floor→A→B→C e Floor→West→Upper→East; passar sob C/East é previsto. West/A são contornadas por cima; passagem apertada sob B não é necessária. Worker de 64 de altura cabe sob B/C/East; GDD descreve worker sob C (`04-combate-e-builds.md:47`).

## 7. Suporte fixo do alvo e colisões de rota

Em cada TrainingTarget autoral, configurar exatamente:

| Fixture | `fixed_support_path` | `fallback_support_path` | Posição primária | Fallback |
|---|---|---|---:|---:|
| main | ../PlatformC | ../PlatformA | (915,392) | (290,420) |
| second_room | ../UpperPlatform | ../WestPlatform | (615,325) | (340,420) |

A origem calculada usa o centro global do suporte menos o centro X local do collider e top do suporte menos bottom local do collider. Para Rect2(-36,-48,72,96), margin8, os alvos ficam centrados e apoiados. Caminhos são relativos ao próprio alvo, não ao Main.

Ao aplicar a posição fixa, o alvo não chama `randf_range` nem agenda `_place_on_platform`. Só após derrota o alvo sai da rota via `queue_free`; vivo, layer8 é sólido para Player mask9. A rota deve permitir chegar à plataforma Upper para combater o alvo por uma posição acessível, e não deve exigir atravessar o collider do inimigo. Em plataforma de 190 com alvo de 72 centrado, sobram 59 de cada lado; descontada a capsule de 28, cada passagem lateral tem 31 de largura. Confirmar a manobra no teste autorizado e não impor dash. Verificar também a passagem completa entre plataformas após remover o alvo derrotado.

## 8. Worker, LOS e critérios de aceitação

Worker permanece no piso; seus bounds já calculados cabem entre faces x64..1088. Com root y=560 e collider offset -32, corpo ocupa aproximadamente y=496..560. Corredores de 96 sob C/East cabem worker; clearance de 80 sob B também excede seus 64 de altura. Não alterar spawns ou limites de patrulha.

Checagem manual LOS, sem inventar frequência/quantidade:
- TrainingTarget: com jogador em alcance já configurado, observar windup/active/recovery com raio limpo; parede/plataforma obstruindo deve impedir ataque através do corpo sólido.
- RivetWorker: confirmar orientação e disparo na posição configurada com raio limpo; obstrução impede disparo através de superfície; permitir reposicionamento existente até linha livre.
- Alvo deve estar visível e apoiado nas duas posições fixas/fallbacks, sem passar pela parede ou esconder sprite.
- Main standalone abre saída só dentro da Area e após interação; não é preciso cruzar a parede. Managed segue sem porta, sem cutout; teto segue fisicamente bloqueado.
- Paredes desenhadas coincidem com faixas de colisão, sem fresta nos cantos; piso preserva tamanho e camada. Player, worker e bola colidem/ricocheteiam/retornam conforme já configurados.
- Layout repete a cada execução; AABB de spawns, patrulha e alvo não começa sobre World layer1 com área positiva >0,01, exceto contato permitido com o suporte do alvo e piso. Passagens previstas e bloqueios contornáveis correspondem à tabela.
- Confirmar rotas antes/depois da derrota do TrainingTarget e retorno East→Upper sem dash obrigatório; a estimativa balística não é critério substituto para teste.

Preservar combate/run: movement, salto, parry, ShotOrigin, snapshot e spawn da bola, máscaras, ricochete, retorno, AoE, colisões e cadência dos inimigos. Nenhuma câmera nova, novo pickup ou arte nova nesta frente.

## 9. Escopo futuro, verificação e rollback

Arquivos previstos após autorização de implementação: `scenes/main.tscn`, `scenes/second_room.tscn`, `scripts/world/main.gd`, `scripts/world/run_controller.gd`, `scripts/world/training_target.gd`, `scripts/enemy/rivet_worker.gd` (somente gate da sala inválida, se necessário) e helper obrigatório `scripts/world/factory_wall_visual.gd`. Recursos de sprite/shader/atlas só se a reprodução localizar a causa. Não tocar `scripts/world/solid_platform.gd`, launcher, GDD ou TileSet existente.

Pedido para implementar não autoriza abrir/executar/importar Godot nem rodar testes; essas ações exigem pedido explícito de verificação/testes. Implementação autorizada pode avançar com revisão estática e etapas independentes, registrando critérios visuais/rotas como pendentes quando não testados. Se a sequência de isolamento terminar sem causa, preservar arte e reportar inconclusivo, escalando apenas evidência/log autorizado; não inventar correção.

Antes de cada etapa futura, criar snapshot SHA-256 dos arquivos tocados. Baseline da primeira etapa é 90b2e59; cada fase aceita estabelece baseline da próxima fase. Rollback limita-se aos arquivos da fase rejeitada, sem reset global ou perda de alterações alheias.

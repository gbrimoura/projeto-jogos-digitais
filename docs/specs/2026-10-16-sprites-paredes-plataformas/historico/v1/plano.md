# Sprites dos inimigos, paredes laterais e plataformas

**Estado:** plano documental congelado para revisão; ainda não aprovado para implementação.  
**Branch preparada pelo agente principal:** corrigir-sprites-salas-plataformas, baseada em main (90b2e59).  
**Escopo desta entrega:** diagnóstico estático e documentação. Nenhum arquivo de runtime, arte, importação ou teste foi alterado/executado.

## Objetivo

Atender ao relato do usuário de que os sprites dos inimigos estão invisíveis, faltam paredes nas salas e a distribuição das plataformas precisa melhorar. O plano cobre as duas salas de combate existentes, sem tratar seus layouts de demonstração como cânone do GDD. Para os sprites, primeiro localizar a causa observável antes de propor correção. Para as salas, tornar as laterais legíveis e coerentes com a colisão, e trocar a distribuição aleatória plataforma a plataforma dessas fixtures por um arranjo autoral alcançável e que preserve os pontos de combate.

## Diagnóstico estático

O usuário relatou os três problemas visuais/de layout. Na inspeção dos arquivos, não foi possível provar a causa da invisibilidade. TrainingTarget e RivetWorker têm AnimatedSprite2D visível por padrão, escala 2, animação idle configurada e material com o shader de flash; seus SpriteFrames referenciam atlases de 64×64 por pose (scenes/training_target.tscn:27–34, scenes/rivet_worker.tscn:44–52, resources/enemy/training_target_sprite_frames.tres:3–18, resources/enemy/rivet_worker_sprite_frames.tres:3–26). Os PNGs dos atlases contêm pixels não transparentes (assets/enemy/training_target/training_target-atlas.png e assets/enemy/rivet_worker/rivet_worker-atlas.png), mas isso não confirma carregamento/importação nem renderização em jogo. O shader compartilha a implementação com os dois inimigos (scripts/enemy/enemy_hit_flash.gdshader:1–16); comparação do estado atual com o snapshot Git anterior não mostrou alteração textual. Essa dependência comum merece ser isolada, mas não prova causa.

As salas têm colliders laterais e teto, porém não têm faixas visuais laterais correspondentes. Em ambas, os colliders atuais são 32×648, centrados em x=-16 e x=1168, tangenciando os limites da viewport em x=0 e x=1152, portanto ficam fora do quadro visível (scenes/main.tscn:13–20,244–254, scenes/second_room.tscn:12–19,110–120; viewport project.godot:21–25). O piso começa em y=560. Esse arranjo explica visualmente a ausência de paredes sem implicar ausência de colisão. O teto também fica acima do quadro; o GDD não exige fechar visualmente a parte superior, então o plano não adiciona um teto aparente.

As seis plataformas das fixtures herdam randomize_position=true e randomize_width=true. O gerador usa room_rect=Rect2(0,0,1280,720) embora a viewport seja 1152×648, sorteia cada plataforma com base em âncoras já colocadas e limita saltos por uma heurística (scripts/world/solid_platform.gd:32–62,81–179). Com room_seed=0, posição e largura mudam em cada instanciação (solid_platform.gd:5–7,100–108). O gerador não valida a rota completa, o spawn do jogador/inimigo, linha de tiro ou uma plataforma de suporte específica do alvo. Além disso, vertical_clearance=70 é menor que a cápsula de colisão do jogador, de 76 unidades (scenes/player.tscn:19–25), e bem menor que o corpo visual ampliado; sobreposição ou oclusão é uma hipótese geométrica a verificar, não causa já demonstrada.

O nó serializado de TrainingTarget não é seu spawn final: por padrão ele escolhe aleatoriamente uma plataforma livre que comporte sua colisão e alinha a base ao topo, com o piso apenas como fallback (scripts/world/training_target.gd:27–29,329–375). Assim, editar somente as coordenadas gravadas em main.tscn ou second_room.tscn não fixa o posicionamento efetivo. O alvo também usa a camada World para linha de visão (training_target.gd:11,112); o RivetWorker usa a mesma máscara para consultas de mundo e projéteis (scripts/enemy/rivet_worker.gd:29,80–94).

As configurações atuais do jogador indicam velocidade 260, gravidade 1600, impulso 640 e dash 720 por 0,14 s (resources/player_movement_config.tres:7–20). A altura balística ideal aproximada do salto é 128 unidades (640²/(2×1600)), antes de cortes de salto e colisões. As distâncias propostas abaixo ficam dentro da faixa nominal e não exigem dash; o teste de controle real ainda é obrigatório.

## Decisão de proposta

1. **Diagnosticar os sprites em ambos os inimigos** com a mesma sequência controlada da especificação. Corrigir apenas a primeira divergência demonstrada, preservar comportamento e assets existentes e repetir nos estados relevantes.
2. **Trazer as paredes laterais para dentro do quadro sem duplicar colisores.** Reutilizar LeftWall e RightWall, tornando cada collider 64×648 e centrando-os em x=32 e x=1120. As regiões físicas passam a ser x=0..64 e x=1088..1152. Reutilizar peças laterais/preenchimento do atlas atual, escala 2× e filtro nearest, produzindo faixas visuais de 64 unidades alinhadas aos colliders. Não acrescentar colisores paralelos. Preservar o teto atual, sem impor parede visual superior.
3. **Usar layout fixo autoral nas duas fixtures atuais**, desligando o sorteio de posição/largura dessas seis instâncias. O gerador geral continua disponível, mas qualquer futura sala gerada precisa de seed reproduzível e validação completa antes de uso. Isso evita que a fixture mude ao abrir a sala e respeita o estado provisório da geração procedural no GDD.
4. **Ordenar a integração de layout**: paredes e retângulo técnico; superfícies/colliders; plataformas e rota alcançável; suporte definido do alvo; spawn do jogador/inimigo e patrulha; linha de tiro, porta, câmera/viewport e ricochetes. O alvo deve referenciar explicitamente uma plataforma de suporte válida em cada sala (PlatformC em main, UpperPlatform em second_room) ou uma allowlist autoral equivalente, em vez de sorteio por todas as plataformas. Recalcular o spawn final sobre esse suporte, sem depender da posição placeholder do nó.

As posições de referência e os critérios geométricos detalhados estão em [spec.md](spec.md). São valores locais de validação para main.tscn e second_room.tscn, não leis globais de movimento ou desenho de fases.

## Etapas futuras e dependências

**Fase 1 — reproduzir e localizar a falha visual.** Somente se o usuário pedir explicitamente verificação/testes no Godot, comparar os dois inimigos na mesma sala e enquadramento. Pedido para implementar, isoladamente, não autoriza abrir/importar/executar o Godot. Seguir a ordem de isolamento na spec; registrar o primeiro estágio em que pixels deixam de aparecer. Só então escolher um ajuste localizado de cena/recurso/script/shader ou posicionamento.

**Fase 2 — laterais visíveis e alinhadas.** Reutilizar os colliders das duas cenas, aplicar a faixa do atlas existente em camada atrás dos atores e ajustar apenas bounds/gerador de plataformas que dependam do retângulo anterior. A saída standalone de main.tscn continua utilizável como porta na parede. O modo gerenciado remove ExitDoor antes de carregar a sala; suas mesmas laterais permanecem (scripts/world/main.gd:63–73). A fixture second_room.tscn continua sem saída seguinte.

**Fase 3 — layout fixo e suportes.** Aplicar as posições da spec com dimensões das cenas atuais, desativar somente a aleatoriedade das seis instâncias e fixar o suporte do TrainingTarget por sala. Manter plataformas, floor e pontos de spawn com as skins existentes. Não alterar HP, ritmo de combate, cadência de ataque, controles ou regras de progressão.

**Fase 4 — validação de geração, se necessária depois.** Não é requisito para corrigir as fixtures atuais. Antes de reativar geração procedural, criar um validador que receba uma seed e valide o conjunto completo: limites da sala e dos corpos, rota de pulo sem dash obrigatório, plataformas de suporte, distância/área de patrulha, espaço de cabeça, linhas de tiro, câmera e saída. Tentativas inválidas devem ser rejeitadas com fallback determinístico, nunca deixar fixture parcialmente montada. Procedural continua pendente no GDD.

## Arquivos previstos para uma implementação autorizada

- scenes/main.tscn, scenes/second_room.tscn: colliders laterais, arte/skin e coordenadas/dimensões das plataformas; flags de aleatoriedade por instância.
- scripts/world/solid_platform.gd: somente se a aplicação do retângulo e a validação exigirem ajuste; preservar geração geral até ser validada.
- scripts/world/training_target.gd e cenas/recursos do TrainingTarget: selecionar e validar suporte autoral sem deixar alvo flutuando ou sem fallback diagnóstico.
- assets/enemy/*/*-atlas.png, .import, resources/enemy/*_sprite_frames.tres, cenas/scripts dos inimigos e scripts/enemy/enemy_hit_flash.gdshader: somente os arquivos que a reprodução demonstrar serem a causa dos sprites invisíveis. Não redesenhar atlas como primeira resposta.
- resources/environment/factory_tileset_v1.tres: referência de arte existente; não editar/regenerar o tileset para esta proposta.

## Invariantes

- Preservar CombatRoom, entrada/saída standalone, remoção da porta em salas gerenciadas e estado de vida/build do loop.
- Preservar movimento, pulo, parry, bola, ricochete físico, retorno, área de dano, layers/masks de combate e tempos/estados dos inimigos; qualquer colisão nova de parede deve continuar refletindo os ricochetes previstos.
- Preservar personagens cartoon, atlases e o tamanho/cadência das animações salvo ajuste mínimo provado no diagnóstico.
- Desenhar paredes atrás de jogador, inimigos e bola; nenhuma peça visual nova pode encobrir sprites ou o HUD.
- Manter second_room como fixture fixa e main como fixture repetida atual do RunRoot. Não canonizar floors, salas comuns, chefes ou geração procedural ainda placeholders.

## Critérios de aceite

- TrainingTarget e RivetWorker aparecem integralmente e sem cintilação em idle e nos estados/animações efetivamente usados; mudança de direção, hit/flash, disparo e ataque do alvo não escondem o corpo. A validação cobre ambos nas duas fixtures, com retorno/relato da primeira causa observada e ajuste aplicado.
- As duas laterais são visíveis dentro de 0..1152, cobrem a altura visível, alinham faces internas dos colliders ao desenho e impedem atravessamento de jogador, inimigos e bola. Há ricochete coerente e VFX no impacto. O topo permanece sem parede visual, mas continua fisicamente bloqueado pelo collider de teto existente.
- Todas as plataformas ficam dentro do retângulo útil, não cobrem spawns ou sprites, mantêm gaps/saltos atravessáveis sem dash obrigatório e nenhuma rota primária se fecha. Os alvos surgem apoiados apenas nos suportes declarados. Worker e patrulha permanecem no piso e seus projéteis podem encontrar linha de tiro pelo menos em uma janela de combate por sala.
- A porta standalone segue alcançável e funcional junto à parede lateral; a sala gerenciada não ganha uma porta removida de volta. second_room mantém a ausência de saída seguinte.
- Sem alterações em regras de combate/progressão ou assets fora do escopo justificado.

## Validação futura

Em uma implementação futura, validar estaticamente dimensões, referências, layers/masks e limites. Abrir/importar o Godot, executar gameplay ou testes somente se o usuário pedir explicitamente verificação/testes; o pedido de implementação, por si só, não autoriza esses passos. O roteiro futuro cobrirá enquadramento; alvo em suporte; worker/patrulha; saltos; porta; colisão/ricochete e retorno da bola; visibilidade de atores e efeitos. Esta entrega não executou Godot, importação, testes ou QA.

## Riscos e questões abertas

- Causa da invisibilidade permanece sem prova estática; a hipótese de dependência compartilhada no shader deve ser testada sem atribuir culpa antes da observação.
- A nova faixa de parede usa 64 unidades (duas vezes uma célula de 32 px); é uma escolha local para alinhar visual e collider, não exigência do GDD. Repetição e recorte final de 8 unidades na altura 648 precisam ser conferidos em nearest no jogo.
- O ponto da porta está em x=1080, com painel visual de 48 px e sensor de 96 px (scenes/main.tscn:287–288, scenes/exit_door.tscn:5–28). A faixa direita x=1088..1152 deve tratá-la visualmente como abertura/portal e preservar o alcance. Se o painel ou o jogador colidir com a parede, resolver a moldura/abertura sem duplicar ou enfraquecer o limite físico fora do necessário.
- A escolha aleatória atual do alvo pode ocultar o alvo atrás de plataformas ou criar linha de tiro ruim; selecionar suporte fixo melhora reprodutibilidade, mas o LOS ainda precisa de teste em runtime.
- O worker patrulha x=420..920 em main e x=760..1040 em second_room (scenes/main.tscn:299–315, scenes/second_room.tscn:170–190). Confirmar que as novas plataformas não bloqueiam a única linha de tiro nem a circulação.
- main.tscn mantém overrides serializados factory_skin_enabled = null e factory_surface_style = null nas plataformas (main.tscn:256–285); isso não demonstra falha, mas a revisão da visibilidade de skin precisa confirmar o valor efetivo no editor.
- Para arte nova, se peças atuais não servirem após composição, seguir o procedimento aprovado ImageGen como referência, ajustes/reprodução no Aseprite e revisão antes da integração; primeiro esgotar o tileset disponível.

## Rollback

Aplicação futura deve manter snapshot dos arquivos de runtime tocados antes de alterar. Reverter apenas o conjunto desta implementação caso aceite falhe; preservar todo estado alheio e manter documentadas as evidências da causa. Nenhum rollback de runtime foi necessário nesta etapa documental.
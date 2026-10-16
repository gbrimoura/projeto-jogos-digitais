# Especificação — integração do loop de jogo

**Data:** 16/10/2026  
**Estado:** contrato integrado com as correções da revisão estática R1; baseline e hashes anteriores às correções estão em historico/revisao-r1-baseline.json.

## Fluxo de execução

1. `project.godot` inicia por `res://run_root.tscn`, sem depender de UID ainda não importado.
2. `RunController` instancia a sala comum ou chefe dentro de `RoomContainer`, compartilha a instância da `RunBuild` atual e informa se a oferta local ainda deve aparecer.
3. `Main` conserva seu fluxo de vitória e limpeza pós-física. Em modo gerenciado, não consome snapshot estático de transição e remove `ExitDoor` apenas da instância corrente. Após concluir o caminho de vitória e qualquer oferta local, emite `run_progression_ready` uma vez.
4. `RunController` só avança após esse sinal. Ao trocar de encontro, preserva HP atual/máximo via `PlayerHealth.restore_health_for_room_transition`; valores de vida inválidos ou jogador morto cancelam o avanço. A instância nova aplica `RunBuild` no `_ready` e recebe os multiplicadores da run depois que os filhos terminaram de inicializar.
5. Uma recompensa de chefe aguarda seleção ou cancelamento por morte antes de alterar multiplicadores. A morte também invalida temporizadores/continuações pendentes, mostra Game Over e permite reinício.
6. Modificadores de projétil são aplicados ao snapshot derivado em `BallLauncher`, depois dos efeitos tipados de `RunBuild`; nunca mutam cumulativamente o Resource-base.

## Contratos preservados

- Player continua usando `PlayerHealth` como fonte única de HP, invulnerabilidade e morte; dano retorna booleano.
- `Main` standalone continua usando oferta `RunBuild`, porta, snapshot one-shot e destinos atuais sem alterações de semântica.
- A integração gerenciada mantém ataque circular da sentinela, flash de dano e animações/arte Cartoon V2, incluindo sincronização do aviso visual, physics query e LOS existentes.
- O estado físico da bola mantém charge, parada de sweep em callbacks letais e lock de liberação do parry; o clique de disparo permanece bloqueado durante swing.
- Efeitos de parede são visuais e deferred. Parry e hits aceitos permanecem nos estilos do `CombatFeedback` atual.
- Plataformas continuam usando o posicionamento aleatório existente e os inimigos mantêm suas regras atuais de posição e ataque.
- A sala de chefe atual reutiliza `main.tscn` como placeholder; `floors_per_run=1` na cena é apenas a configuração desta integração.

## Arquivos da frente

Além dos 16 paths na diferença da branch, scripts/world/main.gd recebeu apenas integração gerenciada; R1 também autorizou scripts/player/trajectory_preview.gd e ajustes do HUD em run_root.tscn. Não alterar CombatRoom, assets, recursos, cenas de sala atuais, configurações gerais ou plugins.

## Revisão e validação

Não executar Godot, import, testes ou QA. A frente será congelada e entregue ao agente principal para revisão estática com os arquivos completos e riscos identificados. A validação de runtime continua pendente.

## Correções da revisão R1

- O snapshot de ProjectileConfig derivado após RunBuild e recompensas é usado por spawn, lançamento e trajectory preview.
- A bola retorna ao alvo depois do limite configurado de ricochetes, inclusive zero. Durante retorno não executa sweep, colisão, parry ou dano; ao chegar, emite finished com returned. Os cancelamentos existentes continuam liberando a bola.
- Vitória e Game Over pausam o jogo. RunController aceita R somente como key press não repetido após o fim da run. O HUD da run fica alinhado à direita, sem sobrepor os indicadores de Main.
- R1 incluiu scripts/player/trajectory_preview.gd e o posicionamento do HUD em run_root.tscn no escopo de edição. Não houve Godot/import/testes/QA.
### Ajuste final R2

A previsão termina imediatamente após registrar o N-ésimo ricochete permitido, antes de refletir e projetar outro segmento, alinhando-a ao retorno da bola. O check anterior ao incremento continua cobrindo max_bounces zero; colisões de grazing não incrementam nem consomem o limite.
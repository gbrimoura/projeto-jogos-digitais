# Plano — integração do loop de jogo

**Data:** 16/10/2026  
**Estado:** correções da rodada R1 integradas e congeladas para revisão estática; o merge continua sem resolução do índice, commit ou push.  
**Escopo:** integrar `origin/feature/game-loop-assets` sobre a `main` atual sem substituir contratos de sala, combate, animação ou arte que já existem.

## Decisões

- `RunRoot` será a cena principal e controlará a sequência de salas, o avanço de andares, as recompensas de chefe e o fim/reinício da run.
- Cada sala atual continua sendo uma instância de `scenes/main.tscn`. O controlador configura essas instâncias em modo gerenciado, removendo a porta somente daquela instância; `Main` segue responsável por vitória, parada e limpeza de projéteis, oferta `RunBuild` e proteção de entrada.
- `RunBuild` será estado compartilhado de `RunController` durante a run. A oferta existente aparece quando ainda está vazia e não se repete após uma escolha válida. O `RewardScreen` da branch permanece uma recompensa de chefe separada, com modificadores multiplicativos de dano, velocidade e raio do projétil.
- O modificador de dano multiplica a configuração final depois de aplicar `RunBuild` e arredonda para inteiro. Com a base atual de 1 de dano, `round(1 × 1,25)` continua 1; esse limite de quantização será registrado, sem inventar outro valor de balanceamento.
- A cena atual de chefe é o mesmo placeholder `main.tscn`; `run_root.tscn` configura uma run de um andar. Isso não define o GDD nem balanceamento final.
- As APIs incompatíveis da antiga implementação de jogador são adaptadas aos contratos atuais de `PlayerHealth` e `Player.take_damage(amount, source) -> bool`. O `TrainingTarget` mantém o ataque AoE 0,65/0,14/1,4 s, raio 140, dano-flash e visual Cartoon V2; o antigo contato por cooldown da branch não é combinado com a sentinela.
- O `ImpactSpark` da branch cobre o ricochete em parede; `CombatFeedback` atual continua responsável por parry e acertos aceitos, inclusive a carga. A inclusão de efeitos não altera dano, colisões ou ordem de callbacks.
- A geração aleatória atual de plataformas e o posicionamento de inimigos da `main` permanecem ativos em cada nova instância de sala.

## Limites

Sem Godot, importação, testes ou QA nesta frente, conforme instruções do repositório e da tarefa. O principal fará a revisão estática obrigatória com o estado congelado. Arquivos preexistentes fora dos escopos autorizados não serão editados; os arquivos de runtime abrangidos são os 16 paths da branch, scripts/world/main.gd para integração gerenciada e os paths adicionais scripts/player/trajectory_preview.gd/run_root.tscn autorizados na rodada R1.

## Disposições da revisão R1

A bola mantém o retorno autorizado pela branch: no limite de ricochetes, inclusive limite zero, volta ao alvo sem sweep, colisão, parry ou dano, e termina com motivo returned para liberar BallLauncher. O retorno ignora callbacks do sweep e preserva cancelamento seguro. O snapshot de configuração derivado por BallLauncher é compartilhado em semântica por spawn, lançamento e previsão; permanece cópia sem mutar o Resource-base.

Vitória pausa a árvore como Game Over. Quando a run terminou, R só reinicia em key press não repetido; o handler do RunController trata essa entrada durante pausa. Os labels da run foram posicionados no canto superior direito, mantendo o HUD de Main à esquerda.

Escopo adicional autorizado nesta rodada: scripts/player/trajectory_preview.gd e o HUD de run em run_root.tscn, além dos caminhos já autorizados na integração inicial. Sem Godot, import, testes ou QA. O stdout integral da R1 permanece com o principal; baseline, hashes e disposição resumida estão em historico/revisao-r1-baseline.json.
### Sincronização final do trajectory preview — R2

Após registrar o ricochete permitido de número N, a previsão marca o limite e termina antes da reflexão/segmento seguinte, no mesmo ponto em que RicochetBall inicia o retorno. O teste prévio para limite zero e colisões de grazing permanecem inalterados. Baseline, hashes dos arquivos e SHA-256 do pacote R2 imutável estão em historico/r2-preview-sync-baseline.json.
Resultado final: correções R1/R2/R3 integradas, pareceres registrados; merge autorizado na main. Gemini/Muse R2 e três revisores R3 sem correções obrigatórias. Opus indisponível por quota; sem runtime/testes. Consulte pareceres/README.md.

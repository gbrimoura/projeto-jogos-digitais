# Plano — sentinela de contenção

**Estado:** implementação concluída e congelada para revisão estática.
**Data:** 14/10/2026.

## Objetivo

Transformar o `TrainingTarget` existente em um inimigo sentinela estacionário que inicia um golpe circular corpo a corpo quando o jogador vivo entra na área. A ação mostra um círculo vermelho/laranja de aviso, espera o tempo de reação, consulta o corpo físico real do jogador e aplica dano pela API existente.

## Decisões provisórias

- Raio único da área: 140 px em coordenadas de mundo. A detecção usa o mesmo `CircleShape2D` e centro do golpe, para o aviso, a consulta de acerto e a geometria do círculo concordarem.
- Dano: 1; aviso: 0,65 s; janela ativa: 0,14 s; recuperação: 1,4 s. Vida e flash existentes permanecem.
- Estados no `_physics_process`: `IDLE`, `WINDUP`, `ACTIVE` e `RECOVERY`; sem movimentação, perseguição, teleporte ou rastreamento do jogador após o início.
- O acerto usa `PhysicsDirectSpaceState2D.intersect_shape` sobre o corpo na camada Player e raycast de LOS pela camada World. As plataformas e paredes bloqueiam dano.
- O nó segue usando o path e o contrato `TrainingTarget`, grupos `damageable`/`combat_enemy`, sinal `defeated` e remoção imediata após os 3 HP padrão.
- O efeito visual é desenho nativo, sem textura ou asset raster novo. Durante ACTIVE, a pose Cartoon V2 impact representa o golpe sem ativar shader flash. O flash de hurt/dano recebido é controlado pelo timer existente e mantém prioridade visual enquanto estiver ativo.

## Escopo

Runtime autorizado: `scripts/world/training_target.gd`, `scenes/training_target.tscn` e novo `scripts/enemy/containment_attack_visual.gd` sem `class_name`. Documentação somente nesta pasta. Jogador, vida, trabalhador, projéteis, salas, colisões de mundo, projeto, arte, recursos e estado Git ficam fora do escopo.

## Revisão e validação

Snapshots e SHA-256 dos dois arquivos runtime que serão editados foram capturados antes da implementação em `historico/base/`. A revisão de código é solicitada pelo agente principal após congelar o estado. Por instrução da tarefa, não executar Godot, importação, testes ou QA.



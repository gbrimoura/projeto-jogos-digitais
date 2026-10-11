# Especificação: feedback de combate para o teaser

**Estado:** implementação concluída; revisão estática final Gemini/Muse/Grok sem P1/P2. Opus AGY/Cursor bloqueado por quota, sem parecer. Runtime do feedback pendente.

## Contratos visuais

| Evento confirmado | Resposta | Posição |
|---|---|---|
| Bola aceita pela varredura de parry | Faísca/anel verde-ciano | Posição da bola após aplicar a fração real do sweep |
| Rebite aceito pela varredura de parry | Faísca/anel verde-ciano | Posição do rebite após aplicar a fração real do sweep |
| Ricochete de superfície que não pertence ao grupo `damageable` | Anel/faísca pequeno | `KinematicCollision2D.get_position()` |
| `RicochetBall` causa dano inimigo e recebe retorno booleano `true` | Impacto âmbar | `KinematicCollision2D.get_position()` |
| O caso anterior consome carga reativa | Impacto maior e com marca visual diferente | Mesmo ponto de colisão; antes da mudança para `CONSUMED` |
| Carga em estado `CHARGED` | Pulso de alpha/largura no `ChargeVisual` existente | Ao redor da bola; apenas visual |

Retorno `false`, `null`, ou qualquer valor não booleano não indica dano aceito e não produz impacto inimigo nem consome a carga. Um retorno `true` letal produz exatamente um impacto antes de o sweep retornar por `_stop_sweep_requested`/`_has_finished`.

## Estrutura nativa

- Cena `scenes/feedback/combat_feedback_burst.tscn`, raiz `Node2D`, sem textura/material/asset externo.
- Script `scripts/feedback/combat_feedback_burst.gd`: estilos `PARRY`, `WALL_RICOCHET`, `ENEMY_HIT`, `CHARGED_HIT`; campos exportados de duração, cor e tamanho; desenho e fade em `_draw`/processamento visual.
- Helper `scripts/feedback/combat_feedback.gd`: recebe a raiz da cena atual e a posição mundial; captura ID e `SceneTree`, agenda despacho deferred e, ao executar, verifica instância, `is_queued_for_deletion`, árvore e `tree.current_scene == root`. Só então instancia e adiciona como filha direta da sala, define `global_position` e inicia o efeito. Se a cena mudou, descarta.
- Limite de 20 efeitos por sala contando efeitos ativos e despachos deferred pendentes; excesso é descartado. A contagem pendente fica em metadado transitório da raiz e é removida no despacho. O burst usa `PROCESS_MODE_INHERIT`, `top_level = true` para coordenadas globais e continua filho direto da cena, herdando pause e teardown.
- `ChargeVisual` usa apenas `_process` e propriedades visuais enquanto `CHARGED`; sua geometria, colisão e condição de estado permanecem inalteradas.

## Pontos de integração

- `RicochetBall._physics_process`: ao aceitar um parry, enfileirar na posição efetiva depois de aplicar `fraction`; no caminho de colisão, passar `collision.get_position()` a `_apply_impact_damage` e emitir estilo de hit somente depois do retorno `true`. Capturar se estava carregada e enfileirar o estilo reforçado antes de marcar a carga `CONSUMED`.
- Ricochetes de parede são reconhecidos pelo collider que não está no grupo `damageable`; o evento de colisão de alvo usa exclusivamente o resultado booleano de `take_damage`.
- `HostileRivet._apply_parry`: enfileirar somente no ramo de parry aceito, na posição real do rebite antes da notificação compartilhada. Se rebite redirecionado acertar inimigo, emitir impacto âmbar somente quando `take_damage` retornar booleano `true`.
- `RacketController.register_parry_success` continua sem criar efeito; evita duplicação e não conhece a posição de cada projétil.

## Fora de escopo e validação

Sem mudanças em mecânicas, balanceamento, callbacks de vitória, contrato de dano ou geometria. Sem teste/Godot nesta frente. Revisão estática externa ocorre depois do freeze; runtime permanece pendente.

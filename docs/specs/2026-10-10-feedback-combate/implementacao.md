# Registro de implementação — feedback de combate

**Data:** 10/10/2026. **Plano de referência:** [plano](plano.md), [spec](spec.md).

## Estado

Implementação concluída. Gemini 3.8 Flash High, Muse Spark 1.3 xhigh e Grok 4.7 XHigh Fast concluíram a revisão final R2 sem P1/P2. Opus via Cursor e AGY foi bloqueado por quota; não há parecer Opus. O usuário confirmou manualmente que os upgrades anteriores funcionaram; o agente não executou testes, import, parse ou runtime do Godot neste incremento. Relatórios e fontes: [pareceres](pareceres/README.md).

## Entregas

- Cena nativa `CombatFeedbackBurst` e helper de despacho deferred com verificação de identidade da cena atual e limite de até 20 pedidos ativos + pendentes por sala.
- Parry aceito da bola e do rebite gera efeito verde-ciano na posição do projétil; `register_parry_success` continua sem efeito adicional.
- Ricochete em superfície fora do grupo `damageable` gera anel discreto no ponto de colisão.
- Dano contra inimigo produz impacto âmbar só após retorno booleano `true`, com estilo reforçado para o acerto carregado. A solicitação do efeito antecede consumo da carga e retorno do callback letal.
- `ChargeVisual` pulsa por alpha e largura enquanto a carga está ativa; nenhuma geometria, colisão, regra ou parâmetro de combate foi alterado.

## Arquivos

Novos: `scripts/feedback/combat_feedback.gd`, `scripts/feedback/combat_feedback_burst.gd`, `scenes/feedback/combat_feedback_burst.tscn` e os documentos desta pasta.

Integração autorizada: `scripts/projectile/ricochet_ball.gd`, `scripts/projectile/hostile_rivet.gd` e `scenes/ricochet_ball.tscn`. `scripts/player/racket_controller.gd` não precisou de alteração. Índice: `docs/README.md`. Snapshot: `GDD_Dieselpunk_Noir/04-combate-e-builds.md`.

## Verificação e pendências

Foi feita leitura estática do código, comparação dos hashes finais e `git diff --check`; nenhum teste/Godot foi executado conforme escopo. A validação visual do feedback em runtime permanece pendente. A primeira rodada foi substituída após ajustes posteriores ao anúncio inicial de freeze; R2 confirmou o estado final. Atualizações posteriores são somente metadados de resultado, sem alterar código ou contratos.

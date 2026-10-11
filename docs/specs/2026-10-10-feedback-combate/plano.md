# Feedback de combate para o teaser

**Estado:** implementação concluída; Gemini, Muse e Grok concluíram revisão estática final sem P1/P2. Opus AGY/Cursor bloqueado por quota, sem parecer. Runtime do feedback pendente.
**Data:** 10/10/2026. **Plano relacionado:** [upgrades básicos](../2026-10-10-upgrades-basicos/plano.md).

## Objetivo

Dar leitura visual breve a parry aceito, ricochete de parede, dano inimigo aceito e consumo da carga reativa. O usuário validou manualmente que os upgrades funcionaram e pediu textos objetivos; esse registro não é um teste executado pelo agente. Este incremento adiciona somente feedback visual nativo ao combate do teaser.

## Direção aprovada

- Parry aceito de bola ou rebite: faísca/anel verde-ciano, breve, na posição real do projétil.
- Ricochete em parede: faísca/anel pequeno e discreto no ponto de colisão. Não representar alvo de dano como parede.
- Dano inimigo aceito: impacto âmbar apenas quando `take_damage` retorna booleano `true`; golpe letal também recebe efeito. Um acerto que consome carga recebe uma variação mais intensa e distinta.
- Enquanto a carga estiver ativa, o anel `ChargeVisual` pulsa de forma leve.

## Implementação

Usar uma cena nativa `Node2D` reutilizável, desenhada com primitivas de Godot e parâmetros exportados de duração, cor e tamanho, além de um helper pequeno para enfileirar a criação visual. Efeitos têm duração curta, herdam o pause da cena e são filhos da cena de sala, nunca do projétil ou alvo atingido.

Callbacks físicos apenas capturam a cena atual, seu instance ID e a posição mundial imutável, e enfileiram a criação deferred. No despacho, revalidar validade/queued deletion, árvore e identidade da cena atual antes de adicionar o efeito; descartar o pedido se a cena já mudou. Limitar a 20 por sala a soma de efeitos ativos e pedidos deferred pendentes, descartando excesso sem um flood de chamadas.

O impacto recebe o ponto de `collision.get_position()`. O efeito de dano é enfileirado após confirmação estrita de retorno booleano `true`, antes do retorno do sweep por morte/parada e antes de consumir a carga. O parry é emitido apenas no ramo em que a varredura aceitou o hit, em cada projétil; não se duplica em `register_parry_success`.

## Escopo permitido

- Novos arquivos em `scripts/feedback/` e `scenes/feedback/`.
- Integração em `scripts/projectile/ricochet_ball.gd`, `scripts/projectile/hostile_rivet.gd`, `scripts/player/racket_controller.gd` e `scenes/ricochet_ball.tscn`, somente se necessária.
- Atualizar `docs/README.md` com estados; criar este plano/spec/registro e atualizar o snapshot indicado no GDD externo.

Nenhum outro código, cena, recurso, arte, áudio ou mecânica faz parte deste plano. Não alterar dano, velocidade, tempo de vida, cooldown, geometria de parry, colisões, carga ou regras de aquisição. Sem hitstop, tremor de câmera ou áudio obrigatório.

## Aceite

- As quatro respostas visuais são distintas e curtas; só parry/hit aceitos disparam seus efeitos.
- Posição dos efeitos vem do ponto do evento físico, sem parentear o efeito no objeto que pode ser removido no mesmo callback.
- Efeito letal e consumo de carga permanecem únicos e em ordem correta.
- Adição deferida não introduz filhos durante o flush nem transfere efeitos para uma sala nova.
- Sem assets externos; cena e parâmetros são editáveis no Inspector.
- Nenhum teste, import, parse ou runtime do Godot será executado nesta frente; validar estaticamente o diff.

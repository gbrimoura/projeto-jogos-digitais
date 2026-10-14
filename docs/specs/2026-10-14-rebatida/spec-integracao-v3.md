# Integração prospectiva — rebatida V3

## Escopo e contrato

Integrar as seis poses corpo+braço já reproduzidas em Aseprite ao runtime sem alterar os 28 frames preexistentes. Anexar os novos quadros como 28–33 no atlas; manter durations, tags e pixels anteriores. Criar `parry_body` one-shot em +X com durações 30/35/25/25/40/45 ms (200 ms no total). A raquete vermelha existente permanece como objeto independente, posicionada por anchors de mão por quadro; o corpo exportado não inclui cabeça/cabo da raquete. Espelhamento horizontal do sprite aplica o mesmo flip às anchors, sem rotacionar o corpo.

`RacketController` continua autoridade do estado, direção congelada e progresso físico. `Player` publica ao visual, a cada física após o controller de prioridade -100, estado/progresso/direção. `PlayerVisual` mantém precedência death > hurt > dash > air > land > parry > walk/idle; ao retomar parry após uma prioridade superior, sincroniza frame e progresso pelo relógio físico sem reiniciar a janela. `RacketVisual` usa a direção capturada e a âncora body-frame durante parry; idle/walk mantêm IK e poses aéreas preservam a mão nativa. Reset, cancelamento e morte limpam o estado. O bloqueio autoritativo de disparo em `BallLauncher` permanece como está; o cooldown da rebatida não se estende.

## Preservação e validação

Antes das edições, os assets e scripts de base são copiados para `historico/aseprite-v3/base-runtime/` com hashes SHA-256. A fonte Aseprite e o PNG recebem seis cels após os quadros existentes; a fonte arte V3, anchors e timings são registrados junto aos previews. A verificação desta integração é somente estática e documental, conforme as instruções vigentes: sem execução de Godot, import, testes ou Git. Não alterar controller, launcher, física, movimento, cenas, regras de colisão ou cadência de input.

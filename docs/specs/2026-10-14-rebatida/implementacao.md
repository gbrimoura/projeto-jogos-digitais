# Implementação — rebatida visual e bloqueio de disparo

Estado: integrado e congelado; Gemini R2 e Muse R1 concluíram revisão estática sem correções obrigatórias pendentes. Opus bloqueado por quota; Grok timeout sem parecer. Avaliação visual no jogo pendente.

## Alterações

- `racket_visual.gd`: timeline de seis transições em até 0,20 s com preparo, varredura acelerada, contato, acompanhamento e retorno; o progresso do parry segue o relógio físico e limpa quando o controller encerra a janela. Interpolação do grip e orientação do head; IK existente recalcula o cotovelo e limita o alcance. O rig inativo continua seguindo as âncoras da mão nativa. Animação de disparo preservada.
- `racket_controller.gd`: `is_swing_active()` retorna o estado físico `_active`; `get_swing_progress()` deriva o progresso do tempo restante sobre a duração capturada em `_begin_swing`. O sinal visual leva também a duração efetiva da janela. A ordem de prioridade física -100 foi preservada.
- `ball_launcher.gd`: `is_launch_available()` bloqueia durante o swing, incluindo prévia de trajetória e chamada direta a `try_launch`. A tentativa rejeitada não cria fila.

## Preservação e escopo

Snapshots dos scripts antes da implementação em `historico/base/`. A janela padrão permanece 0,20 s e o cooldown 0,55 s. Nenhuma alteração de hit/parry, projétil, movimento, arte, atlas, cena ou shader foi feita.

## Validação

Revisão estática manual dos caminhos de estado e das referências das poses. `git diff --check` terminou com exit 0; Git informou avisos de normalização CRLF em arquivos do workspace. Nenhum teste, Godot, importação ou quality audit foi executado. Pareceres originais, decisões e hashes em [pareceres/README.md](pareceres/README.md).

Hashes SHA-256 dos snapshots de base:

- `racket_visual.gd`: `DCAA9CA3EEB77E4F165014C8658ED142DCB8CDA2A98D32A83E5FF1D9C3EF6B3B`
- `racket_controller.gd`: `142A7DDA9C9FF5E27503A34C20B9D7F09E6EAF5327AF8E15DB845B6D38BA9FDE`
- `ball_launcher.gd`: `41376049656FF69FBC9EDB3C9168DEA4DF6567AED2A5B6DC233BF6CA10ADED7A`

## Incremento de expressividade — v2 (14/10/2026)

O gesto começa no grip neutro, retrai a mão até raio 11,3 px com o head a -80°, acelera pela varredura e passa pelo contato em t=0,50 da janela. O follow-through abre a raquete a +60°, seguido de um pequeno overshoot e retorno desacelerado ao endpoint exato do idle: grip `(24, 0)` e ângulo `0`. O controller, a leitura física do progresso, o clamp/IK 14/12 e o fallback de mão no ar foram preservados; as curvas e timings do disparo não mudaram.

Esta revisão incremental está congelada e revisada por Gemini/Muse, sem correções obrigatórias pendentes. Opus bloqueado por quota; Grok sem parecer utilizável. Não foram executados testes, Godot ou importação; `git diff --check` terminou com exit 0, com avisos de normalização CRLF do workspace. A proposta curta, snapshot da v1 e status dos pareceres estão em `spec-expressividade-v2.md`, `historico/expressividade-v1/` e `pareceres/expressividade-v2/`.

Hashes SHA-256 desta revisão: `racket_visual.gd` = `AD9EBF413A4702671DF1561B24F2E4CA134B6ACE0FE932F0C82847A681769C23`; snapshot v1 = `160FEF88D252374335243B1CB4A1CBB41D11F946452BD372F6B3FA3A09285104`.

Revisão expressividade V2: Gemini/Muse concluídos, sem correções obrigatórias; Opus quota, Grok saída vazia. [Consolidado e saídas originais](pareceres/expressividade-v2/consolidado.md). Sem execução de Godot/testes/gameplay.


## Integração da arte corpo+braço V3 (14/10/2026)

Após inspeção e aprovação do contact, os seis cels `BODY + ARM` foram anexados como frames 28–33 ao atlas Aseprite/PNG e registrados em `SpriteFrames` como `parry_body` one-shot, durações exatas 30/35/25/25/40/45 ms. Os 28 frames anteriores, tags e durações ficaram preservados; o exportador comparou os cels ao snapshot PNG antes de salvar. O snapshot completo está em `historico/aseprite-v3/base-runtime/`, com hashes SHA-256.

`Player` publica estado ativo, progresso físico e direção capturada após a atualização do controller prioridade -100. `PlayerVisual` para a reprodução automática do body e define frame/progresso a partir dessa fração física. A prioridade permanece morte > hurt > dash > ar > pouso > parry > walk/idle; quando um clip prioritário termina, o parry retoma no progresso atual, sem reiniciar a janela. A direção congelada só orienta o body enquanto `parry_body` está exposto; clips prioritários preservam o facing existente. Cancelamento/reset e morte limpam o estado.

`RacketVisual` acrescenta anchors por pose derivados da arte e orienta a cabeça vermelha separada segundo os ângulos de cada gesto, relativa à mira congelada. O corpo não gira como um todo; o flip horizontal do sprite também espelha anchors e raquete. O rig/IK idle-walk, comportamento aéreo e timeline de disparo permanecem como antes. `BallLauncher.is_launch_available()` e a proteção de `try_launch` não mudaram.

Validação estática: exportação pelo Aseprite gerou 34 frames 64×64, tag `parry_body` one-shot e atlas 2176×64; os seis tempos e o total de 200 ms foram conferidos na fonte. Os 28 frames-base foram comparados pixel a pixel ao PNG do snapshot antes da integração. Nenhum teste, import ou Godot foi executado; o GIF de runtime comparativo não foi produzido nesta etapa. `git diff --check` terminou sem erros de whitespace; o Git emitiu somente avisos de normalização CRLF.


## Pareceres da integração Aseprite V3

Gemini R3 e Muse R2 concluíram a revisão estática sem bloqueios funcionais, após esclarecer fontes completas. Gemini R2 aprovou a correção do GIF de preview para200ms. Opus bloqueado por quota; Grok timeout10min, sem stdout utilizável. [Saídas originais, decisões e hashes](pareceres/aseprite-v3/README.md). Sem testes, Godot ou importação.


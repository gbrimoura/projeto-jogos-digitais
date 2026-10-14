# Reprodução e integração Aseprite V3 — rebatida

Estado: arte aprovada e integrada após inspeção do contact; frames 28–33 do atlas ativo.

A prancha aprovada foi reproduzida em Aseprite 1.3.18.6 em seis cels 64×64, escala uniforme nearest 6:1, sola em y=56 e direção nativa +X. O corpo e braço/luva ficam na camada `BODY + ARM · cabeca isolada`; cabeça e cabo da raquete permanecem em layer separada e não entram no body-arm exportado. A composição integral foi mantida como referência. Paleta: 27 cores-base do runtime mais os três vermelhos aprovados da raquete; alpha binário. A metadata preserva bounds, anchors da mão/ombro, origem, escala e hashes.

As poses e timings são preparo 30 ms, recolhimento 35 ms, varredura 25 ms, contato 25 ms, follow-through 40 ms e retorno 45 ms, total 200 ms. O arquivo Aseprite editável recebe a tag one-shot `parry_body`. O GIF de referência tem quantização de centésimos de segundo, duração aproximada `[30,40,20,30,40,40]` ms, também totalizando 200 ms; os tempos exatos ficam na fonte Aseprite e no SpriteFrames runtime.

Após aprovação do contact, a integração adicionou somente os frames 28–33 ao atlas e a animação `parry_body` a SpriteFrames. O snapshot imutável dos 28 frames anteriores está em `historico/aseprite-v3/base-runtime/`. O exportador Aseprite verifica que os pixels antigos correspondem ao PNG-base antes de anexar os novos frames. `PlayerVisual` sincroniza o frame e progresso pelo relógio físico do `RacketController`; maior prioridade de morte, hurt, dash, ar e pouso continua valendo. `RacketVisual` prende a raquete existente aos anchors por pose e espelha os anchors junto ao sprite; a camada de corpo não duplica raquete/cabo. O bloqueio autoritativo de lançamento não foi alterado.

A referência PNG original foi preservada. Contact aprovado, fonte Aseprite, PNG e script reprodutível estão na pasta `pitch-assets/protagonista-rebatida-aseprite-v3/` no GDD.

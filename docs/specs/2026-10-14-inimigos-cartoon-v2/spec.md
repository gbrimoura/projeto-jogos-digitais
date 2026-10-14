# Especificação — inimigos cartoon V2

**Estado:** arte aprovada e integrada por cópia byte a byte nos quatro paths autorizados em 14/10/2026. O snapshot art-only está em `historico/etapa-arte-only/`.
**Data:** 14/10/2026.
**Referência:** `../../../../GDD_Dieselpunk_Noir/pitch-assets/inimigos-cartoon-v2/referencia-inimigos-cartoon-v2.png` (1983×793; mantida inalterada).

## Direção visual

TrainingTarget é um alvo cartoon com cabeça marfim grande, visor laranja angular e tubo grosso ancorado na base. RivetWorker tem capacete vermelho com aba, face marfim, luvas e botas robustas e ferramenta compacta conectada à mão. O principal aprovou o contato 4× por leitura cartoon, expressão, silhuetas e conexão da ferramenta.

## Formato e registro

- Cels nativos 64×64, alpha 0/255, nearest uniforme 8:1 por personagem e sem dithering. Alvo: 3 frames na ordem idle/impacto/desativado. Rebiteiro: 5 frames na ordem idle/andando/mirando/disparo/recuperação.
- TrainingTarget: base edge y=56, centro x=32, corpo 35×44 nativo. Collider de referência 72×96 permanece sem alteração.
- RivetWorker: feet edge y=56, facing à direita, corpo 23×31 nativo. Muzzle calculado em (43,38.25) nativo para mirar/disparo. Collider de referência 46×64 permanece sem alteração.
- Paleta: 14 cores-base existentes e swatch localizado `#FE5B01` amostrado da referência para pixels laranja nos visores; máximo observado 15 cores opacas por frame. Fundo quase neutro removido por flood-fill conectado às bordas; outline azul-preto preservado.
- Durations dos cels são metadados visuais. Nenhum tempo de IA, HP, alcance, projétil ou regra de jogo foi alterado.

## Arte e integração

Os fontes imutáveis da etapa artística, o Lua, metadata, contato e variantes ficam em `GDD_Dieselpunk_Noir/pitch-assets/inimigos-cartoon-v2/`. Os quatro arquivos runtime foram substituídos por cópias byte a byte:

- `assets/enemy/training_target/training_target-atlas.png`
- `assets/enemy/training_target/training_target.aseprite`
- `assets/enemy/rivet_worker/rivet_worker-atlas.png`
- `assets/enemy/rivet_worker/rivet_worker.aseprite`

Os recursos SpriteFrames continuam nos mesmos paths e permanecem inalterados. Scripts, cenas, shader, `project.godot`, colisões, jogador, pisos e salas não foram modificados. A verificação foi estática por SHA-256. Godot, importação, gameplay e testes não foram executados.

## Baseline

`historico/base/hashes-base.md` registra 20 itens antes da reprodução. Os quatro atlas/fontes foram intencionalmente substituídos; os outros 16 arquivos snapshot/protegidos conferem com os hashes anteriores. `historico/etapa-arte-only/` preserva o plano e spec da etapa anterior à integração.
| Arquivo integrado | SHA-256 da fonte e destino |
| --- | --- |
| `assets/enemy/training_target/training_target-atlas.png` | `B81CC88B02B37F740845DED39A146D9480D8EBD57F6B493F4B8491CE986E99D6` |
| `assets/enemy/training_target/training_target.aseprite` | `78DC598E6BF20E4DA56A5FD975597245871F14365010E9D5C85B17A827807C88` |
| `assets/enemy/rivet_worker/rivet_worker-atlas.png` | `9028C991C29F072E4AA41C85FCFD7648F0650BB80AE4C41658BC056E26E75DD1` |
| `assets/enemy/rivet_worker/rivet_worker.aseprite` | `DD0747F3FD159CB78397B31F417734F54EC6CDA014C951397CB812D7F0E24450` |
## Resultado da revisão e integração
Cartoon V2 integrado por substituição dos quatro PNG/ASE. Gemini e Muse R2 concluídos sem defeitos estáticos remanescentes; Grok sem parecer útil e Opus bloqueado por quota. [Saídas, decisões e hashes](pareceres/README.md). Código/recursos/física/IA preservados; sem Godot/import/testes/gameplay e sem commit/push nesta tarefa.


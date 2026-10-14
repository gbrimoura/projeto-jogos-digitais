# Plano — inimigos cartoon V2

**Estado:** integração concluída em 14/10/2026 por substituição byte a byte dos quatro PNG/ASE autorizados. O snapshot art-only anterior está em `historico/etapa-arte-only/`.
**Data:** 14/10/2026.

## Objetivo

Reproduzir a prancha Cartoon V2 aprovada para TrainingTarget e RivetWorker em sprites 64×64, e integrar as quatro fontes PNG/ASE mantendo o runtime existente. Não adaptar a arte V1 nem alterar scripts, cenas, recursos, shader ou gameplay.

## Método de arte

- Aseprite 1.3.18.6, um Lua de lote para as oito poses, nearest uniforme 8:1 por personagem e flood-fill 4-conectado do fundo neutro ligado às bordas.
- Alpha binário; contorno azul-preto preservado; 14 cores-base existentes e swatch `#FE5B01` amostrado, restrito às regiões laranja dos visores. Máximo observado: 15 cores opacas por frame.
- Fontes Aseprite com 3 cels de TrainingTarget e 5 de RivetWorker; atlas PNGs 192×64 e 320×64; contato nearest 4× aprovado pelo principal.

## Contrato visual e runtime preservado

TrainingTarget: poses idle/impacto/desativado, centro x=32, base edge y=56, corpo 35×44 nativo. RivetWorker: idle/andando/mirando/disparo/recuperação, facing à direita, pés edge y=56, corpo 23×31 nativo; muzzle registrado em (43,38.25) nas poses mirando/disparo, ferramenta conectada. A ordem é compatível com os recursos SpriteFrames existentes.

A integração substituiu somente `assets/enemy/training_target/training_target-atlas.png`, `assets/enemy/training_target/training_target.aseprite`, `assets/enemy/rivet_worker/rivet_worker-atlas.png` e `assets/enemy/rivet_worker/rivet_worker.aseprite`. Recursos, scripts, cenas, shader, colisores e temporizadores permanecem intactos. Engine, importação e testes não foram executados.

## Baseline e histórico

`historico/base/` contém snapshots e hashes anteriores à geração. Antes da cópia, os 20 itens do snapshot/protegidos correspondiam ao baseline. Depois da cópia, os 16 itens não substituídos continuaram idênticos; cada destino novo corresponde byte a byte à fonte aprovada. O plano e spec art-only foram preservados em `historico/etapa-arte-only/`.
## Resultado da revisão e integração
Cartoon V2 integrado por substituição dos quatro PNG/ASE. Gemini e Muse R2 concluídos sem defeitos estáticos remanescentes; Grok sem parecer útil e Opus bloqueado por quota. [Saídas, decisões e hashes](pareceres/README.md). Código/recursos/física/IA preservados; sem Godot/import/testes/gameplay e sem commit/push nesta tarefa.


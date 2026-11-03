# Registro de implementação — 02/11/2026

## Entrega

- Aseprite 1.3.18.6 gerou o kit em R2 após o principal pedir uma camada de noite opaca para que o céu não dependa da clear color do viewport. O fundo usa `#0E0D0E` em todas as linhas nativas y=0..279 e alpha0 de y=280 a323. A versão R1 foi arquivada em `assets/environment/factory_v1/lobby_v1/history/r1-before-opaque-base/` com suas fontes, PNGs, previews, logs e hashes antes de regenerar.
- A prévia contextual R2 foi inspecionada e aprovada visualmente pelo principal; mantém materiais e silhuetas industriais de baixo contraste, cabine como destino visual e o Hero original.
- O estudo do Hero usa o frame0 crop64×64 original, desenhado64×64 nativo em `(88,223)`. O limite inferior visível do crop é y=280 nativo, correspondente a y=560 no mundo; pixels do Player não foram alterados.
- Runtime recebeu os PNGs nativos como dependências `Texture2D preload`, com destino de desenho exatamente2× e `TEXTURE_FILTER_NEAREST`. Somente `scripts/world/lobby_visual.gd` mudou; a cena permaneceu idêntica ao baseline.
- A placa âmbar em `(888,384,176,40)`, letreiro bitmap, três luzes dinâmicas, campos/métodos públicos da visualização, coordenadas das portas, interpolação, piso/atlas e limites foram preservados. A arte substitui as massas de fundo, bancada e moldura/portas chapadas; o piso continua no topo lógico y=560.

## Arquivos

- Fontes editáveis: `assets/environment/factory_v1/lobby_v1/source/lobby-backdrop.aseprite` e `elevator-doors.aseprite`.
- Gerador: `assets/environment/factory_v1/lobby_v1/source/generate_lobby.lua`.
- Exports e regiões: `assets/environment/factory_v1/lobby_v1/export/` e `manifest.json`.
- Previews: `assets/environment/factory_v1/lobby_v1/preview/`.
- Baseline e versão R1: `docs/specs/2026-11-02-lobby-pixel-art/historico/baseline/` e `assets/environment/factory_v1/lobby_v1/history/r1-before-opaque-base/`.

## Produção e limites de validação

Aseprite batch R1 e R2 terminaram com exit0; versão1.3.18.6. Logs completos R2 estão em `source/aseprite-production-r2.stdout.log`, `source/aseprite-production-r2.stderr.log` e `source/aseprite-production-r2.exit-code.txt`. R2 reportou bounds do Player e pé a y=560 world. Os PNGs foram abertos com o visualizador e examinados; a composição não é captura do Godot.

Nenhum Godot, import, parser, lint, teste, auditoria de pixel/`quality_audit`, simulação, gameplay, commit ou push foi executado. A revisão estática final dos produtos integrados permanece com o principal; hashes atuais estão em `assets/environment/factory_v1/lobby_v1/manifest.json`.


## Fechamento do principal
Arte R2 aprovada visualmente em estudo1152x648; integração Texture2Dpreload mantém contratos e cena. R3 corrige apenas API de paleta das fontes e duplicações, sem mudar pixels dos3exports (hashes idênticos). Gemini/Muse final favoráveis; Grok sem parecer; Opus obrigatório bloqueado por quota. Fontes ASE editáveis, PNGs nativos e gerador Lua entregues; preservação17/17fontes anteriores conferida por hash. Consulte pareceres/README.md para saídas originais e avaliação crítica. Nenhum Godot/import/teste, commit ou push.

# Registro — polimento visual v2 da porta lateral

Baseline local anterior às alterações preservado em `historico/baseline-r1/`. SHA-256 conferidos contra os arquivos originais antes de qualquer mudança:

| Arquivo | SHA-256 R1 |
|---|---|
| `scripts/world/side_door_visual.gd` | `f7ed64b224b868b0934e7c83f320ace419f2b01f71c7978a3c7659399f5bfd2e` |
| `assets/environment/factory_v1/door/side-opening/preview-side-opening.lua` | `25471e50e8835d58aa47e89eae5d5b82cffa3dd3e05042289d3411c43e89e33c` |
| `assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png` | `11599bc614aaff71cf582aa0472871165d1b7b38b2373a5c66cf48fee989a9aa` |

A paleta confirmada tem 20 cores; o polimento usará exclusivamente cores já usadas no helper. Nenhuma alteração de runtime foi feita quando este baseline e o adendo prospectivo foram registrados.
## Estado final congelado

Polimento visual concluído e prévia inspecionada pelo principal. A silhueta externa, estados, API, flip e camada foram preservados. Os retângulos da prévia agora espelham os do runtime por conversão local `(+32,+64)`. Sem execução de Godot, importação, testes, quality audit ou QA.

| Arquivo final | SHA-256 |
|---|---|
| `scripts/world/side_door_visual.gd` | `2c5e4369b9184c09acdf55bc33248886fd6f652d029989f29ca9f92dfabe2389` |
| `assets/environment/factory_v1/door/side-opening/preview-side-opening.lua` | `048fe852f5168cefa003fcf3bf4c1d7fe3b76c133d8ea29bd542060c3523019c` |
| `assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png` | `9e0329a916e3b2291dab12dd50e6d17946ee0404c69a6b2c86b14238b3d0b3e9` |

Consolidação do principal: Gemini sem defeito estático; Grok sem stdout útil; Opus Cursor quota e Muse chave expirada. Sem parecer desses três. Preview final inspecionado; fontes estáveis, arquivos fora do escopo preservados. Sem engine/import/testes/QA/commit/push. Pareceres originais em pareceres/README.md.

# Registro — Porta lateral recortada na parede

O usuário esclareceu: “as portas tem que ser na parede lateral,como se fosse um buraco”. Isso substitui a proposta anterior de painel na parede de fundo. O PNG/Aseprite landscape anterior permanece arquivado em `assets/environment/factory_v1/door/` como estudo descartado e não tem referência ativa nas cenas/scripts.

Implementação visual: `factory_wall_visual.gd` recorta pixels exatamente no intervalo `[432,560)` nas faixas x=0..64 e x=1088..1152, sem esticar UV; o export default deixa a parede intacta. `SideDoorVisual` ocupa 64×128 sobre o recorte, exibe grade dentro do túnel quando fechada e um vão escuro quando aberta. Usa apenas cores da paleta fábrica e desenha sem textura filtrada. `WallVisuals` e a camada do recorte ficam efetivamente em z=-1; fundo z=-10, player z=1.

As raízes ExitDoor/EntranceDoor, sensor 96×108 da saída e sensor desativado da entrada permanecem; nenhuma parede física foi aberta. Entrada fica fechada e seu `flip_h` só espelha o visual. A saída conserva estados/labels, E, sinais e transição. O buraco comunica abertura visual e não permite travessia física.

Montagem estática gerada por Aseprite Lua e inspecionada em `assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png`; estados fechado/aberto nas duas laterais, atlas/piso existentes e protagonista em primeiro plano. A fonte de preview fica ao lado; nenhuma runtime art foi gerada ou substituída.

O baseline local anterior à edição de runtime e os SHA-256 dos cinco arquivos preexistentes estão em `historico/baseline-local/`; as cópias incluem alterações não commitadas. Nenhum teste, engine, import, QA, collider ou script de gameplay foi executado/alterado. `.import` não foi modificado.
## SHA-256 do estado congelado

| Arquivo | SHA-256 |
|---|---|
| `scripts/world/factory_wall_visual.gd` | `1b67320689fdc71c76913f7a38c697b3914481d4226908076063f69320980f73` |
| `scripts/world/side_door_visual.gd` | `f7ed64b224b868b0934e7c83f320ace419f2b01f71c7978a3c7659399f5bfd2e` |
| `scenes/exit_door.tscn` | `5cd9bcae6286e2e1d3c1dc50a39a958c6b536fc0b321060fdc2371dcfb88246b` |
| `scripts/world/exit_door.gd` | `f99819ffe052b0fb7973b457c00c1c9aafc1d6cfd5c2ebfe80340ae94a1d4c5a` |
| `scenes/main.tscn` | `0ca69baeb1c66af8a2a3aef02a4844149f690218fd31e149b606a214533b13a4` |
| `scenes/second_room.tscn` | `1b738417fa9c68d597cf39b78a18238fb8701ee6a01eca73e6180f40977d59fe` |
| `assets/environment/factory_v1/door/side-opening/preview-side-opening.lua` | `f414e06d2d6547782c237aa9c8c0c1874997f014a27eac44b6071222d32ac6f1` |
| `assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png` | `ca009f064588908fbb03f88aba77b52eaa5b63c3ead811167765ac89cb48ad28` |
## R2 — clipping da prévia e recursos redundantes

O preview R1 foi preservado sem alteração em `historico/R1/porta-lateral-preview.png`, junto da fonte Lua R1. A nova renderização compõe cada faixa em imagem intermediária de 1152×224 e recorta todos os blits de parede, piso, abertura e protagonista aos limites da faixa; a sombra inferior começa em y=124 conforme o retângulo de runtime. Nas cenas `main.tscn` e `second_room.tscn`, removi somente a declaração redundante do script `side_door_visual.gd`; a segunda cena passou de `load_steps=21` para `20`.

Aseprite foi executado apenas para gerar a nova prévia. Não foram executados testes, engine, importação ou QA.

| Estado / arquivo | SHA-256 |
|---|---|
| R1 arquivado — `historico/R1/preview-side-opening.lua` | `f414e06d2d6547782c237aa9c8c0c1874997f014a27eac44b6071222d32ac6f1` |
| R1 arquivado — `historico/R1/porta-lateral-preview.png` | `ca009f064588908fbb03f88aba77b52eaa5b63c3ead811167765ac89cb48ad28` |
| R2 — `assets/environment/factory_v1/door/side-opening/preview-side-opening.lua` | `25471e50e8835d58aa47e89eae5d5b82cffa3dd3e05042289d3411c43e89e33c` |
| R2 — `assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png` | `11599bc614aaff71cf582aa0472871165d1b7b38b2373a5c66cf48fee989a9aa` |
| R2 — `scenes/main.tscn` | `67fff6889cae9369b089348a64b662183d01e3e2c20d0ce55f280bdc472d2986` |
| R2 — `scenes/second_room.tscn` | `062d590ce48877ddc954dca5037ac36c7a6b2e24ba73eb6a716381dfb9c25f7f` |

Consolidação do principal: Gemini/Grok R2 sem regressão concreta no delta; Opus AGY plano sem bloqueio; Opus Cursor quota e Muse API expirada, sem parecer de implementação. Fontes estáveis e prévia final inspecionada. Sem Godot/import/testes/QA/commit/push. Detalhes em pareceres/README.md.

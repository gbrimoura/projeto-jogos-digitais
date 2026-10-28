# Diff do freeze R3 contra o baseline local

O baseline é a cópia byte a byte preservada em `historico/baseline-local/`; os números abaixo vêm de comparação textual `git diff --no-index`, sem comparação com HEAD.

| Arquivo | Linhas adicionadas | Linhas removidas |
|---|---:|---:|
| `scripts/world/exit_door.gd` | 137 | 61 |
| `scenes/exit_door.tscn` | 2 | 1 |
| `scripts/world/main.gd` | 204 | 79 |
| `scripts/world/run_controller.gd` | 93 | 3 |
| `scenes/main.tscn` | 26 | 6 |
| `scenes/second_room.tscn` | 27 | 7 |
| `scripts/world/room_transition_overlay.gd` | novo arquivo; sem snapshot no baseline | — |

O conteúdo runtime congelado está identificado por SHA-256 e tamanho em bytes em `sha256.json`.

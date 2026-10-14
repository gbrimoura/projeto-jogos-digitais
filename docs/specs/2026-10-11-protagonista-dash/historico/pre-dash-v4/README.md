# Snapshot anterior ao dash v4

Estado congelado antes de desenhar a referência v4, com 25 quadros. Use esta cópia como fonte para comparação e integração determinística; não edite os arquivos deste snapshot.

| Arquivo-fonte | Cópia do snapshot | SHA-256 |
|---|---|---|
| `assets/player/player-animations.png` | `runtime/assets/player/player-animations.png` | `58059c4b51f502f210922f624accb0f10baba1a042b73c39fcd04a277982c9bc` |
| `assets/player/source/player-animations.aseprite` | `runtime/assets/player/source/player-animations.aseprite` | `f56e61168412cd423072bac4de9000d65833c424ee5ed37fba634f989cbb6412` |
| `scripts/player/player_visual.gd` | `runtime/scripts/player/player_visual.gd` | `658871cf4587a797431104b7569da5293daf7ee86286d267cdb1b1807b556620` |
| `scripts/player/player.gd` | `runtime/scripts/player/player.gd` | `2e86fdfc1040046b53e1d7ac3dd4f3d8bebf5d9278b765e693662744676c7099` |
| `scripts/player/movement_controller.gd` | `runtime/scripts/player/movement_controller.gd` | `59c8987f01c769c40f6657e09bc6e69a1eeb6fefe98220d84f15d6c9a9f6e6ec` |
| `resources/player_sprite_frames.tres` | `runtime/resources/player_sprite_frames.tres` | `ff45afd4124cbff029f564990acd1d12def5945b048c9a775c970cd598dcdc30` |

O atlas registra idle 0–5, walk V8 6–13, dash 14–16 e pulo V3 17–24. Dash está como 40/40/60 ms, não cíclico. `PlayerVisual` considera dash nativo para a direita e mantém a regra atual de `flip_h`; não houve mudança nos scripts durante a preparação deste snapshot.

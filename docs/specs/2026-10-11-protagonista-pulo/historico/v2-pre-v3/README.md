# Snapshot runtime V2 pré V3

Este diretório preserva o estado V2 dos recursos substituídos em 12/10/2026. Os arquivos foram copiados antes de regenerar o atlas e SpriteFrames; não foram editados. O runtime V2 foi rejeitado esteticamente pelo usuário por falta de mobilidade/peso, embora tenha servido de base para preservar idle, caminhada, dash e o comportamento de PlayerVisual.

## Conteúdo

- runtime/assets/player/player-animations.png — atlas V2 de 26 quadros, 1664×64.
- runtime/assets/player/source/player-animations.aseprite — fonte editável combinada de 26 quadros.
- runtime/resources/player_sprite_frames.tres — SpriteFrames V2.
- runtime/scripts/player/player_visual.gd — código visual V2; continuou idêntico no runtime V3.
- plano-v2.md, spec-v2.md, implementacao-v2.md — documentação imediatamente anterior à integração V3.
- scripts/player/player.gd não foi duplicado: permaneceu inalterado durante esta integração, SHA-256 2e86fdfc1040046b53e1d7ac3dd4f3d8bebf5d9278b765e693662744676c7099.

Os hashes dos arquivos preservados estão em SHA256SUMS.txt. O diretório está sob docs/.gdignore, para impedir importação como recursos de jogo.
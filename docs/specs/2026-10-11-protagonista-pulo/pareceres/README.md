# Versão atual — escala do pulo V4 (13/10/2026)

Luna xhigh corrigiu apenas jump17–24; import Godot concluído. Gemini/Muse/Grok sem correções obrigatórias, Opus quota. [Pareceres e hashes V4](escala-v4/README.md). As seções abaixo são histórico.

# Revisões da reprodução em Aseprite — V3

Arte-fonte corrigida em arquivos referencia-v2; código/runtime Godot continua na V2. A avaliação visual final do usuário permanece pendente. Pareceres iniciais, correções e revisão final: [reprodução V3](reproducao-v3/README.md).

# Revisões — animação de pulo V2

## Estado

A V2 foi integrada e importada pelo editor Godot 4.7.2. O principal inspecionou e aceitou a arte; depois autorizou um ajuste pontual em land_1, levando a compressão do torso a 2→1→0 px. Gemini, Muse e Grok concluíram revisão estática do código e da geração desta revisão sem achados reais no escopo; Opus bloqueado por quota. Os resultados foram consolidados pelo principal em v2/README.md. A aprovação visual final do usuário e a conferência no jogo também permanecem pendentes.

Os pareceres e a avaliação da V1 estão preservados em historico/v1/docs/specs/pareceres/README.md. Eles cobrem as três poses estáticas anteriores e não são atribuídos à V2.

## Estado estável para revisão

- PlayerVisual: scripts/player/player_visual.gd, SHA-256 658871cf4587a797431104b7569da5293daf7ee86286d267cdb1b1807b556620.
- Player: scripts/player/player.gd, SHA-256 2e86fdfc1040046b53e1d7ac3dd4f3d8bebf5d9278b765e693662744676c7099.
- SpriteFrames: resources/player_sprite_frames.tres, SHA-256 34224da2f32274641b8140a8d2dce6a78fd2cef1ebfbee6e4213e25d4f9735a8.
- Atlas: assets/player/player-animations.png, SHA-256 d04e34d9179070c2f5298fbc7490ef50d352917c3da5df457dc28af7803264cb.
- Lua V2: GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2.lua, SHA-256 3ea76aa16a3548f9af53c6d42c3291053ea4b475c5250f91e0797e4c82309aae.
- Contact V2: GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo-v2-contact.png, SHA-256 b0fc08f52199847d6a031f06b263d7e049e8b80dbb5b7a6e8ac5e1b9505aec10.
- GIFs V2 4×: esquerda `adf7c12b38a9e36c3586dda95ef1eb0f46d28ad84ff3809632a011e8e0e6b5e2`; direita `da2a3f3d56265d2c33ff339760e3745926f93b6152d259f17184ad1e6b46a188`.

## Limites da evidência

As execuções Godot foram restritas à importação de recursos pelo editor; a importação final (`--headless --editor --path projeto-jogos-digitais --import --quit`) terminou com exit 0 e stderr vazio. Não houve teste, gameplay ou quality audit. A importação confirma que o editor abriu o projeto e carregou os recursos; ela não confirma a sensação ou a legibilidade visual em jogo.

Saídas originais, modelos, escopo, hashes e avaliação do principal estão em [pareceres V2](v2/README.md).


## Integração Godot V3 — 12/10/2026

[Revisão da integração](integracao-godot-v3/README.md): Gemini/Muse/Grok concluídos sem defeitos concretos; Opus bloqueado por quota. Arte reproduzida agora integrada e importada sem erros. Conferência visual do usuário em jogo pendente.

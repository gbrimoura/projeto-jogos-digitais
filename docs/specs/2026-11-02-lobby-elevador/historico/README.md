# Histórico e baseline pré-produto

A captura abaixo representa o working tree local no início da fase documental, incluindo modificações locais anteriores a esta tarefa. Não representa HEAD/commit e não deve ser usada para remover ou sobrescrever alterações do usuário. Nenhum arquivo de produto foi escrito nesta fase.

SHA-256  caminho relativo

42a90285feacc10034cbd02d270b66a48a88e33ac33f570a6cfb67329d9c5ff1  project.godot
6fc7522c9f8e83f39c7cca5694246cb6b241cc9d79c5b1c7e8275c4d91205c98  run_root.tscn
1fc1e81ff31ec8ebdfb928f5d41a2d7544c58b6721db0c1ac10c7fcf82a757f6  scripts/world/run_controller.gd
2a0eda364faeeeee7ba06b349a8f1aeaf37407f3c29907543e52b8d075a08461  scripts/world/room_transition.gd
bf2971e0f0194f46d728f5ab2e3b7dec4783405c8026ec0e34663f678f9005ab  scenes/main.tscn
d1d2707899a8cb3dedff8311a8ff46998c6d55e561580f421c935c30baf6b46d  scenes/player.tscn
d3dc1cb7fd19673eab4e2e6fa8221b0e57365017673425617ee7ef242caef566  scripts/player/player.gd
bb08df627852d4b9dbdc68a4f21897875a84c614109a9bb3c326fe92895ffa61  scripts/player/player_health.gd
d08b53121f33247fa4339016f58a6dd9b20c6a788fc3104150b4152117a52275  scripts/player/ball_launcher.gd
36a1a7d7a1f826a7281a6e8f9a9d84157ae9d078a31f3d033c68a32239a455cb  scripts/player/racket_controller.gd
74178a45a2087b27c7ae2a9876afe859f047fa1a0f9a8f241f83b85bcc57b7e5  scripts/ui/hud/bitmap_text.gd
b0165e15cd26977a04345fe2401888f3e35262d3b4e0ca53a5de71e7bdf9dd37  resources/environment/factory_tileset_v1.tres
bd37ecdbfea99050306ef9e77f2e2eaac221acfc8e62f3c17c621721a1fba6f0  resources/environment/factory_floor1_base_boiler_texture.tres
f9241611fa55fc19f7fcb270d6da0f6a37c5af946305893b815af5497b2bdda8  resources/environment/factory_floor1_base_maintenance_texture.tres

Cenas/projeto propostos como produto: project.godot, scenes/lobby.tscn (ausente neste baseline), scripts/world/lobby.gd (ausente neste baseline), scripts/world/run_controller.gd. O escopo proíbe alterar run_root.tscn, scenes/main.tscn, RoomTransition e componentes do Player; os hashes destes estão como guardas de preservação.

Leitura estática inicial: project.godot aponta para run_root.tscn. run_root.tscn já tem floors_per_run=1 e common_rooms_per_floor=10. Os assets de fundo modular são 576×324 nativos ampliados 2× para 1152×648; o atlas de tiles de fábrica usa células 32×32. A fonte bitmap atual lê font.json e font-atlas.png por HudBitmapText.
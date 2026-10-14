# Integração — raquete de pingue-pongue e disparo

Estado: arquivos integrados; Gemini/Muse concluíram revisão estática e correções. Opus bloqueado por quota; Grok timeout, sem parecer utilizável. Avaliação em runtime pendente.

A cena player.tscn substitui o pivô/raquete vetoriais por RacketVisual sob PlayerVisual e cabeça PNG vermelha 14×14, escala 2 e filtro nearest. O cabo curto, a luva e o braço articulado seguem a mira 360°. Idle/walk usam máscara de texels e rig ligado ao ombro; ar, dash, hurt e pouso preservam os braços nativos e posicionam somente a raquete por âncora de mão por quadro. O timeline corporal, a física e os colliders não foram editados.

BallLauncher emite launch_accepted após o lançamento aceito, recebendo posição real e direção para a apresentação. Disparo começa no contato e recupera em quatro poses/125 ms; não atrasa a bola, não cria bola visual duplicada e não muda spawn seguro perto de paredes. Parry emite swing_started, congela direção e toca seis poses/200 ms inclusive sem acerto. Cancelamento, morte e reset limpam o visual. Guarda de input, dano, cooldown e detecção mantêm a lógica anterior.

Arquivos editados nesta tarefa: scenes/player.tscn; scripts/player/player.gd; scripts/player/ball_launcher.gd; scripts/player/racket_controller.gd; docs/README.md. Novos: scripts/player/racket_visual.gd; scripts/player/racket_arm_mask.gdshader; assets/player/racket/generate_racket_head_v4.lua, racket_head_v4.aseprite e racket_head_v4.png; esta pasta documental. scenes/racket.tscn permanece como arquivo legado sem instância na cena player; player_visual.gd foi preservado.

Preservação confirmada por SHA256 igual ao início desta tarefa:

- assets/player/player-animations.png: C87E5D07A4B375378330A56AD1307DED9A8464D95FFB53F9DC09C838E7E211E6
- assets/player/source/player-animations.aseprite: 59065A95A80E8F00EA8867CC42CDB780773F4F0BB9520CD5D014ED9173B9955F
- resources/player_sprite_frames.tres: 38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164

Implementação por GPT-6 Luna xhigh, serviço Fast/priority não confirmável. Arte gerada com Aseprite real; verificação estática de dimensões/alpha e git diff --check sem erros. Nenhum teste, gameplay, importação ou comando Godot foi executado, conforme AGENTS.md. Pareceres originais, decisões e hashes em [pareceres/README.md](pareceres/README.md); snapshots do estado local anterior em historico/baseline. Sem commit, push ou mudança de branch.

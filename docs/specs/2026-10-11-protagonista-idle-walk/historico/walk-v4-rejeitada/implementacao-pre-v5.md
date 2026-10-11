# Implementação — idle e caminhada

Implementada pelo subagente GPT-6 Luna xhigh; a interface não permite selecionar ou confirmar Fast/priority. Exportações executadas pelo principal no Aseprite 1.3.18.6 e arte inspecionada visualmente.

## Resultado

Idle v2 aprovado preservado; caminhada frontal com membros alternados e espelhamento horizontal. Atlas de 12 quadros 64×64, fonte editável Aseprite, SpriteFrames idle/walk e AnimatedSprite2D em scenes/player.tscn. As duas salas usam a mesma cena do jogador. Walk só no chão com velocidade horizontal real superior a 8 e sem dash; ar/dash usam primeiro quadro estático de idle. Colisão e combate preservados.

## Revisão e limites

Gemini, Muse e Grok concluíram revisão estática. Achados de Gemini/Grok sobre revive na mesma instância foram avaliados com os chamadores: o fluxo atual reinicia via reload_current_scene, portanto não exigem correção nesta integração. Um futuro revive precisará restaurar saúde, estado visual e flag de apresentação de morte. Pareceres originais preservados.

Opus 5.5 High via Cursor: preflight bloqueado por quota, sem parecer. Não houve execução de Godot, testes ou quality audit. Exportação Aseprite e inspeção de arte não constituem validação do gameplay. Aparência/cadência precisam de conferência manual no jogo; arte em escala 2× mede cerca de 100px e mantém o collider 28×76. Fonte editável: assets/player/source/player-animations.aseprite.

## Ajuste de pernas — v2

Quadris ancorados, articulação ≤1px e bota de balanço alternada; fase bob sincronizada com os dois passos. Atlas e Aseprite atualizados. R2 Gemini/Muse/Grok sem defeitos concretos pendentes na fonte; Opus por quota e runtime pendentes. Pareceres em pareceres/correcao-pernas-v2/README.md.

## Caminhada expressiva — v3

Mãos e botas até 2 px, corpo inclinado 1 px nos picos, ombros/quadris ancorados. Atlas e fonte editável atualizados; idle e tempos preservados. Exportação Aseprite exit 0 e inspeção visual principal/Luna. Gemini e Muse concluíram revisão estática sem correções pendentes; Grok terminou sem parecer (stdout vazio) e Opus bloqueado por quota. Essas revisões e a validação no Godot permanecem pendentes. Consulte pareceres/expressividade-v3/README.md.


## Caminhada redesenhada — v4

A fonte Lua cria oito poses articuladas nativas para a esquerda e copia literalmente os quadros do idle e dash do atlas de entrada versionado no diretório pitch-assets/protagonista-walk. Contact sheet e GIFs esquerdo/direito foram exportados pelo Aseprite 1.3.18.6 (exit 0). O principal inspecionou o contact sheet; não inspecionou dinamicamente os GIFs. O atlas runtime agora mede 1088×64, com idle 0–5, walk 6–13 e dash 14–16. O SpriteFrames usa oito poses de 75 ms. A velocidade do ciclo usa abs(velocity.x)/260, limitada a 0,65–1,35 somente em caminhada; os demais estados usam scale 1.0.

O pé de apoio mantém sola y=56 apesar do bob; o pé em balanço sobe até y=53. A cabeça e antena usam pixels do idle aprovado. O principal aprovou o contact sheet antes da integração. Revisão estática v4 permanece pendente. O editor Godot 4.7.2 headless reimportou player-animations.png com status 0; isso confirma somente a importação do recurso. Não houve gameplay, testes ou quality audit.


## Correção do preview direcional

Muse R1 encontrou que o GIF rotulado direita espelhava o personagem, mas diminuía x. O script agora aumenta x para o deslocamento à direita e mantém o caminho da esquerda de direita para esquerda; o metadata registra ambos. A fonte e os dois GIFs foram regenerados com Aseprite (status 0); os GIFs usam --scale 6 e medem 960×384. O spritesheet exportado permaneceu byte a byte igual ao PNG runtime, assim como a fonte Aseprite combinada; não houve nova cópia de runtime ou reimportação. Os comandos de geração e exportação foram adicionados ao README da pasta de arte. O principal inspecionou apenas o contact sheet, não os GIFs dinamicamente. Nenhum teste foi executado.

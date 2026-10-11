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


## Rejeição artística v4 e integração v5

O usuário rejeitou a arte v4 como feia/esquisita e pediu uma leitura mais frontal. O plano, a especificação e o registro anteriores foram preservados em historico/walk-v4-rejeitada/. Os pareceres técnicos v4 continuam em pareceres/caminhada-v4/ e não representam aprovação visual.

A prévia inicial de duas poses preservou o volume do idle e foi aprovada pelo principal para completar o ciclo. O principal também inspecionou o contact final de oito poses e autorizou integrar. A aprovação visual do usuário não foi registrada; revisão estática v5 pendente. As poses v5 são frontais, 64×64, feitas sobre pixels do idle, com oito fases articuladas e bob de 1 px.

O PNG de 1088×64 e a fonte editável v5 foram copiados para assets/player/player-animations.png e assets/player/source/player-animations.aseprite. O recurso SpriteFrames já tinha os índices corretos 0–5/6–13/14–16 e durações 420, 140, 180, 140, 540, 80 ms; 8×75 ms; e 40, 40, 60 ms, por isso não foi alterado. PlayerVisual/Player não foram alterados. A importação foi executada com:

    Godot_v4.7.2-stable_win64.exe --headless --editor --path projeto-jogos-digitais --import --quit

O processo retornou exit 0 e reimportou player-animations.png. Durante o carregamento, Godot reportou erros de parsing em player.gd (chamada set_walking com dois argumentos) e player_visual.gd (classe global PlayerVisual duplicada/oculta); esses scripts não foram alterados nesta frente. Não houve gameplay, testes ou quality audit.


## Correção da descoberta de classe no import v5

O primeiro import do PNG retornou exit 0, mas o carregamento do editor imprimiu erros de parsing: o cache global mapeava PlayerVisual para docs/specs/2026-10-11-protagonista-dash/historico/pre-dash/player_visual.gd, cópia histórica com API antiga de um argumento. O erro não vinha de uma regressão no script ativo. Para impedir que o Godot indexe scripts sob documentação, foi criado o arquivo vazio projeto-jogos-digitais/docs/.gdignore, conforme a organização documentada pelo Godot.

Reimport executado com Godot_v4.7.2-stable_win64.exe --headless --editor --path projeto-jogos-digitais --import --quit: exit 0, stdout do editor normal e stderr vazio. Leitura de .godot/global_script_class_cache.cfg confirmou PlayerVisual em res://scripts/player/player_visual.gd. O PNG runtime permanece SHA-256 bcc43aacb6f5679432be22abb797fecfc8ad6b2519b99a225e631fbfd522a04b. Comparação RGBA feita antes da cópia final confirmou igualdade byte a byte para os quadros idle 0–5 e dash 14–16; esse import é integração de recursos, não teste de gameplay.


## Ajuste de compressão e elevação v5

O principal identificou que compressão e elevação usavam bob de +1 px, repetindo quatro subidas curtas no ciclo. As duas poses de compressão agora usam bodyBob=-1 (torso desce 1 px); elevações permanecem em +1 px (torso sobe 1 px), enquanto contatos e passagens ficam em 0. As oito poses, membros, apoio em y=56, índices e durações não mudaram.

Antes de regenerar, os exports v5 anteriores foram preservados em pitch-assets/protagonista-walk/historico/v5-pre-ajuste-bob/. Lua, Aseprite editável, contact sheet, PNG/JSON horizontal e GIFs esquerdo/direito foram regenerados a partir do input congelado (SHA-256 19d218d2630eaac25d14fd2106b5298b1102de30475cbed05903a177a933a8e9). As quatro operações Aseprite terminaram com exit 0 e stderr vazio. O PNG runtime 1088×64 tem SHA-256 722043ec65573ebead392a88ef1f35993c9f00e0ba0f1517d9a9e69100020996; comparações RGBA mantiveram 0 divergências nos quadros idle 0–5 e dash 14–16.

O PNG e Aseprite regenerados foram copiados para assets/player/ e assets/player/source/. Godot 4.7.2 executou --headless --editor --import --quit, exit 0 e stderr vazio; PlayerVisual continua mapeado para res://scripts/player/player_visual.gd. Nenhum teste ou gameplay foi executado.


## Revisão estática v5 e decisões finais

Gemini, Muse e Grok concluíram análise estática sobre o estado congelado. Opus claude-opus-5-5-high ficou bloqueado por quota no preflight. Relatórios e hashes em pareceres/caminhada-v5/. A sobreposição local da bota na perna elevada foi aceita pelo principal após inspeção de contact e avaliação Luna; pode suprimir detalhes locais, e aprovação estética do usuário segue pendente. Luna corrigiu somente comentário de oito poses, status da fonte e limite declarativo32 no Lua/metadata; principal inspecionou o delta sem regenerar imagens. Não houve gameplay ou testes.

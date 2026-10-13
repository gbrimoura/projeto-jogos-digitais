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


## Refinamento de braços V6 e correção de conexão

A V5 movia o antebraço lateralmente em até ±2 px, com mudanças de 2–3 px entre fases de 75 ms. V6 limita o swing a ±1 px, ancora os ombros e move a mão por arco vertical de até ±1 px. Após o principal inspecionar o contact comparativo, ele aprovou integração do refinamento.

A conferência final de pixel mostrou que follow-through +1 aplicado somente à linha y=44 separava pontos da mão do antebraço. Foram adicionadas pontes mínimas na região dos braços nos quatro quadros afetados. O principal inspecionou o contact já corrigido e confirmou a coesão. Nenhuma região além dos braços mudou; cabeça/torso/bob, pernas/botas, idle, dash, cadência, atlas, facing, scripts e SpriteFrames permaneceram conforme V5.

A fonte protagonista-walk-v6-bracos.lua usa o input congelado de 960×64. Aseprite regenerou fonte editável, PNG/JSON horizontal, contact e GIFs esquerda/direita; cada operação retornou exit 0 e stderr vazio. O PNG runtime 1088×64 foi comparado com a referência V5 congelada: idle 0–5 e dash 14–16 têm zero divergências; as 200 alterações de walk estão dentro do envelope dos braços; zero diferenças fora. Alpha permanece binário e as cores pertencem à paleta de entrada.

PNG e Aseprite V6 foram copiados para assets/player/ e assets/player/source/. SpriteFrames não mudou. Godot 4.7.2 executou --headless --editor --path projeto-jogos-digitais --import --quit: exit 0, stderr vazio. Isso é importação de recurso, sem gameplay ou testes.

Hashes finais: PNG runtime 9c69d9f03b97db69c4b74ef735008ad6dce8a0d463c68bffed26aff15389a143; Aseprite runtime 75668700cd1e1a65dfa2aa4226480455db30703d7fc2d29d6057a35d70ca8a4c; Lua V6 79032aad4d8bb57401d3788a9afcd4b4eac1910a0e100a918eac69c310c78834; metadata bea0bed29fb36937205fdcbf3c6af5bd87133e0f6edf86b9ca16fad2ec53cf07; input congelado 19d218d2630eaac25d14fd2106b5298b1102de30475cbed05903a177a933a8e9. Detalhes em spec-v6-bracos.md. Revisão estática pendente; aprovação visual do usuário não registrada.


## Pareceres finais braçosV6

Gemini/Muse/Grok concluíram revisão estática. Opus bloqueado por quota no preflight. Principal avaliou os achados com Luna contra os pixels: o notch entre dedos da luva direita mantém conexão e preserva formaoriginal; sobreposição de detalhes escuros na mão elevada aceita como limitação artística local. Nenhuma imagem/fórmula alterada depois da revisão. Pareceres/hashes/decisões em pareceres/bracos-v6/README.md. A avaliação visual do usuário segue pendente; import semerros, nenhumteste/gameplay.


## Movimento leve dos braços — V7

A V7 move o antebraço e a luva juntos em até 1 px vertical nas oito poses da caminhada frontal. Os ombros ficam ancorados; o swing lateral V6 permanece em ±1 px. A mudança está restrita aos braços; cabeça, torso/bob, pernas, botas, idle, dash, facing, tempos e SpriteFrames não mudaram.

O principal inspecionou o contact comparativo V6/V7 e autorizou a integração. Aseprite 1.3.18.6 exportou a folha horizontal, JSON e GIFs de preview esquerda/direita em nearest 6×; exit 0 e stderr vazio. O PNG de 1088×64 e a fonte Aseprite foram copiados para assets/player/ e assets/player/source/. Godot 4.7.2 executou `--headless --editor --path projeto-jogos-digitais --import --quit`: exit 0, stderr vazio; isso foi importação de recurso, sem gameplay ou testes. Revisão estática V7 pendente; aprovação visual do usuário não registrada.

Hashes e artefatos estão em [spec-v7-bracos.md](spec-v7-bracos.md).


## Revisão final V7

Gemini, Muse e Grok concluíram a revisão estática delimitada dos braços sem bugs apontados. Opus claude-opus-5-5-high bloqueado por quota no preflight, sem parecer. Saídas originais, hashes e avaliação do principal em pareceres/bracos-v7/README.md. Nenhuma fórmula ou imagem alterada após a revisão. Os deslocamentos de 1 px são relativos ao torso; a posição absoluta também inclui o bob existente. Avaliação estética do usuário pendente; importação sem erros, sem testes ou gameplay.



## Correção local dos ombros — caminhada V8 V3, 12/10/2026

O principal apontou uma separação leve nos ombros da caminhada V8. A causa foi confirmada no mapa de pixels: a camada da cabeça, copiada do idle até y=32, ainda continha os dois pads amarelos e seus contornos (x=24–28 e x=34–39). Ao mesmo tempo, o corpo gerado por IA já tinha seu próprio par de ombros ligado ao torso, em y=33–35. Como a cabeça e o torso usam deslocamentos independentes, a cópia dos pads podia aparecer duplicada ou separada do braço.

A correção remove somente esses 11 pixels da camada da cabeça em cada pose, nas coordenadas y=32, 33, 32, 31, 32, 33, 32 e 31. A camada do corpo não teve alterações. O par de ombros que pertence ao corpo permanece; o colar central x=29–33 e os pixels reais do capacete, visor, antena e cabeça também permanecem. A comparação de oito poses registra 88 pixels alterados no composto, todos na remoção dos pads da camada da cabeça. O diff detalhado está em [diff-v3-ombros.txt](../../../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/diff-v3-ombros.txt).

O principal inspecionou o comparativo normal e o detalhe ampliado 8×, com V2 acima e V3 abaixo, e aprovou a integração. A imagem de detalhe é [protagonista-walk-v8-v3-ombros-contact-detalhe-antes-depois-8x.png](../../../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/protagonista-walk-v8-v3-ombros-contact-detalhe-antes-depois-8x.png). A [folha de contato normal](../../../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/protagonista-walk-v8-v3-ombros-contact-4x.png) e os GIFs [esquerda](../../../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/protagonista-walk-v8-v3-ombros-preview-esquerda.gif) e [direita](../../../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/protagonista-walk-v8-v3-ombros-preview-direita.gif) também foram exportados.

A integração partiu do snapshot de runtime [pre-ombros-v3](historico/pre-ombros-v3/README.md), que preserva o estado V8 V2 de 25 quadros antes da substituição. Foram atualizados somente o PNG runtime e sua fonte Aseprite editável de duas camadas. No atlas, apenas os quadros de caminhada 6–13 receberam o patch local; os outros 17 quadros foram preservados pixel a pixel. Durações, tags, facing e SpriteFrames permaneceram iguais: caminhada de oito quadros a 75 ms cada, baseline y=56. Não houve alteração de scripts, cenas, física, input, combate ou TRES.

### Arquivos e hashes SHA-256

Arte e prévias em GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8:

- protagonista-walk-v8-v3-ombros.lua — 696C58E50350B3E1459B24C4779F29EF21C3B255D7FF300EC409514E1BA0B339
- integrate-walk-v8-v3-ombros.lua — 2D5807E612B8FCB75027A0F590191B82E33BDA365F08079BABE7CACA61062AEF
- protagonista-walk-v8-v3-ombros-poses.aseprite — 26ED755636DEE22402D2546B4D99ED0686611D0F23435FA099179CF1FE832D60
- protagonista-walk-v8-v3-ombros-poses.png — FB10BA44021724AAC9E3939300CF2C3424CFCD76EE408B5EFD39C20430B8F5A3
- protagonista-walk-v8-v3-ombros-metadata.json — 80297B372EB970E2C585CB8EF8386278CE275951A275D4E77EA88166396079FE
- Contact 4× — D2011AB3B2429DA924557DDFA6E1061F706BA1605530B520A95B2446D8C2524A
- Comparativo de detalhe antes/depois 8× — 2BBAC0FC5480C8741361B5AE65114BCDC4D6FE190C21D7DEFF864D65C0BF4E24
- GIF esquerda — D06520B81B29CA2B7EF213DB9CCC7B56B390C45193FBA16FE835BE0786238B45
- GIF direita — FC695F48F394153A7547A06F8DBB472A6DDEEB26A776BAA72A84E1BA4B79CF6D

Runtime:

- assets/player/player-animations.png — 58059C4B51F502F210922F624ACCB0F10BABA1A042B73C39FCD04A277982C9BC
- assets/player/source/player-animations.aseprite — F56E61168412CD423072BAC4DE9000D65833C424EE5ED37FBA634F989CBB6412
- assets/player/player-animations.png.import — FEB38B6EC7B49D4BC2C050E2012A688027825B08A9564A30853E842FBB8C5815 (igual ao snapshot)
- resources/player_sprite_frames.tres — FF45AFD4124CBFF029F564990ACD1D12DEF5945B048C9A775C970CD598DCDC30 (igual ao snapshot)

### Exportação e importação

As exportações e a integração no Aseprite 1.3.18.6 terminaram com status OK. A primeira chamada ao Godot exibiu erro de cópia/carregamento da extensão do addon godot-git-plugin (DLL); a saída observada não apontou erro no PNG, no TRES ou em scripts, e o exit code dessa chamada não foi registrado separadamente. Uma nova importação com Godot 4.7.2 usando --headless --editor --path projeto-jogos-digitais --import --quit foi capturada com exit code 0, stderr vazio e sem erro de recurso no stdout. O import atualizou o cache .ctex do atlas. Os logs finais estão em GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/godot-import-v3-ombros-stdout.txt e godot-import-v3-ombros-stderr.txt. Nenhum teste de gameplay foi executado.
Pareceres finais da correção: [ombrosV3](pareceres/ombros-v3/README.md). Gemini/Muse/Grok recebidos; possível apagamento de ombro sugerido porGrok descartado após leitura dos pixels pré-clear: cream/contorno da mandíbula AI, não amarelo dospads. Arte/runtime sem mudanças após a revisão. Opus por quota.

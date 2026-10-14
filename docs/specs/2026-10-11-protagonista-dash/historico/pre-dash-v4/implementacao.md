# Implementação — dash do protagonista

Implementação pelo GPT-6 Luna xhigh: gerador Lua, PlayerVisual, SpriteFrames e documentação. Fast/priority não selecionável nem confirmável na interface. Principal executou exportações com Aseprite1.3.18.6 (exit0), inspecionou a arte e integrou o atlas PNG e a fonte editável.

## Resultado

Três poses de dash — impulso, avanço e sustentação — em 40/40/60ms, reprodução não cíclica. Atlas de quinze quadros 64×64, total960×64. Idle v2 e walk v3 preservados. Dash tem prioridade visual no chão e no ar, reinicia uma vez na entrada, mantém a última pose enquanto ativo e retorna ao estado apropriado ao sair. Morte interrompe a reprodução; trilha, física e controles preservados. As duas salas usam a mesma cena do jogador.

## Correção de exportação

Aseprite expandia automaticamente a tag walk ao acrescentar frames. O gerador restaura os intervalos originais após append e cria dash em seguida. Export final confirmou idle0..5, walk6..11, dash12..14/repeat1. R1 preservada em historico/ e pareceres/estado-r1.json.

## Revisão e limites

Gemini, Muse e Grok concluíram R2 sem bugs concretos pendentes nas fontes. Inspeção visual principal/Luna sem clipping ou fendas evidentes, com poses legíveis. Opus claude-opus-5-5-high bloqueado por quota; nenhum parecer, obrigação ainda pendente. Não foram executados Godot, testes ou quality_audit; o implementador fez revisão estática e git diff --check. Validar aparência/cadência manualmente no jogo. Pareceres completos em pareceres/README.md.

## Prévia horizontal corrigida

O GIF original mostrava poses estacionárias. O novo protagonista-dash-horizontal-v1.gif mostra deslocamento nos dois sentidos, com 16quadros e holds nos extremos. Fonte separada criada pelo Luna; export/inspeção pelo principal. Gemini/Muse/Grok concluíram revisão estática sem bugs concretos; Opus por quota. Runtime/atlasGodot intactos. Relatórios em pareceres/preview-horizontal/README.md.

## Pose lateral v2 — 11/10/2026

GPT-6 Luna xhigh redesenhou as três poses em perfil +X, corrigiu proporções e preservou visor, peito creme/amarelo e pernas escuras. Principal exportou fonte, atlas, contato e GIF no Aseprite1.3.18.6 (exit0); inspecionou contato e integrou assets/player/player-animations.png e source/player-animations.aseprite. Atlas960x64,15quadros; tags idle0..5, walk6..11, dash12..14/repeat1 confirmadas pelo metadata. Preview16quadros, deslocamento nos dois sentidos. Nenhum teste/Godot executado. Revisão v2: Muse concluído sem bloqueios; Gemini recebido, achados avaliados e descartados por evidência de API/export. Grok timeout10min sem parecer; Opus bloqueado por quota, sem parecer. Histórico das fontes/specs anterior em historico/pose-pre-v2.

## Postura compacta v3

GPT-6 Luna xhigh alterou somente gerador Lua, defaults da prévia e README de arte. Principal exportou no Aseprite1.3.18.6 (exit0) atlas960x64, fonte combinada15quadros, contato3poses e GIFpreview16quadros880ms; integrou assets/player/player-animations.png e source/player-animations.aseprite. Metadata confirma idle0..5/walk6..11/dash12..14/repeat1 e40/40/60ms. Inspeção visual principal e Luna: postura mais baixa, cabeça/ombro ligados, sem tesoura ampla ou clipping/desconexão evidente; apoio ainda diagonal pode receber polimento estético futuro. Gemini/Muse concluíram revisão estática sem regressões concretas; Grok timeout10min sem parecer; Opus quota bloqueado no preflight, sem substituição. Fast não confirmávelinterface. Sem testes/Godot/quality_audit.

## Correção de integração: atlas sem importação

Após captura de jogador invisível, log existente confirmou No loader found para PNG e falha do SpriteFrames. Luna xhigh executou Godot --headless --editor --path projeto --import (exit0), gerando .png.import/.ctex e cache. PNGhash antes/depois idêntico; código/arte preservados. Gemini/Muse/Grok revisaram metadados sem bugs concretos; Opus quota. Registro/hashes em pareceres/correcao-importacao-atlas. Gameplay não executado; usuário deve reiniciar execução para carregar textura importada.

## Correção de orientação ao andar

Usuário confirmou sprite após importação e apontou caminhada invertida. Idle/walk nativos apontam para esquerda; dash para direita. Luna xhigh ajustou _apply_facing para considerar a direção nativa da animação e conectou animation_changed, reaplicando flip ao entrar/sair do dash mesmo sem mudança de direção. Apenas scripts/player/player_visual.gd alterado; controles/física/arte/tempos preservados. Inspeção estática e git diff --check sem erros; sem testes/Godot. Revisões em pareceres/correcao-orientacao; Opus preflight quota bloqueado.

Revisão da orientação concluída por Gemini/Muse sem achados concretos; Grok timeout2min sem parecer, Opus quota. Apenas revisão estática, sem gameplay/testes.

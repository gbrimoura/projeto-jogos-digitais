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

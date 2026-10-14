# Expressividade V2 — revisão concluída

Implementação GPT-6 Luna xhigh; Fast/priority não confirmável. Revisões somente leitura sobre script completo e diff autorizado inline, com limite curto de 3 minutos para esta alteração apenas de curvas. Preflight uma vez: AGY/Cursor/OpenCode Go, autenticação e modelos exatos confirmados. Estado congelado registrado em estado-r1-sha256.json.

- Gemini 3.8 Flash (High), AGY plan: done, sem P1 ou correção obrigatória; saída original gemini-r1.txt.
- Muse Spark 1.3 Contributor, OpenCode opencode-go/muse-spark-1.3-contributor xhigh/plan: done, sem bloqueios; saída original muse-r1.txt.
- Grok grok-4.7-xhigh-fast, Cursor plan: terminou com exit 0, mas retornou somente linha vazia; nenhum parecer utilizável. Saída original grok-r1.txt preservada. Não classificado como timeout nem aprovação.
- Claude Opus claude-opus-5-5-high, Cursor plan: blocked por quota; saída original opus-r1.txt. Sem substituição de modelo.

## Avaliação do principal

As três curvas possuem oito chaves com tempos estritamente crescentes, endpoint de grip (24,0) e ângulo 0 idênticos ao idle. Windup recolhe a pegada a ~11,18 px e inclina a cabeça até -80°. Follow-through chega a +60° e alcance ~25,94 px, dentro dos 26 px do rig. O braço quase estendido nessa fase é parte do gesto; IK/clamp continuam seguros. Mudanças de velocidade entre easings são intencionais para acentuar passagem/contato, sem descontinuidade de posição. Nenhum ajuste adicional foi imposto sem inspeção visual em jogo.

O diff altera somente chaves e easing do parry. SHOT, relógio físico, controller/launcher, bloqueio de disparo, sprites/atlas, materiais e cenas foram preservados. Snapshots anteriores mantidos em historico/expressividade-v1. Leitura estática e git diff --check pelo implementador; nenhum teste, Godot, importação ou gameplay executado. Avaliação estética em runtime permanece pendente.

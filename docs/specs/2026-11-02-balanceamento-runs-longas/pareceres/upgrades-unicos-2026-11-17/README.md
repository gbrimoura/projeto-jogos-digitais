# Revisões: upgrades com identidade (17/11/2026)

Os snapshots .diff foram calculados contra cópias do estado anterior a esta tarefa para separar as mudanças locais já existentes. Cada rodada conserva diff, stdout, stderr, exit code e metadados.

- R1: Muse apontou P3 em copy, limite e reset do Rolamento.
- R2: Muse apontou P2 sobre perda do bônus ao reaplicar/substituir build e P3 sobre informação de limite/copy.
- R3: sem P1/P2; achados P3 em copy/trigger. A observação sobre main.gd foi considerada não acionável porque consume_pending_snapshot valida antes de retornar.
- R4: sem achados P1/P2/P3 no snapshot final.
- Gemini 4 Hydrogen (High) e Gemini 3.8 Flash (High): pendentes; o isolamento AGY não foi comprovado, nenhum diff foi enviado.
- Grok 4.7 XHigh Fast e Claude Opus 5.5 High via Cursor Agent: pendentes; agent --list-models exigiu autenticação, sem fallback.
- OpenCode identificou o modelo no stderr; variante efetiva/modelUsage não ficou visível e permanece não verificada.
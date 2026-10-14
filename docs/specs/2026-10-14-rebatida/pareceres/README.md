# Pareceres — rebatida e bloqueio de disparo

Estado: revisão estática concluída por Gemini e Muse, sem correções obrigatórias pendentes. Implementação GPT-6 Luna xhigh; Fast/priority não confirmável. Preflight uma vez: autenticação/modelos exatos confirmados em Cursor, AGY e OpenCode Go. Fontes autorizadas inline, somente leitura, sem execução de testes/Godot. Hashes dos três scripts congelados em `estado-r1-sha256.json`; R2 esclareceu fontes completas sem editar o estado.

| Revisor | Ferramenta e modelo | Resultado |
|---|---|---|
| Gemini R1/R2 | AGY plan, Gemini 3.8 Flash (High) | R2 done, sem P1/P2; falsos P1 de R1 retirados após fornecer fontes completas |
| Muse R1 | OpenCode plan, opencode-go/muse-spark-1.3-contributor xhigh | done, sem bloqueios demonstráveis |
| Grok R1 | Cursor plan, grok-4.7-xhigh-fast | timeout: limite 5 min, processo encerrado sem stdout utilizável |
| Opus R1 | Cursor plan, claude-opus-5-5-high | blocked por quota; nenhum parecer |

Saídas originais preservadas: `gemini-r1.txt`, `gemini-r2.txt`, `muse-r1.txt`, `grok-r1.txt` e `opus-r1.txt`. Nenhuma substituição de modelo nem atribuição de aprovação aos pareceres ausentes. R2 Gemini teve limite curto de 3 min por analisar somente esclarecimentos de contexto e a guarda nova.

## Avaliação do principal

- Os P1 Gemini R1 provinham de trechos de contexto tratados como arquivos inteiros. `get_catch_radius`, `request_stop_active_sweep`, `_update_racket_visual` e `_update_feedback` existem completos. R2 recebeu arquivos completos e retirou todos os P1, sem alteração de implementação.
- A guarda nula do controller no launcher é intencional: não aceitar disparo sem a entidade que informa o rebate. No Player, o controller existe e é capturado em configure. Não há fila nem acionamento automático após rejeição; Player usa somente a borda `is_action_just_pressed` existente.
- A chave final interpolada tem grip `(24,0)` e orientação zero, idênticos ao idle; a conclusão via idle não exige hold ou bloqueio adicional. O cooldown permanece fora da guarda de lançamento.
- Progresso visual usa o timer físico capturado no início do swing. Disparo mantém o relógio visual próprio. Estado ativo e duração são definidos antes de emitir `swing_started(direction,duration)`, evitando leitura reentrante de estado antigo.
- Consultas e comportamento preexistentes de gamepad, cooldown residual em reset, sweep e feedback ficaram fora desta alteração. O jogo usa mira por mouse; não foram inventadas novas regras de entrada ou recarga.
- Cancelamento/reset/morte zeram o estado ativo e limpam o visual pela conexão de `swing_cancelled`. Atlas, assets, cenas, shader, pulo, dash e hurt não foram editados nesta rodada.

Validação proporcional autorizada: leitura estática e git diff --check sem erros. Nenhum teste, gameplay, importação ou comando Godot executado. Avaliação visual em runtime continua pendente.

Versão atual: [Aseprite V3 — arte e integração](aseprite-v3/README.md). As seções anteriores são histórico das curvas procedurais.

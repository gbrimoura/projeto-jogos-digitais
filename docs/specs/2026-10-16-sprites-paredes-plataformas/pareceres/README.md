# Pareceres

Inputs originais e hashes de R1/R2 em pareceres/ são imutáveis. Os achados R1 foram incorporados na V2; as decisões de R2, na V3. Esta pasta não substitui stdout ou inventário de revisão. O principal registra ferramenta/modelo/esforço, escopo, status, hash do estado revisado e decisão sem sobrescrever os inputs.

## Consolidação final — 16/10/2026

Estado: proposta V3 revisada por Gemini, Muse, Grok e Opus via Antigravity sem bloqueios documentais remanescentes. Implementação não iniciada. Branch local corrigir-sprites-salas-plataformas, base90b2e59; sem commit/push desta tarefa. Nenhum Godot/import/runtime/teste/QA executado.

Autoria e coordenação: GPT-6 Luna xhigh fez diagnóstico estático e escreveu plano/spec, V1/V2 preservadas em historico; Fast/priority não selecionável/confirmável. Principal criou branch, conferiu criticamente medidas/contratos, coordenou revisões e consolidou o resultado. Somente documentação foi alterada; mudanças alheias de editor/plugin/DLL/TMP preservadas.

Preflight realizado uma vez para AGY, Cursor e OpenCodeGo, autenticação/IDs disponíveis. Revisões somente leitura, timeout10min, sem comandos/engine/mutações. R1/R2/R3 recebem conteúdo completo inline, pois esta é revisão de plano, não execução. Entradas imutáveis review-input-r1/r2/r3.txt e hashes estado-r1/r2/r3-sha256.json; stdout original em arquivos por modelo/rodada e native exits separados.

Resultados fiéis:
- Gemini3.8Flash(High), AGY plan: R1 pediu precisão da porta/suporte/nós visuais; R2 sem bloqueio próprio; R3 done sem bloqueios, exit0.
- Muse opencode-go/muse-spark-1.3-contributor, OpenCode plan xhigh: R1 lacunas; R2 needs-input sobre preparo/falha e contratos; R3 done encerrou os bloqueios, exit0.
- Grok cursor-grok-4.6-xhigh-fast, Cursor plan: R1 exit0 apenasCRLF, sem parecer útil; R2/R3 pareceres úteis, exit0; R3 done sem bloqueios.
- Opus claude-opus-5-5-high, Antigravity plan: R1 exit0 com mensagem jetski/read_file negado no modo não interativo, sem parecer; R2 retornou blocked por problemas documentais B1/B2/B3/A1/M1, não por indisponibilidade; R3 done aprovou o plano documental, exit0. Não houve alteração de permissões ou uso de flags para contornar a negação.
- Opus claude-opus-5-5-high, Cursor plan: R1/R2/R3 exit1 ActionRequiredError por usage limit, sem parecer. Não substituído silenciosamente pelo AGY: ambos foram solicitados e registrados separadamente conforme a regra local específica de planos e a regra global. A exigência de revisão via Cursor segue indisponível por quota.

Decisões do principal incorporadas:
1. Invisibilidade segue sem causa comprovada; plano isola PNG/recurso/frame/CanvasItem/material/oclusão e não promete correção sem reprodução autorizada.
2. Paredes64×648 visíveis dentro do viewport, colliders reutilizados, shapes/skin alinhados e recorte/ordem do atlas definidos. Sobreposição com Floor intencional; teto físico permanece.
3. Porta standalone reposicionada1040,522 com sensor inteiro no lado jogável; troca por Area/E, sem abertura física. NodePaths relativos ao alvo filho direto estão corretos.
4. Layout autoral determinístico, suporte/X do alvo fixos, fallback explícito; preparo idempotente de Main antes de combate com rejeição managed/standalone sem vitória falsa. Contato com apoio é permitido, não obstrução.
5. Inventário de spawns, bounds e patrulhas conferido; alvo vivo é sólido e travessia completa por seu suporte é avaliada após derrota. Distâncias entre plataformas e margens teóricas não são prova de jogabilidade.
6. Root identificou salto reverso frágil e corrigiu proposta East para900,452, com gap105/subida67; identificou confusão linha55/borda56 e corrigiu fórmula sem mover sprites. Snapshots por fase, pipeline inconclusivo e autorização de testes foram esclarecidos.

Clarificações finais de leitura (sem nova decisão de design): toda validação geométrica usa coordenadas locais da sala, conforme spec§2; o termo centro global em§7 não exige consultar transform global fora da árvore. Layer8/mask9 são VALORES de bitmask (collision_layer=8, bit da camada4), não números ordinais de camada. A faixa lateral31 indica intervalo de posição onde o jogador cabe ao lado do alvo, não corredor para atravessar o collider vivo. O texto free_room designa descartar instância ainda fora da árvore com Node.free(), não uma API existente. Detalhes rotineiros de assinatura não exigem decisão humana.

Limites: causa visual, LOS, saltos e manobras permanecem pendentes de verificação autorizada. Aprovação é do plano, não do comportamento no jogo. Não abrir/executar/importar Godot nem rodar testes automaticamente ao implementar; seguir o pedido explícito de verificação do usuário. Estado final hashes em estado-final-documentos-sha256.json; hashes R3 preservam o conteúdo exato lido pelos revisores, anterior ao registro de status pelo principal.

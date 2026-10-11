# Etapa A — Gemini 3.8 Flash High

Revisão estática inline; modelo exato via AGY, modo plan. Sem Opus por autorização explícita.

STATUS: done
SUMMARY: Revisão estática documental e arquitetural da Etapa A concluída com sucesso com base exclusivamente nos fontes integrais e especificações fornecidos inline. A implementação cumpre com rigor todos os critérios estipulados para a Etapa A: (1) Três recursos de definição (`impacto_reforcado.tres`, `motor_acelerado.tres`, `carga_reativa.tres`) configurados via `UpgradeDefinitionResource`; (2) `RunBuild` como `RefCounted` desacoplado, com contagens estritamente 0 ou 1 e total delimitado por `MAX_UPGRADES = 1`; (3) Clonagem profunda (`duplicate(true)`) idempotente das configurações-base por jogador e a cada disparo individual de bola, mantendo os arquivos `.tres` imutáveis; (4) Snapshot em `RoomTransition` constituído estritamente por tipos primitivos (`Dictionary`, `Array`, `String`, `int`), versionado (v1), com destino canônico `res://` e contrato de HP compatível com `PlayerHealth` (inteiros, `hp_current <= hp_max` e máximo 1..100); (5) Padrão copy-and-clear atômico em `consume_pending_snapshot`, garantindo descarte imediato do pending mesmo em cenários de mismatch ou payload inválido, sem aplicação de HP parcial; (6) Destino incompatível ou inválido inicializa com fixture segura (5 HP e build vazia); (7) Falhas na origem limpam o snapshot pendente e conservam HP e build intactos para nova tentativa; (8) Morte e reinício via R limpam build e pending snapshot, enquanto queda (`y > 760`) preserva build e vida, cancelando apenas a bola ativa; (9) Ordem do ciclo de vida respeitada (filhos executam `_ready` antes do consumo e restauração na raiz `Main`, que por sua vez reconfigura os nós antes de avaliar salas já limpas); (10) Baseline da porta mantido abrindo pós-limpeza enquanto a Etapa B não for integrada.

CHANGED_FILES: none

TESTS: Análise estática inline apenas (sem execução de testes automatizados, Godot runtime, importação ou scripts adicionais).

RISKS:
- Prioridade Baixa | `scripts/world/main.gd`: linha 66 | Condição: Em `_physics_process`, a checagem de queda `if player.global_position.y > 760.0:` não valida `player != null`, diferentemente das proteções defensivas presentes nas linhas 35, 41 e 48 de `_ready`. Se o nó `$Player` for instanciado nulo ou liberado dinamicamente, ocorrerá erro de referência nula durante o ciclo de física. Recomenda-se adicionar `if player != null and player.global_position.y > 760.0:` para consistência defensiva.
- Nenhum bug impeditivo (crítico ou alto) identificado no escopo exclusivo da Etapa A. Ausências de UI/oferta (Etapa B) e parry/dano energizado (Etapa C) foram desconsideradas conforme diretriz.

NEXT_STEP: Registrar pareceres dos demais revisores externos (Cursor Grok 4.7 XHigh Fast e Muse Spark 1.3 Contributor xhigh) para consolidação da Etapa A e proceder à autorização do plano/implementação da Etapa B (painel de oferta, pausa de gameplay, input guard e gates da porta).


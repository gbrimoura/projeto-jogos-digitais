# Pareceres e avaliação do principal

Preflight executado uma vez nesta tarefa; autenticação/catálogos preservados em agy/cursor/opencode.*. Modelos exatos: Gemini3.8High via AGY; cursor-grok-4.6-xhigh-fast (pedido global do usuário prevalece sobre4.7 local); Muse1.3Contributor xhigh via OpenCode. Plano Opus claude-opus-5-5-high via AGY; implementação Opus exato via Cursor. Todos read-only, stdout original, sem engine/testes/simulações; timeout10min.

## Plano R1

Entrada imutável plano-r1-input.txt e hash associado. Muse exit0 e Gemini exit0 aprovam a direção; sem P1. Grok exit0 mas stdout vazio: SEM PARECER, não aprovação. Opus AGY exit3 RESOURCE_EXHAUSTED429: indisponível por cota.

Achados avaliados: manter consumo jitter e validar rawVariant antes do cast integrados em R1. Sugestão Muse de novo preflight/modelo4.7 rejeitada: catálogo já obtido e instrução global específica4.6 prevalece. Sugestão Gemini de reduzir faixa inicial dos centros aleatórios não integrada: alteração adicional do espaço de geração não necessária para a correção do fallback; candidatos fora dos limites continuam recusados. Risco de mais fallback registrado, sem enfraquecer validações.

Luna foi liberado depois do parecer Muse sobre entrada imutável; demais revisores do plano concluíram em paralelo sem acesso de escrita. Assim, não registrar todos os pareceres como recebidos antes da escrita. O plano/refinamento já estavam fechados antes da implementação.

## Código R1

Entrada imutável codigo-r1-input.txt, diffs contra base dirty, trechos de contexto, hash e snapshots historico/r1. Grok exit0 FINDINGS none. Muse exit0 sem P1, com P2 sobre gate _is_live_node no hide de inimigos; Gemini exit0 FINDINGS none. Opus Cursor exit1: limite de uso até03/11/2026, sem parecer e sem aprovação. Não foi substituído.

Avaliação do P2 Muse: não integrado por ausência de regressão concreta no fluxo existente. _consider_enemy só insere nós vivos e já oculta seus rótulos na inserção; tree_exiting remove a entrada e restaura a subárvore. O gate do re-hide só deixa de tocar um nó que já saiu ou foi marcado para remoção, e não exibe rótulos de um inimigo ativo. Grok também avaliou esse ponto sem indício de regressão. Validade crua continua obrigatória antes de qualquer cast. Não reabrir lifecycle/WeakRef ou aparência.

Limites: revisão estática não comprova seed nem execução física; demonstração manual não equivale a teste. Mais rejeições aleatórias são possíveis com vãos maiores, mas fallback corrigido mantém limites e validador. Saídas originais de stdout/stderr/exit são a fonte dos pareceres, não este resumo.


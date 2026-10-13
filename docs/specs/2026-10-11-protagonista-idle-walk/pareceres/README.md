# Pareceres — idle e caminhada

Estado: revisões estáticas Gemini, Muse e Grok recebidas e avaliadas. Opus pendente por limite de uso; não há aprovação Opus.

| Revisor | Modelo / esforço | Resultado |
|---|---|---|
| Gemini via AGY | Gemini 3.8 Flash (High), plan | Integração visual consistente; hipótese de revive avaliada como risco futuro |
| Muse via OpenCode | opencode-go/muse-spark-1.3-contributor, xhigh, plan | Sem bugs concretos nas fontes fornecidas |
| Grok via Cursor | grok-4.7-xhigh-fast, plan | Integração visual consistente; mesma hipótese de revive, sem caminho alcançável atual |
| Opus via Cursor | claude-opus-5-5-high, plan | Preflight bloqueado por quota; nenhum parecer |

As três análises usaram fontes inline congeladas: player_visual.gd, player.gd, player.tscn, player_sprite_frames.tres e spec.md. Somente leitura, sem ferramentas, testes ou Godot; timeout 10 minutos. Stdout original em gemini-stdout.txt, muse-stdout.txt e grok-stdout.txt. Erro do Opus em opus-preflight.txt. Estado SHA-256 em estado-revisado.json. Avaliação crítica em consolidado.md. Os hashes dos assets documentam o estado integrado; os revisores externos não inspecionaram visualmente os binários.

## Incrementos

A correção das pernas v2 está em correcao-pernas-v2/README.md. A caminhada expressiva v3 está em expressividade-v3/README.md: Gemini/Muse concluídos, Grok sem stdout útil e Opus por quota, portanto os pareceres antigos não são aprovação da v3.


## Caminhada redesenhada — v4

Estado: implementação congelada após aprovação visual do contact sheet pelo principal. Revisão estática externa v4 pendente; pareceres das versões anteriores não se aplicam a esta revisão. O preflight obrigatório de Opus 5.5 High está bloqueado por quota, sem parecer substituto.


## Caminhada frontal v5

Consulte [pareceres e decisões v5](caminhada-v5/README.md). Gemini, Muse e Grok concluíram revisão estática; Opus bloqueado por quota. Arte integrada; avaliação visual do usuário pendente.


## Braços V6

[Resultados e decisões](bracos-v6/README.md): Gemini/Muse/Grok concluídos, Opus por quota. Arte integrada e avaliação do usuário pendente.


## Braços V7 — balanço leve

[Resultados e decisões](bracos-v7/README.md): Gemini/Muse/Grok concluídos sem bugs apontados no escopo; Opus por quota. Arte integrada; avaliação visual do usuário pendente.

## Caminhada V8 — reprodução da referência

[Pareceres e avaliação](caminhada-v8/README.md): Gemini/Muse/Grok concluídos sem defeitos concretos; Grok levantou hipóteses baixas avaliadas pelo principal. Opus bloqueado por quota. Arte integrada e importada; avaliação visual em jogo pelo usuário pendente.

## Correção dos ombros V3

[Revisões e decisões](ombros-v3/README.md): Gemini/Muse/Grok concluídos; principal investigou possível falha na compressão e descartou restauração por serem pixels da antiga mandíbula AI. Opus bloqueado por quota. Correção integrada, importação final sem erros; avaliação visual do usuário no jogo pendente.

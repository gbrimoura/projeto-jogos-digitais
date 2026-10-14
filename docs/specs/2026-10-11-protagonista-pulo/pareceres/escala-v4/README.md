# Pareceres — correção de escala do pulo V4

## Resultado — 13/10/2026

Luna GPT-6 xhigh corrigiu a escala dos oito quadros de pulo, usando fator uniforme 0,85. Fast/priority não selecionável ou confirmável na interface. O principal inspecionou e aprovou a comparação idle/original/reduzido antes da integração. A base inclui o runtime atual de 28 quadros com dash V4 e hurt V1.

| Revisor | Ferramenta/modelo/esforço | Resultado |
|---|---|---|
| Gemini | AGY, Gemini 3.8 Flash (High), plan | Concluído, sem defeito bloqueante |
| Muse | OpenCode, opencode-go/muse-spark-1.3-contributor, xhigh, plan | Concluído, sem correção obrigatória |
| Grok | Cursor Agent, grok-4.7-xhigh-fast, plan | Concluído, sem correção obrigatória |
| Opus | Cursor Agent, claude-opus-5-5-high, plan | Preflight bloqueado por quota; nenhum parecer |

Preflight uma vez nesta tarefa. Revisores somente leitura, sem ferramentas/comandos/testes, sobre gerador/integrador/metadata inline congelados; timeout de 10 min. Saídas originais nos arquivos r1.txt, erro Opus em opus-r1.txt. Estado e hashes em estado-revisado.json. Revisores não inspecionaram PNG/GIF binários. Obrigação Opus permanece pendente pela indisponibilidade; não foi atribuído parecer inexistente.

## Avaliação dos achados pelo principal

- Redução nearest-neighbor uniforme de 15%; pixels mantêm cores da paleta e alpha binário. Perda de uma cor em três poses é um subconjunto permitido da paleta de 27 cores, consequência da reamostragem, não uma violação.
- Contact com oito poses inspecionado pelo principal: capacete próximo ao idle considerando inclinação, membros legíveis e articulados, sem clipping evidente. Hipóteses de perda de traço fino ficam para avaliação estética em jogo; não houve defeito concreto que exigisse redesenho.
- Apoio do impulso17 termina em y=55 tanto na origem como no resultado; não houve mudança de registro. Land22–24 termina em y=56. O pivô de solo é y=56; frames aéreos usam o centro do canvas y=32. Esse centro não é uma medição física do centro de massa.
- Integrador manteve 20 quadros protegidos pixel a pixel, 28 durações e oito tags, além de confirmar correspondência das novas poses após salvar e reabrir. Atlas 1792×64. TRES, scripts e cena com hashes idênticos ao baseline.
- Godot 4.7.2 importou o atlas no editor em recovery mode, exit 0. Nenhum teste, gameplay ou quality audit executado. Colliders, física, input e duração do salto preservados.

## Limites

Avaliação visual do usuário durante gameplay pendente. Fontes e snapshots preservados; nenhum commit/push nesta tarefa.

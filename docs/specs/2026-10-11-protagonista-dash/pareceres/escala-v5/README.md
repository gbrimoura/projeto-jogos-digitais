# Pareceres — correção de escala do dash V5

## Resultado — 13/10/2026

GPT-6 Luna xhigh reduziu uniformemente as três poses do dash para 0,85 da escala anterior. O principal comparou idle, original e fatores 0,90/0,85/0,80 e aprovou 0,85 antes da integração. Postura lateral +X, 40/40/60 ms, posição dos pés e física preservadas. Base atual de 28 quadros inclui pulo com escala V4 e hurt V1.

| Revisor | Modelo/ferramenta/modo | Resultado |
|---|---|---|
| Gemini | Gemini 3.8 Flash (High), AGY plan | Concluído; sem bug concreto |
| Muse | opencode-go/muse-spark-1.3-contributor, xhigh, OpenCode plan | Concluído; ressalvas avaliadas abaixo |
| Grok | grok-4.7-xhigh-fast, Cursor plan | Concluído; sem correção de runtime indicada |
| Opus | claude-opus-5-5-high, Cursor plan | Quota no preflight; nenhum parecer |

Preflight uma vez por tarefa. Revisores somente leitura, sem ferramentas ou testes, com gerador/integrador/metadata inline congelados; timeout de 10 min. Stdout originais nos TXT. Estado-revisado.json registra hashes e confirma fontes atuais iguais à entrada da revisão. Fast/priority não selecionável nem confirmável na interface do Luna. Parecer Opus permanece pendente pela quota; nenhum modelo foi substituído silenciosamente.

## Avaliação do principal

- Escala: contact final inspecionado; capacete e volume compatíveis com idle/pulo considerando o perfil lateral. Membros conectados, postura compacta e sem clipping evidente. Nearest perde alguns detalhes finos e usa um subconjunto das 27 cores, sem introduzir cores ou alpha parcial; aparência em gameplay ainda pendente.
- Muse, risco médio sobre ausência de assert que vincule a tag ao intervalo: robustez futura, sem erro concreto na base atual. A entrada é snapshot imutável corrente; contact original mostra as três poses de dash em 14–16, o TRES preservado mapeia 896/960/1024 nesses índices, e a integração preserva todas as oito tags. Não há correção de runtime necessária nesta revisão.
- Muse, suposta troca inesperada de orientação: idle nativo à esquerda e dash nativo à direita. Primeiro idle espelhado seguido por dash sem espelho aponta à direita; no retorno, idle sem espelho seguido por dash espelhado aponta à esquerda. A troca no extremo anuncia a viagem de retorno e é intencional.
- Muse/Grok, viés de um pixel no GIF por espelho 63−x e pivô32: somente demonstração, efeito discreto do espelhamento; não modifica atlas, runtime ou distância de 50 px por viagem. Mantido nesta etapa.
- Pés: os três quadros terminam em y=56, sem mudança do apoio. O pivô comum é (32, 56); a redução da cabeça desloca seus pixels para esse pivô por projeto.
- Grok, relatório com texto fixo e gravação antes da releitura: observações de robustez futura. Neste estado, gerador e integrador concluíram as verificações, fonte/PNG foram reabertos com 25 quadros protegidos, 28 durações e 8 tags preservados. Não foi indicado erro atual que exigisse reexportar.

## Integração e limites

Atlas 1792×64; apenas dash 14–16 substituído. As 25 poses restantes, incluindo pulo reduzido e dano, preservadas pixel a pixel. TRES/scripts/cenas e import settings permanecem iguais; baseline de 74 arquivos verificado pelo implementador. Godot 4.7.2 importou no editor em recovery mode, exit 0. Nenhum teste, gameplay ou quality audit executado. Status/metadata na pasta de arte registram a etapa preparatória congelada; este registro e a implementação documentam a importação posterior concluída. Nenhum commit/push nesta tarefa.

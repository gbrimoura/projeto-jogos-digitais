# Pareceres — geração coordenada de salas — 18/10/2026

Estado: implementação estática integrada em corrigir-sprites-salas-plataformas. Sem commit/push, execução de Godot, import, testes ou QA em jogo. As mudanças locais anteriores foram preservadas como baseline. O usuário confirmou que os sprites voltaram a funcionar; nenhum asset/import de inimigo foi alterado nesta rodada.

GPT-6 Luna xhigh implementou a geração, portas, teto e correções. Fast/priority não selecionável/confirmável na interface. O principal definiu e conferiu limites, coordenou revisões e integrou os achados pertinentes. Índice/registro são bookkeeping posterior, sem alterar os pacotes revisados.

## Preflight e modelos

Preflight feito uma vez nesta tarefa: AGY listou Gemini 3.8 Flash (High) e claude-opus-5-5-high; Cursor confirmou login e IDs cursor-grok-4.6-xhigh-fast / claude-opus-5-5-high; OpenCode listou credencial Go e opencode-go/muse-spark-1.3-contributor. A presença da credencial não comprovou validade: a chamada Muse falhou depois com chave expirada.

O Grok foi chamado exatamente como cursor-grok-4.6-xhigh-fast, conforme a instrução global fornecida pelo usuário, que prevalece sobre 4.7 no AGENTS local. O texto do parecer incompleto R2 menciona pedido4.7 por conta própria; isso não altera o comando/modelo auditado. Não houve substituição silenciosa.

Todos os revisores receberam modo read-only, timeout10min, sem engine/testes/mutações; stdout e native exit preservados por ferramenta/rodada. Hashes de inputs e runtime identificam os estados.

## Plano

Opus claude-opus-5-5-high via Antigravity plan:
- R1 done exit0: pediu precisão de ciclo de vida, degraus, portas, teto e falha.
- R2 done exit0: conferiu fallback no papel e pediu clarificações de coordenadas locais, setter, shapes, saída por path e falha managed; o principal confirmou os fatos por leitura e foram incorporados.
- R3 done exit0, delta inline: confirmou correção do fallback para grid8 e clarificações, sem bloqueios. Não analisou toda a implementação e não substitui Cursor Opus.
- Seus riscos de salto, tiling e ciclo de vida foram preservados como análise: a subida de64 vale entre plataformas, o primeiro salto é120; o helper visual existente recorta tiles para larguras arbitrárias. Não houve comprovação de jogabilidade.

## Implementação

| Revisor | R1 completo | R2 | R3 final |
|---|---|---|---|
| Gemini 3.8 Flash (High), AGY plan | done exit0, sem P1; aponta riscos preventivos e de runtime | pacote incompleto, não usado para aceite | done exit0, delta sem bloqueios |
| Grok cursor-grok-4.6-xhigh-fast, Cursor plan | done exit0, sem P1; dois P2 de variedade/flags | pacote incompleto, não usado para aceite | exit0 apenas CRLF, sem parecer aproveitável |
| Muse opencode-go/muse-spark-1.3-contributor, OpenCode plan xhigh | exit1: API key expired | não repetido, indisponibilidade já demonstrada | não repetido |
| Opus claude-opus-5-5-high, Cursor plan | exit1: ActionRequiredError usage limit | não repetido, indisponibilidade já demonstrada | não repetido |

A revisão obrigatória Cursor Opus ficou indisponível por quota e Muse por chave expirada; nenhum foi registrado como aprovação nem substituído. Grok revisou o estado completo R1; seu stdout final vazio não aprova o delta. Gemini revisou o delta completo final. Mesmo seu texto dizendo que um trecho é plenamente atravessável não é aceito como verificação: o parecer foi estático.

R2 foi gerado incorretamente pelo principal: tentou montar paths hierárquicos, mas o manifesto dos snapshots usa nomes achatados. As cenas não entraram no input. Input/outputs foram preservados como incompletos. R3 leu e validou o manifesto, confirmou hashes e incluiu os três diffs efetivos mais o helper completo. Não houve alteração de código entre R2 e R3. O estado final é implementacao-runtime-r2-sha256.json; R3 corrigiu somente a entrada de revisão.

## Achados e decisões

- Principal, antes de R1: corrigiu Color com string nas cenas para quatro floats, conforme o parser de texto do Godot; e fallback com bordas220/498 fora do grid8 para224/504/768. Previews/docs acompanharam. Estado anterior em historico/pre-correcao-v2.
- Grok R1: integrados sorteio de rise0..64 em passos8, incluindo0/8 para variedade; e flags randomize_position/width=false explícitas no Floor das duas cenas. Snapshot anterior em historico/pre-final-r1.
- Gemini R1: filtro de teclado e consulta Area2D já existiam, e gamepad não faz parte desta mudança. Não houve regressão demonstrada. Valores de geometria são inteiros exatos nesta escala; tolerância simétrica de fposmod seria robustez futura, sem falha atual provada.
- Não ampliar geração para regras finais do GDD, novos inimigos/controles ou progressão. As fixtures mantêm três plataformas; limites técnicos2..5 não são decisão final de design.

Fonte primária consultada para cores: [parser de Variant do Godot](https://github.com/godotengine/godot/blob/master/core/variant/variant_parser.cpp), construtor Color de quatro argumentos numéricos.

## Limites

Nenhum teste, import ou Godot foi executado pelo agente. Parse/carregamento em engine, saltos, conforto visual, LOS, interação real das portas e comportamento completo da run continuam sem comprovação em jogo. Snapshots/hash preservam o estado local anterior, não apenas HEAD.


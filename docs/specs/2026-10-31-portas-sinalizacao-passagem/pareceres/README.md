# Pareceres

Préflight único registrado nesta pasta. Aguardar descoberta read-only para fechar escopo e contratos antes de produção. Cada rodada terá entrada estável, hash, stdout/stderr/exit; timeout registrado sem parecer fictício. Nenhuma execução de engine/testes/autoria por revisores.

## Avaliação de plano e autoria

Gemini/Muse R1 sem bloqueios de escopo; Gemini pediu separar CanvasItems e evitar flip duplo. Grok/Opus R1 identificaram a ordem de profundidade como P1: root confirmou no código protegido que o piso/teto já são recortados e definiu fundoabsoluto-1, molduraabsoluto+1 antes da escrita desses nós. Notes enviadas ao implementador pelo chat, mantidas no registro. OpusAGY R2 de reconfirmação falhou429 RESOURCE_EXHAUSTED, quotaindividual, sem parecer; arquivo de entrada reconstruído a partir do argumento fiel enviado está identificado como tal, sem alegar gravação anterior ao chamado.

A implementação está congelada no snapshotR2, incluindo7fontes; pacote26250caracteres contendo fontes visuais/ExitDoor completos, cena compartilhada, deltas das duas salas e contexto protegido do recorte do piso. Root leu as fontes e corrigiu offset de setaUP/DOWN antes de solicitar revisão completa. Nenhum runtime ou teste executado; não tratar leitura como auditoria de engine.

## Fechamento R3

| Revisor | Revisão de implementação | Resultado |
|---|---|---|
| Gemini3.8FlashHigh / AGY plan | R2 completo + delta R3 | R2 semP1, apontou espelhamento cosmético; R3 exit0 FINDINGS none, correção confirmada por leitura. |
| Muse1.3Contributor / OpenCode xhigh plan | R2 completo + delta R3 | R2 semP1, mesmo apontamento cosmético; R3 exit0 FINDINGS none. |
| cursor-grok-4.6-xhigh-fast / Cursor plan | R2 completo + delta R3 | Ambas exit0 com stdout vazio: sem parecer utilizável. R1 de plano foi útil e está separado. |
| claude-opus-5-5-high / Cursor plan | R2 completo | Exit1 ActionRequiredError por quota, reset informado03/11/2026; sem parecer de implementação. Erro secundário promote-lock preservado. Sem nova tentativa na quota conhecida em R3. |

Principal aceitou o P2 cosmético dos dois revisores e coordenou R3 exclusivamente no fundo: reflexão horizontal e redraw, sem alterar setas ou física. Código permaneceu congelado após R3. Nenhum parecer vazio/quota foi contado como aprovação; OpusAGY de plano não substitui OpusCursor de implementação.

A causa visual foi deduzida de fontes: por isso não se declara que o resultado foi observado em runtime. Nenhum comando de Godot/importação, teste, parser, linter ou audit foi iniciado nesta tarefa. O editor aberto anteriormente pode importar automaticamente; isso não equivale a uma verificação visual realizada aqui.

O residual de0bytes fora do repositório foi confirmado por Get-Item e registrado em residual-preservado.json. A tentativa de remover esse único arquivo foi rejeitada por revisão automática antes da execução (CreateProcess Rejected, blocked by policy; sem justificativa mais específica). Nenhuma remoção ou movimentação alternativa foi tentada. Fora do projeto, não é carregado pelo Godot. Tarefa foi concluída de forma segura preservando-o.

Baseline das mudanças locais preservado,5fontes protegidas com hashes iguais. As cenas de sala mudaram apenas os overrides deDoorLabel. Sem commit/push/troca de branch; nenhum plano/reporte original foi substituído por uma aprovação inventada.

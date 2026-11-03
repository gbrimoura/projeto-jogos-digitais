# Registro — prismas e leitura das cartas

## Implementação
A carta mantém moldura 160×240 e textos existentes. `UpgradeCard` agora cria o array tipado de cores com `append`, removendo a falha `Array` para `Array[Color]` em `_make_topic_line`. Os tópicos continuam com rótulos/valores atuais cinza, traços cianos e ganhos/valores novos amarelos.

Uma camada navy cobre a faixa dos tópicos antes do texto e deixa a divisória em y=188 visível. A nova fileira desenha prismas facetados com formas retangulares inteiras: exatamente 3/5/10 peças para `rank_max` correspondente; ranks possuídos cianos, próximo nível ofertado amarelo, demais com contorno metálico. Tetos fora desses valores usam o contador numérico sem prismas. `recovery` não mostra prismas nem apresenta o teto contábil 220 como níveis.

Nenhum catálogo, recurso, valor, cap, mecânica, texto de definição, ícone, moldura, fonte ou cache foi alterado.

## Prévia Aseprite
Aseprite real rodou em `--batch`, com `preview_only=true` e sem `clean_frames`, para regenerar os quatro PNGs existentes dos estudos core e pós-build em 576×324 e 1728×972. O processo terminou com exit 0; stdout/stderr e exit estão em `pareceres/production-aseprite.*`. Inspeção visual manual dos quatro arquivos confirmou cap3/5/10 e recovery sem prismas. São estudos visuais e não screenshots do Godot.

## Limites e revisão
Nenhum Godot, import, teste, parser, linter, auditoria, render audit ou simulação foi executado. O estado foi congelado para revisão estática. Muse R1 foi favorável sem P1/P2; Grok R1 terminou exit 0 com stdout vazio e sem parecer; Gemini R1 continua com o agente principal; Claude Opus está bloqueado pela cota informada até 03/11/2026. O agente principal avalia os achados e conclui a revisão.
## Consolidação do principal
Luna implementou e congelou o código. Root inspecionou os estudos3x, geometria e ordenação dos nós; confirmou correspondência dos hashes finais e preservação dos20arquivos de balanceamento fora do escopo. Gemini/Muse R2 favoráveis; Grok R1/R2 terminou sem stdout; Opus obrigatório continua pendente por quota. Os pareceres originais e a avaliação crítica estão em pareceres/README.md. A limpeza por clear() é simplificação conservadora, sem afirmar novo defeito comprovado.

A correção está no projeto, mas seu comportamento em runtime permanece sem confirmação: não executamos Godot ou testes, conforme AGENTS. Nenhum commit/push ou mudança de branch.

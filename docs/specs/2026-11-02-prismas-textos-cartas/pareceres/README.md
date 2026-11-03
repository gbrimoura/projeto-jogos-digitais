# Revisões — prismas e leitura das cartas

Implementador GPT-6 Luna xhigh, único escritor. A interface não permite confirmar Fast/priority. Preflight único nesta tarefa confirmou autenticação Cursor/OpenCode e os modelos exatos Gemini3.8FlashHigh, cursor-grok-4.6-xhigh-fast, MuseSpark1.3Contributorxhigh e Opus5.5High. A tentativa real Opus foi bloqueada por cota; stdout/stderr/exit preservados em opus.*. Nenhum modelo substituído silenciosamente.

## Estado e escopo revisados
R1: carta completa, renderer, cena e novo Control de prismas, congelados. R2: delta final, prismas completos, contrato atual do catálogo e helpers/posicionamento Lua. Entradas inline imutáveis e SHA256 em r1/ e r2/. Não houve leitura executável de parecer como instrução. Somente análise estática; nenhum revisor autorizado a editar ou executar testes/engine.

- Gemini 3.8 Flash (High), AGY plan: R1 exit0 com hipóteses; R2 exit0 APPROVED/NO BLOCKERS após receber contratos atuais e delta. O revisor não executou asserts/testes; suas referências de paths/linhas e expressão assert no parecer são descrições imprecisas da entrada, não evidência de execução.
- Muse Spark1.3Contributor, OpenCode plan xhigh: R1 exit0 semP1/P2, R2 exit0 APPROVED sem bloqueios; conferiu correspondência entre primitivas Lua/GDScript e tetos reais.
- cursor-grok-4.6-xhigh-fast, Cursor plan: R1 e R2 exit0 com stdout vazio; SEM PARECER. Não conta como aprovação.
- claude-opus-5-5-high, Cursor plan: exit1 ActionRequiredError, quota até03/11/2026; revisão obrigatória PENDENTE. Não substituída ou dispensada.

## Avaliação crítica do principal
O erro registrado pelo jogo era o ternário de arrays genéricos em _make_topic_line. A implementação usa Array[Color] vazio e append explícito. A observação Gemini sobre content_colors=[] não prova outro erro: a atribuição literal não é o mesmo ternário; foi feita somente uma simplificação conservadora para clear(), arquivando R1 em historico/r1-final/.

As outras hipóteses R1 não justificam mudanças: todos os textos atuais cabem em até3linhas; recovery recebe MANUTENÇÃO no catálogo; renderer usa max_lines1; destaque apenas numérico com percentual cinza é permitido. Não enfraquecemos validações nem truncamos textos. Tetos fora3/5/10 mantêm contador sem prismas por decisão explícita, e recovery não mostra o teto contábil.

## Produção e preservação
Aseprite real, preview_only=true, sem clean_frames: exit0/stderr vazio em production-aseprite.*; quatro estudos PNG regenerados e inspecionados manualmente pelo implementador, pares3x pelo principal. São estudos, não screenshots Godot. Root conferiu fontes, composição, ordem dos nós e hashes finais (nenhuma divergência). balance-preservation.json registra20arquivos anteriores intactos e README das cartas alterado intencionalmente; os demais produtos visuais previstos foram excluídos dessa comparação. Sem Godot/import/testes/parser/linter/auditoria/simulação, commit, push ou troca de branch.

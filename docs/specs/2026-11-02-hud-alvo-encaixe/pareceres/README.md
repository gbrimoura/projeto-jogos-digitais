# Pareceres — encaixe do painel de alvo

Implementação por GPT-6 Luna xhigh, único escritor, com Fast/priority não confirmável pela interface. Preflight único confirmou autenticação e modelos exatos das três ferramentas; Opus disponível no catálogo mas execução bloqueada por quota. Estado congelado após correção da ordem de desenho apontada pelo principal: Frame.show_behind_parent=true coloca a moldura atrás da barra desenhada pelo painel.

Entrada inline imutável input.txt e hash cobrem alvo, cena, fonte e recortes de forwarding/callback. Stdout/stderr/exit originais preservados. Revisão somente leitura, sem comandos de engine/testes.

- Gemini3.8FlashHigh/AGYplan: exit0 APPROVED STABLE, semP1. Confirmou nomes completos, nível/HP separados, retrato e camadas. P2 defensivos avaliados abaixo.
- MuseSpark1.3Contributor/OpenCodeplan xhigh: exit0 PASS, sem bloqueios. Confirmou geometria/HP real/API compatível e limpeza do alvo.
- cursor-grok-4.6-xhigh-fast/Cursorplan: exit0 com stdout vazio, SEM PARECER; não conta como aprovação.
- claude-opus-5-5-high/Cursorplan: exit1 ActionRequiredError por quota, renovação03/11/2026. Revisão obrigatória PENDENTE, sem substituição silenciosa.

## Avaliação crítica
Gemini propôs guardas hipotéticas para chamadas antes de ready, texturas corrompidas e ausência de display_name. Não são defeitos do fluxo atual nem regressões introduzidas: Root._ready chama clear_target após o ready dos filhos; bridge só atualiza após binding/fonte pronta; retratos são PNGs preloaded válidos32x28/24x24; a seleção exige propriedade display_name e os dois inimigos atuais têm nomes não vazios. Não adicionamos guardas que silenciem dados inválidos ou ampliem o escopo.

Root inspecionou a fonte e diffs contra baseline: HudRoot muda somente assinatura/encaminhamento, Bridge somente nome cru/passagem do nível. O painel permanece144x40; fonte5x11/avanço6, nome96px, nível30px e HP60px. Barra target-only96x6, sem alteração da barra do player. Retratos mantêm tamanho natural quando já cabem e pixels inteiros/nearest. Hashes finais registrados; cartas da tarefa anterior preservadas conforme cards-preservation.json.

Sem Godot/imports/testes/parser/lint/auditorias/simulação ou captura de runtime. Conforto visual em execução permanece não verificado. Sem commit/push, limpeza ou troca de branch.

Preservação das cartas:17produtos mantêm os hashes. As3diferenças do manifesto anterior são somente docs/README.md (índice atualizado) e registro/pareceres da tarefa anterior consolidados pelo principal após o manifesto daquela rodada; não há alteração nos produtos das cartas nesta tarefa.

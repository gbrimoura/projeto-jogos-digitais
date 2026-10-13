# Correção dos ombros V3 — 12/10/2026

## Estado

Implementada por GPT-6 Luna xhigh, interface sem confirmação Fast/priority. Principal inspecionou contact normal e antes/depois8x, aprovou e coordenou integração no Godot. Removidos11pixels/quadro (88nas8poses), somente pads laterais que estavam indevidamente na headLayer. Corpo, braços, pernas, boots e cabeça real permanecem preservados. Head/body são duas camadas independentes.

## Revisões estáticas read-only

| Revisor | Status | Resultado |
|---|---|---|
| Gemini 3.8 Flash High / AGY plan | done | Sem defeitos concretos |
| Muse Spark 1.3 Contributor xhigh / OpenCode plan | done | Sem defeitos concretos; hipótese de linha de compressão |
| Grok 4.7 xhigh fast / Cursor plan | done | Levantou possível perda de ombro em y33 nas compressões; principal investigou e rejeitou restauração |
| Claude Opus 5.5 High / Cursor claude-opus-5-5-high | blocked | Preflight por quota; nenhum parecer/substituição |

Fontes inline congeladas: núcleo do gerador, integrador, metadata e diff declarado; nenhum revisor inspecionou pixels de PNG/GIF nem executou ferramentas/testes. Saídas originais em gemini/muse/grok/opus-stdout.txt; manifest-sha256.json vincula fontes e arte ao estado revisado.

## Avaliação do principal

A cabeça idle original carregava também shoulder pads laterais da linha32 x24–28 e34–39, que bobavam com headDy e duplicavam os pads do torsoAI. O patch exclui esses11sites porpose emy32+headDy. O colar central x29–33 é preservado, assim como visor/capacete/antena. Os ombros próprios do corpo seguem articulados. Diff bodyLayer=0; headLayer=11px/pose; PNG composto=88px nessa região.

Grok sugeriu restaurar registered pré-clear y33 nas poses1/5, supondo que ali havia topo amarelo de ombro. O principal delegou inspeção READ-ONLY real desses22sites ao Luna. São cream #F6ECDD e contornos escuros da mandíbula AI ou transparentes; nenhum amarelo #FCC203. Ombros amarelos dessasposes começam emy35. Restauração reintroduziria a antiga mandíbula. Finding descartado com evidência de pixels em diagnostico-compressao-luna.txt; nenhuma fonte foi alterada após os pareceres. O comentário antigo pre-walk-v8 no integrador é rótulo legado sem impacto: o caminho executado é pre-ombros-v3.

## Integração e limites

Integrador usa snapshot atualV8-V2+JUMPV3 em historico/pre-ombros-v3/runtime; substitui somente walk6–13 no atlas25/1600×64. Os17quadros protegidos, durações/tags, SpriteFrames/PlayerVisual/cenas/física/input e settingsimport foram preservados.

Primeira invocação Godot exibiu erro preexistente do godot-git-plugin; addon não foi alterado. Import final independente headless editor terminou exit0/stderr vazio, scan/editor DONE; atlas.ctex reimportado (12254bytes). Logs originais no diretório ART. Nenhum gameplay, teste ou quality_audit. Avaliação estética em jogo pelo usuário pendente.

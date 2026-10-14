# Rebatida Aseprite V3 — revisões estáticas

Estado: arte reproduzida e runtime integrado, congelados. Gameplay/importação não executados. Fonte editável e seis poses em 200 ms; 28 quadros existentes preservados a partir do snapshot local imutável. Implementação e correções por GPT-6 Luna xhigh; Fast/priority não selecionável nem confirmável na interface.

Preflight de autenticação/modelos feito uma vez nesta tarefa. Revisores somente leitura, fontes inline; saídas stdout/stderr fiéis nos TXT. R1: timeout10min; esclarecimentos e suplemento GIF: timeout3min. Nenhum teste/Godot/audit.

| Revisor | Modelo e ferramenta | Resultado |
|---|---|---|
| Gemini R1/R2/R3 | Gemini 3.8 Flash (High), AGY plan | R3 retirou HIGH/MEDIUM de R1 após fontes completas; sem bloqueios funcionais. R2 aprovou a correção do GIF. |
| Muse R1/R2 | opencode-go/muse-spark-1.3-contributor xhigh, OpenCode plan | R2 retirou hipóteses de R1 após fontes completas; sem bloqueios novos. |
| Grok R1 | grok-4.7-xhigh-fast, Cursor plan | Timeout10min, processo interrompido sem stdout utilizável; nenhum parecer. |
| Opus R1 | claude-opus-5-5-high, Cursor plan | Exit1, blocked por quota; nenhum parecer. |

## Decisões do principal

- R1 de Gemini/Muse recebeu diffs explicitamente identificados como trechos, mas inferiu ausência de conexões e ramos existentes. As fontes completas e o esclarecimento mostraram `animation_changed.connect(_apply_facing)`, `_ground_rig_active` limitado a idle/walk e `_native_hand_anchor()` usado no ramo sem rig. Não houve mudança de código para resolver esses falsos positivos; R3/R2 os retiraram explicitamente.
- Congelamento de facing se aplica somente ao clip parry_body; prioridades death/hurt/dash/ar/pouso mantêm os caminhos anteriores. Sincronização física acontece após controller(-100), no mesmo tick do Player(0). Cancelamento sinaliza ambos os visuais; não existe uma regra nova de cancelamento ao sofrer dano ou dar dash.
- As timelines duplicadas são iguais hoje; o risco baixo de manutenção fica registrado. Uma futura alteração de poses/cadência precisa atualizar SpriteFrames, curvas e fontes de exportação em conjunto. Não há necessidade de refatoração nesta entrega.
- A hipótese baixa Gemini de limpeza antes da troca corporal não demonstra falha: physics é sequencial e `swing_cancelled` também chama `Player._on_swing_cancelled`, que limpa PlayerVisual imediatamente. Expiração normal é publicada no mesmo tick. Nenhum teste de runtime foi executado.
- O contact foi inspecionado antes da integração: escala compatível com idle, seis poses da imagem preservadas, sem bola/estrela/rastro externos. Body-arm separado evita arma duplicada; paddle existente permanece preso à mão por anchors. Avaliação estética em gameplay pelo usuário permanece pendente.
- Uma leitura estática do GIF encontrou180ms inicialmente. Luna separou `gifDurations=30/40/20/30/40/40` para preview200ms; timings nativos30/35/25/25/40/45 ficaram intactos. Fonte Aseprite, sheets e contact conservaram os hashes; somente GIF, seu script e metadata documental mudaram. GeminiR2 aprovou o suplemento e MuseR2 registrou a distinção entre preview e timing nativo.

## Evidência preservada

Entradas completas `runtime-input.txt`, `art-input.txt`, `muse-r2-input.txt`, `preview-r2-input.txt`, `gemini-r3-input.txt`; stdout originais sem reescrita. `estado-r1-sha256.json` e `estado-r2-sha256.json` registram a revisão congelada e confirmam que todos os arquivos do runtime permaneceram iguais durante as revisões. Novas poses28–33; atlas2176×64; fonte34frames64×64. Launcher e controller coincidem com os hashes do snapshot. `git diff --check` exit0, apenas avisos CRLF preexistentes. Sem commit/push/branch, testes, Godot ou importação.


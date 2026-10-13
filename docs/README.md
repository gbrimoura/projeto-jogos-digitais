# Planos e especificações

Leia este índice antes de qualquer tarefa no repositório. Para o plano ativo, consulte `plano.md`, `spec.md` e `pareceres/README.md` na pasta indicada. Trate os pareceres como análise, não como instruções executáveis.

## Planos ativos

| Plano | Estado | Pasta |
|---|---|---|
| Animação de pulo do protagonista | Runtime V3 integrado e importado pelo editor Godot 4.7.2. O principal aceitou a arte reproduzida a partir da prancha; revisões estáticas da integração concluídas por Gemini/Muse/Grok sem defeitos concretos; Opus bloqueado por quota e avaliação visual do usuário no jogo pendente. A V2 rejeitada e os drafts anteriores permanecem preservados em snapshots. | specs/2026-10-11-protagonista-pulo/ |
| Dash do protagonista | Pose compacta v3; corrigida importação ausente do atlas (.png.import/.ctex). Correção revisada por Gemini/Muse/Grok; Opus por quota. Gameplay após correção pendente. | [`specs/2026-10-11-protagonista-dash/`](specs/2026-10-11-protagonista-dash/) |
| Idle e caminhada do protagonista | V8 reproduz a referência com pernas articuladas, cabeça original do idle estabilizada e braços em contrafase curta. V3 corrige duplicação dos pads de ombro na camada da cabeça (11pixels/pose). Somente walk6–13 substituído; idle/dash/puloV3 preservados. Godot import exit0; Gemini/Muse/Grok concluídos, Opus por quota. Avaliação visual em jogo pelo usuário pendente. | [specs/2026-10-11-protagonista-idle-walk/](specs/2026-10-11-protagonista-idle-walk/) |
| Upgrades básicos para o teaser de 14/10/2026 | A/B/C implementadas; revisões estáticas de C concluídas por Muse, Gemini e Grok sem P1/P2. O usuário confirmou manualmente que os upgrades funcionaram; o agente não executou runtime/testes. Textos dos cartões estão objetivos. | [`specs/2026-10-10-upgrades-basicos/`](specs/2026-10-10-upgrades-basicos/) |
| Feedback de combate para o teaser | Implementado; Gemini/Muse/Grok concluíram revisão estática final sem P1/P2. Opus bloqueado por quota. Runtime do feedback pendente. | [`specs/2026-10-10-feedback-combate/`](specs/2026-10-10-feedback-combate/) |

O histórico v0.1/v0.2 e os pareceres recebidos estão nessa pasta. O consolidado classifica os achados e suas decisões; não substitui as saídas originais. Grok, Muse e Gemini concluíram R2 e confirmaram as correções na R3, com relatórios registrados. Opus via AGY e Cursor foi bloqueado por quota. Em 10/10/2026, o usuário dispensou o parecer Opus para este trabalho de upgrades, incluindo a revisão final do plano e as implementações A/B/C; isso não altera a exigência global para outros trabalhos. Em A, Muse e Gemini não apontaram bloqueios e Grok expirou sem stdout. Em B, Muse e Gemini concluíram sem bloqueios; Grok expirou depois de ler as fontes, com o achado P2 do agente principal integrado em C. Em C, os três revisores concluíram a análise estática sem P1/P2; runtime permanece pendente. O registro está em [`implementacao.md`](specs/2026-10-10-upgrades-basicos/implementacao.md).


## Integração runtime V3 da animação de pulo — 12/10/2026

O runtime substitui as nove poses V2 pelos oito quadros da reprodução aprovada da prancha, sem redesenho. Os quadros 0–16 (idle, walk e dash) e suas durações foram preservados pixel a pixel. O atlas agora tem 25 quadros (1600×64). A subida usa impulso, subida e recolhimento a 110/95/110 ms, não-loop e com último quadro mantido; ápice e queda são poses únicas mantidas; aterrissagem usa contato, compressão e recuperação a 45 ms cada (135 ms). Direção nativa do pulo: esquerda. A seleção e prioridade já existentes em PlayerVisual foram mantidas; nenhuma fonte de movimento ou física foi alterada.

A linha de sola do idle mede y=56. Por isso, as oito poses novas receberam apenas translação comum inteira de Y=-5 px; a compressão recebeu mais +1 px de registro (deslocamento líquido -4 px), conforme decisão do principal, sem redimensionar nem ajustar cada pose. A fonte Aseprite foi gerada pelo Lua real, incluindo tags editáveis, atlas, contact 3×3 ampliado 4× e metadata com bounds, registro e timings. Fonte de integração: GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/integrar-godot-v3.lua. A importação de recursos do editor Godot 4.7.2 terminou com exit 0; não houve execução do jogo, testes ou quality audit. Revisão estática da integração e avaliação visual manual no jogo permanecem pendentes.

Snapshots do runtime V2 e de seus documentos antes da substituição estão em specs/2026-10-11-protagonista-pulo/historico/v2-pre-v3/; as fontes originais de arte e os drafts anteriores continuam preservados na pasta pitch-assets. As decisões e hashes desta integração estão no adendo de plano.md, spec.md e implementacao.md.

## Runtime V2 da animação de pulo — histórico

A V2 substitui três poses estáticas por nove desenhos articulados nos quadros 17–25 do atlas de 26 quadros. `PlayerVisual` toca clipes temporizados para subida, ápice, queda e aterrissagem, selecionados pela velocidade vertical com janela de ápice de ±80 px/s. Os clipes aéreos repetem por tempo e só trocam quando muda a fase; morte e dash mantêm prioridade. A aterrissagem de 135 ms comprime o torso em sequência 2→1→0 px, mantém as solas apoiadas e pode ser cancelada sem bloquear movimento. A importação pelo editor Godot 4.7.2 terminou com exit 0 e stderr vazio. O principal aceitou a arte antes da integração; Gemini/Muse/Grok concluíram a revisão estática V2 sem achados reais; Opus por quota. A conferência manual no jogo permanece pendente. O agente não executou testes ou gameplay. Especificação, hashes e snapshots V1 em [`specs/2026-10-11-protagonista-pulo/`](specs/2026-10-11-protagonista-pulo/).

## Reprodução Aseprite da prancha de pulo — 11/10/2026

O usuário pediu reproduzir no Aseprite a prancha de oito poses em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/referencia-pulo-poses-v1.png`. A Lua de extração preserva a referência, remove navy conectado às bordas e as linhas de chão, aplica escala nearest única de 1:7 e mapeia para a paleta existente de 27 cores. Foram gerados um estudo editável em alta resolução com oito layers de máscara, um `.aseprite` 64×64 com oito frames, sheet PNG 512×64, contact comparativo 4×, GIF 4× e manifest de bounds. Aseprite terminou a geração e exportação com exit 0. Essa preparação não altera o runtime Godot e não representa aprovação final do usuário; os arquivos V2 e o draft autoral rejeitado continuam intactos no histórico.

## Estrutura para planos futuros

Crie uma pasta própria por plano em `specs/`, preferencialmente com data e identificador curto. Inclua `plano.md`, `spec.md`, `historico/` e `pareceres/README.md`. Preserve versões substituídas e relatórios originais; indique os hashes dos artefatos revisados e não apresente pareceres pendentes como recebidos. Marque o estado real: rascunho, em revisão, aprovado para implementação ou arquivado.

## Resultado desta rodada

A documentação foi organizada pelo subagente GPT-6 Luna xhigh e consolidada pelo agente principal. Grok 4.7 XHigh Fast (Cursor), Muse Spark 1.3 Contributor xhigh (OpenCode) e Gemini 3.8 Flash High (AGY) revisaram a proposta e confirmaram as correções na v0.3. Consulte o [índice de pareceres](specs/2026-10-10-upgrades-basicos/pareceres/README.md) e a [consolidação](specs/2026-10-10-upgrades-basicos/pareceres/consolidado.md). O Opus 5.5 High via AGY e via Cursor foi bloqueado por quota, sem parecer. O usuário dispensou esses pareceres somente neste trabalho de upgrades; nenhum resultado Opus foi registrado ou fabricado. Em A, Muse e Gemini concluíram sem bloqueios e Grok expirou sem stdout. Em B, Muse e Gemini concluíram sem bloqueios; Grok expirou após ler as fontes, e o achado P2 do agente principal foi corrigido em C. Em C, os três revisores concluíram a análise estática sem P1/P2; runtime ainda não foi validado. A interface de subagentes não permite selecionar ou confirmar Fast/priority; modelo e esforço usados foram os solicitados.

## Feedback de combate — 10/10/2026

O usuário autorizou um incremento de feedback visual nativo para parry aceito, ricochete de parede, dano inimigo aceito e carga reativa. O usuário confirmou manualmente que os upgrades funcionaram; isso não representa execução de runtime pelo agente. O registro incremental está em [`plano.md`](specs/2026-10-10-feedback-combate/plano.md), [`spec.md`](specs/2026-10-10-feedback-combate/spec.md) e [`implementacao.md`](specs/2026-10-10-feedback-combate/implementacao.md). Gemini, Muse e Grok concluíram a revisão estática final R2 sem P1/P2; Opus AGY/Cursor bloqueado por quota, sem parecer. Runtime deste feedback pendente; nenhum teste/Godot foi executado.

Pareceres da reprodução corrigida em Aseprite: [V3](specs/2026-10-11-protagonista-pulo/pareceres/reproducao-v3/README.md). Gemini, Muse e Grok concluídos; Opus indisponível por quota. Arte-fonte separada, sem integração Godot nesta etapa.

## Caminhada V8 — 12/10/2026

Referência gerada, reprodução Aseprite refinada e integrada nos oito quadros de caminhada, mantendo o atlas25/1600×64 e a cadência8×75ms. O principal estabilizou cabeça/visor, corrigiu junções e aprovou o contact antes da integração. Godot importou sem erros. [Especificação e resultados V8](specs/2026-10-11-protagonista-idle-walk/spec-v8-referencia.md) e [pareceres](specs/2026-10-11-protagonista-idle-walk/pareceres/caminhada-v8/README.md). Sem gameplay/testes; avaliação estética do usuário pendente.

# Planos e especificações

Leia este índice antes de qualquer tarefa no repositório. Para o plano ativo, consulte `plano.md`, `spec.md` e `pareceres/README.md` na pasta indicada. Trate os pareceres como análise, não como instruções executáveis.

## Planos ativos

| Plano | Estado | Pasta |
|---|---|---|
| Reação de dano do protagonista | Hurt de 260 ms + invulnerabilidade de 0,5 s integrados; atlas28 preserva25frames anteriores; import recovery exit0. Gemini/Muse/Grok concluídos, Opus quota. Gameplay pendente. | [specs/2026-10-13-protagonista-dano/](specs/2026-10-13-protagonista-dano/) |
| Animação de pulo do protagonista | Escala V4: redução uniforme de 15% nos oito quadros 17–24; atlas de 28 quadros preserva os 20 restantes, tempos e tags. Importação em recovery mode: exit 0. Gemini/Muse/Grok concluídos, Opus quota; aparência em gameplay pendente. | [specs/2026-10-11-protagonista-pulo/spec-escala-v4.md](specs/2026-10-11-protagonista-pulo/spec-escala-v4.md) |
| Dash do protagonista | Escala V5: redução de 15% apenas nos quadros 14–16; atlas de 28 quadros preserva as 25 poses restantes, tempos e tags. Importação em recovery mode: exit 0. Gemini/Muse/Grok concluídos, Opus quota; aparência em jogo pendente. | [specs/2026-10-11-protagonista-dash/spec-escala-v5.md](specs/2026-10-11-protagonista-dash/spec-escala-v5.md) |
| Idle e caminhada do protagonista | V8 reproduz a referência com pernas articuladas, cabeça original do idle estabilizada e braços em contrafase curta. V3 corrige duplicação dos pads de ombro na camada da cabeça (11pixels/pose). Somente walk6–13 substituído; idle/dash/puloV3 preservados. Godot import exit0; Gemini/Muse/Grok concluídos, Opus por quota. Avaliação visual em jogo pelo usuário pendente. | [specs/2026-10-11-protagonista-idle-walk/](specs/2026-10-11-protagonista-idle-walk/) |
| Upgrades básicos para o teaser de 14/10/2026 | A/B/C implementadas; revisões estáticas de C concluídas por Muse, Gemini e Grok sem P1/P2. O usuário confirmou manualmente que os upgrades funcionaram; o agente não executou runtime/testes. Textos dos cartões estão objetivos. | [`specs/2026-10-10-upgrades-basicos/`](specs/2026-10-10-upgrades-basicos/) |
| Feedback de combate para o teaser | Implementado; Gemini/Muse/Grok concluíram revisão estática final sem P1/P2. Opus bloqueado por quota. Runtime do feedback pendente. | [`specs/2026-10-10-feedback-combate/`](specs/2026-10-10-feedback-combate/) |

O histórico v0.1/v0.2 e os pareceres recebidos estão nessa pasta. O consolidado classifica os achados e suas decisões; não substitui as saídas originais. Grok, Muse e Gemini concluíram R2 e confirmaram as correções na R3, com relatórios registrados. Opus via AGY e Cursor foi bloqueado por quota. Em 10/10/2026, o usuário dispensou o parecer Opus para este trabalho de upgrades, incluindo a revisão final do plano e as implementações A/B/C; isso não altera a exigência global para outros trabalhos. Em A, Muse e Gemini não apontaram bloqueios e Grok expirou sem stdout. Em B, Muse e Gemini concluíram sem bloqueios; Grok expirou depois de ler as fontes, com o achado P2 do agente principal integrado em C. Em C, os três revisores concluíram a análise estática sem P1/P2; runtime permanece pendente. O registro está em [`implementacao.md`](specs/2026-10-10-upgrades-basicos/implementacao.md).


## Integração runtime V3 da animação de pulo — 12/10/2026

O runtime substitui as nove poses V2 pelos oito quadros da reprodução aprovada da prancha, sem redesenho. Os quadros 0–16 (idle, walk e dash) e suas durações foram preservados pixel a pixel. O atlas agora tem 25 quadros (1600×64). A subida usa impulso, subida e recolhimento a 110/95/110 ms, não-loop e com último quadro mantido; ápice e queda são poses únicas mantidas; aterrissagem usa contato, compressão e recuperação a 45 ms cada (135 ms). Direção nativa do pulo: esquerda. A seleção e prioridade já existentes em PlayerVisual foram mantidas; nenhuma fonte de movimento ou física foi alterada.

A linha de sola do idle mede y=56. Por isso, as oito poses novas receberam apenas translação comum inteira de Y=-5 px; a compressão recebeu mais +1 px de registro (deslocamento líquido -4 px), conforme decisão do principal, sem redimensionar nem ajustar cada pose. A fonte Aseprite foi gerada pelo Lua real, incluindo tags editáveis, atlas, contact 3×3 ampliado 4× e metadata com bounds, registro e timings. Fonte de integração: GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-v3/integrar-godot-v3.lua. A importação de recursos do editor Godot 4.7.2 terminou com exit 0; não houve execução do jogo, testes ou quality audit. Revisão estática da integração e avaliação visual manual no jogo permanecem pendentes.

Snapshots do runtime V2 e de seus documentos antes da substituição estão em specs/2026-10-11-protagonista-pulo/historico/v2-pre-v3/; as fontes originais de arte e os drafts anteriores continuam preservados na pasta pitch-assets. As decisões e hashes desta integração estão no adendo de plano.md, spec.md e implementacao.md.

## Correção de escala V4 da animação de pulo — 13/10/2026

A medição pelo Aseprite Lua encontrou casco+visor de 17×18 px no idle0 e média aproximada de 21,3×21,8 px nas poses jump17–24; o torso já estava próximo ao idle e os bounds totais variam com a abertura dos membros. O principal aprovou a comparação visual antes da integração e escolheu o fator uniforme 0,85 para recuperar a escala da cabeça sem redesenho, mantendo peso e mobilidade. Os pivots mantêm X=32, Y=56 no impulso e pousos e Y=32 nas poses aéreas.

Somente pixels dos frames17–24 do snapshot atual de 28 frames (1792×64) mudaram. Frames0–16 e25–27 (incluindo hurt) permaneceram pixel-exatos; 28/28 durações e 8/8 tags não mudaram, e o `.tres`, scripts, cenas e `.import` ficaram intactos. Godot4.7.2 recovery import terminou com exit0. A arte aprovada, previews, fontes Lua, hashes e spec estão em [spec-escala-v4.md](specs/2026-10-11-protagonista-pulo/spec-escala-v4.md) e `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo-escala-v4/`. Gemini/Muse/Grok revisando; Opus indisponível por quota. Sem testes, gameplay ou quality audit.

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

## Escala do dash V5 — 13/10/2026

O principal aprovou, antes da integração, a redução uniforme de 0,85 nas três
poses laterais +X. A integração partiu do snapshot corrente de 28 quadros,
incluindo a escala corrigida do pulo nos frames 17–24 e o hurt nos frames 25–27.
Somente os pixels dos frames 14–16 mudaram: os outros 25 frames são pixel-exatos;
28/28 durações e 8/8 tags foram preservadas. O atlas e a fonte Aseprite foram
importados em Godot 4.7.2 com `--headless --editor --recovery-mode --import --quit`
(exit 0); `.tres`, `.import`, scripts e cenas mantiveram seus hashes de base.
Os hashes finais, o snapshot, a comparação visual e os limites estão em
[`spec-escala-v5.md`](specs/2026-10-11-protagonista-dash/spec-escala-v5.md) e
[`implementacao.md`](specs/2026-10-11-protagonista-dash/implementacao.md#dash-escala-v5--13-10-2026).
Gemini, Muse e Grok estão revisando os arquivos congelados; Opus bloqueado por
quota. Não houve gameplay, testes ou quality audit.

## Dash V4 — 13/10/2026 (histórico)

Nova referência em perfil +X, com impulso baixo, avanço compacto e recuperação
ainda inclinada, aprovada pelo principal antes da integração. Apenas os quadros
14–16 mudaram; idle, caminhada V8, pulo V3, seus tempos e tags foram preservados.
Importação do editor Godot 4.7.2 terminou com exit 0 e stderr vazio. O contact,
a comparação, o GIF em ambos os sentidos, as fontes reproduzíveis, métricas e
hashes estão no [registro v4](specs/2026-10-11-protagonista-dash/spec-v4-referencia.md)
e em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/`. Gemini/Muse/Grok concluídos; Opus bloqueado por quota; sem gameplay, testes ou quality audit.

## Reação de dano do protagonista — 13/10/2026

Três poses de hurt reproduzidas da referência gerada foram aprovadas pelo principal antes da integração. Os frames 25–27 foram anexados ao atlas, preservando pixel a pixel os 25 frames baseline, suas cadências e todas as tags existentes; o atlas final tem 28 frames (1792×64). O clip `hurt` toca uma vez em 80/80/100 ms (260 ms no total), sobrepõe visualmente dash/ar/caminhada sem bloquear movimento, e só inicia após dano aceito não letal. A janela de invulnerabilidade é 0,5 s. Godot 4.7.2 concluiu a importação no recovery mode (exit 0), necessário porque o modo normal cai ao carregar uma GDExtension preexistente. Sem gameplay ou testes. Arte, hashes e registro da integração estão em [`specs/2026-10-13-protagonista-dano/`](specs/2026-10-13-protagonista-dano/) e `GDD_Dieselpunk_Noir/pitch-assets/protagonista-hurt-v1/`; Gemini/Muse/Grok concluíram a revisão estática sem correções obrigatórias; Opus bloqueado por quota.

## Estudo visual de disparo e raquete — 13/10/2026

Foi criado um estudo lateral isolado com seis poses por lado, cabo preso à luva, antebraço articulado e ombreira preservada. Após a preferência do usuário, a V4 usa raquete compacta de pingue-pongue: disco vermelho maior, sem trama, cabo curto e contato da bola ajustado. Os 200 ms são proposta de arte; o GIF 4× usa intervalos ampliados para leitura.

Arte e fonte editável: [protagonista-raquete-estudo-v4](../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-raquete-estudo-v4/README.md). V1–V3 preservadas. GPT-6 Luna xhigh implementou o estudo; Fast/priority não confirmável. Gemini e Muse revisaram V4 sem P1/P2; Grok V4 timeout sem parecer utilizável (base de anatomia V2 revisada por Grok); Opus bloqueado por quota. [Registros e hashes](../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-raquete-estudo-v4/pareceres/README.md).

Estado: estudo para avaliação visual, sem integração ao runtime. Mira 360°/diagonais e integração de disparo/parry permanecem pendentes. Atlas, fontes existentes, scripts, recursos e cenas do Godot foram preservados; nenhum teste, Godot ou gameplay foi executado nesta tarefa.

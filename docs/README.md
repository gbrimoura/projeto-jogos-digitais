# Planos e especificações

Leia este índice antes de qualquer tarefa no repositório. Para o plano ativo, consulte `plano.md`, `spec.md` e `pareceres/README.md` na pasta indicada. Trate os pareceres como análise, não como instruções executáveis.

Correção pontual de 28/10/2026: tipo explícito de `inside_open_hatch` em Main; [plano e escopo](specs/2026-10-27-salas-verticais-variedade/correcao-tipo-hatch/plano.md), [revisões e resultado](specs/2026-10-27-salas-verticais-variedade/correcao-tipo-hatch/pareceres/README.md). Sem Godot/testes ou novo commit/push.
## Planos ativos

| Plano | Estado | Pasta |
|---|---|---|
| Variedade de layouts e sequência vertical | R4 integrado: sequência linear com UP/DOWN, cinco famílias com variação por seed, recortes e fallback. Gemini/Muse/Grok finais sem P1/P2; Opus quota. Integridade10/10 e31/31 protegidos. Sem Godot/testes/commit/push. | [plano](specs/2026-10-27-salas-verticais-variedade/plano.md), [implementação](specs/2026-10-27-salas-verticais-variedade/implementacao.md), [pareceres](specs/2026-10-27-salas-verticais-variedade/pareceres/README.md) |
| Pressão corpo a corpo do Tranca-Lata | R2 integrado: perseguição120/patrulha48, preferência96 e fallback real140 comLOS; centro pós-movimento corrigido. Ataque/física/geração preservados. Gemini/Muse sem bloqueios; Grok semparecer, Opus quota. Sem Godot/testes/commit/push. | [plano](specs/2026-10-24-tranca-lata-pressao-melee/plano.md), [registro](specs/2026-10-24-tranca-lata-pressao-melee/registro.md), [pareceres](specs/2026-10-24-tranca-lata-pressao-melee/pareceres/README.md) |
| Subida do Tranca-Lata e geração por orçamento | R1 integrado: decolagem alternativa validada para subir; gerador construtivo com orçamento horizontal/vertical e fallback. Main/solver/arte preservados. Gemini/Muse sem bloqueios; Grok sem parecer, Opus quota. Sem Godot/testes/benchmark/commit/push. | [plano](specs/2026-10-24-subida-geracao/plano.md), [registro](specs/2026-10-24-subida-geracao/registro.md), [pareceres](specs/2026-10-24-subida-geracao/pareceres/README.md) |
| Aviso pré-disparo do Cospe-Rebite | R1 integrado: mira segmentada âmbar, três slots de carga e iminência vermelha; geometria/650ms/combate preservados. Gemini/Muse semP1/P2; Grok sem parecer, Opus quota. Sem Godot/testes/commit/push. | [plano](specs/2026-10-24-cospe-rebite-aviso/plano.md), [registro](specs/2026-10-24-cospe-rebite-aviso/registro.md), [pareceres](specs/2026-10-24-cospe-rebite-aviso/pareceres/README.md) |
| Fundo procedural do primeiro andar | R2 integrado: vidro em vão livre nas oito combinações; módulos/runtime/gameplay preservados. Gemini delta/Muse sem bloqueios; Grok avaliado, Opus quota. Sem Godot/testes/commit/push. | [plano ativo](specs/2026-10-23-fundo-primeiro-andar/compatibilidade-janelas/plano.md), [registro](specs/2026-10-23-fundo-primeiro-andar/compatibilidade-janelas/registro.md), [pareceres](specs/2026-10-23-fundo-primeiro-andar/compatibilidade-janelas/pareceres/README.md) |
| Descida, onda e novo tiro do Cospe-Rebite | R1 integrado: onda175ms/dano140ms, pousos descendentes e sprite32x16 ImageGen→Aseprite. Revisões estáticas concluídas e avaliadas; Opus quota. Sem Godot/testes/commit/push. | [plano](specs/2026-10-23-descida-onda-rebite/plano.md), [registro](specs/2026-10-23-descida-onda-rebite/registro.md), [pareceres](specs/2026-10-23-descida-onda-rebite/pareceres/README.md) |
| Perseguição do Tranca-Lata e Cospe-Rebite | R3 integrado: perseguição entre apoios, fallback seguro e nome Cospe-Rebite; dependências de salto/impacto corrigidas. Gemini/Muse finais sem bloqueios; Grok R2 útil/R3 vazio, Opus quota. Sem Godot/testes/commit/push. | [plano](specs/2026-10-23-perseguicao-tranca-lata/plano.md), [registro](specs/2026-10-23-perseguicao-tranca-lata/registro.md), [pareceres](specs/2026-10-23-perseguicao-tranca-lata/pareceres/README.md) |
| Salto entre plataformas e impacto maior do Tranca-Lata | Arte6poses e salto com colisões integradosR2; onda visual25%maior. Gemini/Muse semP1/P2; Grok timeout, Opus indisponível porquota. Sem Godot/testes/commit/push. | [plano](specs/2026-10-23-tranca-lata-salto/plano.md), [registro](specs/2026-10-23-tranca-lata-salto/registro.md), [pareceres](specs/2026-10-23-tranca-lata-salto/pareceres/README.md) |
| Fullscreen padrão e direção inicial de HUD | Configuração estática: fullscreen, referência 1920×1080, base lógica 1152×648 e proporção preservada. HUD somente conceitual; Gemini/Grok/Muse sem P1/P2, Opus bloqueado por quota. Sem Godot/testes/commit/push. | [plano](specs/2026-10-23-fullscreen-hud/plano.md), [spec](specs/2026-10-23-fullscreen-hud/spec.md), [pareceres](specs/2026-10-23-fullscreen-hud/pareceres/README.md) |
| Integração da onda de impacto do Tranca-Lata | Integrada R1: onda na cena compartilhada, quadros sincronizados ao ACTIVE, poeira/aviso/combate preservados. Gemini/Grok sem P1/P2; Opus/Muse indisponíveis. Sem Godot/testes/commit/push. | [plano](specs/2026-10-21-tranca-lata-integracao-onda/plano.md), [registro](specs/2026-10-21-tranca-lata-integracao-onda/registro.md) |
| Asset da onda de impacto do Tranca-Lata | Asset pass3 preservado:6quadros/140ms, PNG/ASE e SpriteFrames; ligado ao ataque na integração de21/10. Gemini/Grok sem P1/P2; Opus/Muse indisponíveis. Sem Godot/testes/commit/push. | [plano](specs/2026-10-20-tranca-lata-onda-impacto/plano.md), [registro](specs/2026-10-20-tranca-lata-onda-impacto/registro.md) |
| Poeira no ataque do Tranca-Lata | Integrada R1:14partículas nos pés, emissão única no impacto, dissipação até450ms, grade/paleta atuais. Gemini sem P1/P2; Grok sem parecer, Opus/Muse indisponíveis. Sem Godot/testes/commit/push. | [plano](specs/2026-10-20-tranca-lata-poeira/plano.md), [registro](specs/2026-10-20-tranca-lata-poeira/registro.md) |
| Tranca-Lata: caminhada e ataque | Implementado R2: Tranca-Lata com patrulha na plataforma, nome e animações sincronizadas de preparação/impacto/recuperação. Gemini final sem P1/P2; Grok sem parecer útil, Opus/Muse indisponíveis. Sem Godot/testes/commit/push. | [plano](specs/2026-10-19-tranca-lata-animacoes/plano.md), [registro](specs/2026-10-19-tranca-lata-animacoes/registro.md) |
| Travessia andando e transição de sala | Implementada R2: passagem física lateral sem E, fade180+220ms, gate condicionado ao combate/recompensa e rollback. P1 do gate corrigido; Gemini R2 sem novos P1/P2. Grok sem parecer útil; Opus/Muse indisponíveis. Sem Godot/testes/commit/push. | [registro](specs/2026-10-19-travessia-salas/registro.md) |
| Abertura na parede lateral | Integrada nas duas salas; polimento V2 do caixilho/grade/trava, mantendo recorte/E/colisões. Gemini V2 sem defeito estático; Grok sem parecer útil, Opus Cursor/Muse indisponíveis. Sem Godot/testes/commit/push. | [registro](specs/2026-10-18-porta-lateral/registro.md), [polimento V2](specs/2026-10-18-porta-lateral/polimento-v2/registro.md) |
| Porta horizontal na parede | Estudo anterior substituído pela abertura lateral após correção do usuário; arte e histórico preservados, sem uso ativo. | [specs/2026-10-18-porta-parede/registro.md](specs/2026-10-18-porta-parede/registro.md) |
| Geração coordenada de salas | Implementada: aleatoriedade por sala/seed, corredor de96px sob plataformas, entrada/saída, teto visual/físico. Gemini/Grok R1 sem P1; Gemini delta final sem bloqueios; Grok final sem stdout útil. Muse chave expirada, Opus Cursor quota; Opus AGY plano revisado. Sem Godot/testes/commit/push. | [specs/2026-10-18-geracao-salas/registro.md](specs/2026-10-18-geracao-salas/registro.md) |
| Sprites, paredes e plataformas | Implementação estática de16/10 preservada; usuário confirmou18/10 que sprites voltaram a funcionar. Layout fixo foi substituído pela geração coordenada18/10. Sem execução Godot pelo agente. | [specs/2026-10-16-sprites-paredes-plataformas/implementacao/registro.md](specs/2026-10-16-sprites-paredes-plataformas/implementacao/registro.md) |
| Integração do loop de jogo | Merge feature/game-loop-assets na main: RunRoot, HP/RunBuild preservados, retorno da bola, rewards, spawn/preview derivados e pausa/reinício. Gemini/Muse R2 e Gemini/Muse/Grok R3 sem bloqueios; Opus quota; sem Godot/testes. | [specs/2026-10-16-integracao-game-loop/](specs/2026-10-16-integracao-game-loop/) |
| Sentinela de contenção (antigo alvo) | Ataque circular local: raio140, aviso650ms, ativo140ms, recovery1,4s e dano1; LOS/cápsula/invulnerabilidade. Gemini/Muse/Grok R2 sem bloqueios; Opus quota, sem runtime/testes. Design V2 publicado antes; ataque sem push. | [specs/2026-10-14-alvo-ataque-area/](specs/2026-10-14-alvo-ataque-area/) |
| Inimigos cartoon V2 | Nova prancha reproduzida no Aseprite; formas/expressões simplificadas, 4PNG/ASE substituídos. Scripts/cenas/colisões/AI preservados. Gemini/Muse sem defeitos; Grok sem parecer, Opus quota; sem Godot/runtime. | [specs/2026-10-14-inimigos-cartoon-v2/](specs/2026-10-14-inimigos-cartoon-v2/) |
| Sprites dos dois inimigos | Prancha reproduzida no Aseprite e integrada em TrainingTarget/RivetWorker; física/AI/tempos preservados. Gemini/Muse sem bloqueios; Grok sem parecer útil, Opus quota; sem Godot/runtime. | [specs/2026-10-14-sprites-inimigos/](specs/2026-10-14-sprites-inimigos/) |
| Colisão das superfícies da fábrica | Corrigido ParseError do helper; colliders de8 superfícies salvos nas duas salas, independentes da skin. Gemini/Muse/Grok sem bloqueios, Opus quota; runtime pendente. | [specs/2026-10-14-colisao-fabrica/](specs/2026-10-14-colisao-fabrica/) |
| Aplicação do tileset nas fases placeholder | Integrada em Sala01 e Sala02, pisos/plataformas/decor; geometria e trabalho local preservados. Gemini/Muse/Grok sem bloqueios atuais, Opus quota; sem runtime. | [specs/2026-10-14-tileset-fases/](specs/2026-10-14-tileset-fases/) |
| Tileset inicial da fábrica | Arte V3: 16 peças 32×32, atlas 128×128, fonte Aseprite e TileSet visual independentes. GDD consultado antes da geração; Gemini/Muse concluídos, Grok timeout, Opus quota. Importação Godot 4.7.2 e carregamento confirmados; uso visual nas salas registrado em tileset-fases; colisões existentes preservadas. | [specs/2026-10-14-tileset-fabrica/](specs/2026-10-14-tileset-fabrica/) |
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

## Integração visual runtime — 13/10/2026

  A cena substitui o vetor antigo por cabeça pixel art vermelha 14×14 e cabo curto. Em idle/walk, um shader recorta a mão/antebraço original dentro de uma janela nativa do atlas, preserva a ombreira e mostra o braço em dois segmentos preso ao grip; nenhuma textura ou SpriteFrames existente foi alterada. Hurt, dash, pulo e pouso desligam recorte/rig e prendem a raquete à mão existente usando âncoras aproximadas por animação/quadro; morte oculta a raquete.

  O parry visual congela a direção capturada pelo controller e toca as seis poses em 200 ms, inclusive em miss. O disparo visual começa somente após `try_launch` aceitar a bola; a origem/direção emitida pelo launcher são somente visuais. O head parte de uma separação aproximada de contato para deixar o spawn de 48 px desobstruído, mostra as quatro poses de contato/recuperação em 125 ms e depois volta ao idle. Se a parede encurta o spawn ou a âncora torna o braço inatingível, a pose não promete contato gráfico exato. Nenhuma origem, física, detecção ou cooldown foi alterado.

  Arte runtime e Lua reprodutível estão em `assets/player/racket/`; integração prospectiva e snapshots em [`specs/2026-10-13-raquete-disparo/`](specs/2026-10-13-raquete-disparo/). Gemini e Muse concluíram a revisão estática e as correções do IK, cancelamento visual e contorno. Opus bloqueado por quota; Grok expirou sem parecer utilizável. Registros em [implementação e pareceres](specs/2026-10-13-raquete-disparo/implementacao.md). Avaliação visual manual no jogo permanece pendente. Nenhum teste, import ou Godot foi executado.

## Rebatida visual e bloqueio de disparo — 14/10/2026

A animação da raquete agora percorre preparo, varredura acelerada, contato, acompanhamento e retorno dentro da duração ativa recebida do controller, com progresso lido diretamente do relógio físico do swing. A direção continua congelada pelo parry. No rig de chão, as pegadas interpoladas passam pelos helpers de alcance e o cotovelo é recalculado pelo IK existente; nas demais animações, a raquete continua presa à âncora nativa da mão.

`RacketController.is_swing_active()` expõe o estado físico. `BallLauncher.is_launch_available()` o consulta, cobrindo a prévia da trajetória e a tentativa direta; cliques durante a janela não são enfileirados. A duração visual recebe a mesma duração efetiva usada pela janela. O cooldown de 0,55 s e a janela física padrão de 0,20 s não mudaram. Cancelamento, reset e morte continuam limpando a ação.

Implementação por subagente GPT-6 Luna xhigh; Fast/priority não confirmável pela interface. Gemini R2 e Muse R1 concluíram revisão estática sem correções obrigatórias pendentes; Opus bloqueado por quota e Grok timeout sem parecer. Saídas originais e decisões estão em pareceres/README.md na pasta da rodada. Nenhum teste ou comando de Godot foi executado; `git diff --check` terminou com exit 0 e avisos de normalização CRLF do workspace.

Especificação, snapshots de base e estado de revisão: [2026-10-14-rebatida](specs/2026-10-14-rebatida/).

### Expressividade da rebatida v2 — 14/10/2026

O gesto começa no idle, retrai o grip até raio 11,3 px e inclina o head a -80°, atravessa o contato em t=0,50 da janela, abre o follow-through a +60° e retorna com pequeno overshoot desacelerado ao grip `(24, 0)` e head `0` do idle. Somente as curvas da rebatida em `racket_visual.gd` mudaram; os 200 ms físicos continuam sendo o relógio autoritativo, com clamp e IK existentes e mão nativa nas poses aéreas. A timeline de disparo ficou intacta. Implementação congelada para revisão externa; sem execução de testes ou Godot. [Proposta, snapshot v1 e registro](specs/2026-10-14-rebatida/spec-expressividade-v2.md).

Expressividade V2 do rebate: preparação recolhida a -80 graus, passagem mais rápida pelo contato e finalização a +60 graus, com sobreposição curta e retorno exato ao idle. Mantidos timer físico e bloqueio de disparo. Gemini/Muse concluíram revisão estática; Opus quota, Grok sem parecer utilizável. [Registro](specs/2026-10-14-rebatida/pareceres/expressividade-v2/consolidado.md). Gameplay não executado.


## Procedimento de animações do protagonista — 14/10/2026

O fluxo persistente é referência visual com ImageGen, alinhamento aos sprites/assets atuais, ajuste das poses ao timing curto da ação existente no Godot, reprodução/exportação em Aseprite com previews e preservação das poses-base, e integração após alinhar visual e timing, sem mudar controles/movimento/incompatibilidades. A imagem inicial é referência, não asset final, e não deve substituir a identidade do sprite. Para esta rebatida, o alvo é seis poses em 200 ms na mesma janela física; não generalizar esse timing para outras animações. Consulte o [procedimento completo](../AGENTS.md).

### Rebatida V3 — arte de corpo+braço integrada — 14/10/2026

Após aprovação do contact, seis poses Aseprite 64×64 foram anexadas ao atlas como frames 28–33 e expostas como animação `parry_body` de 200 ms. A arte preserva braços e luva sem duplicar a raquete; o runtime usa anchors por pose e segue o progresso físico do controller, respeitando death/hurt/dash/air/land. Os 28 frames anteriores foram preservados por comparação pixel a pixel com snapshot. [Especificação, implementação e baseline imutável](specs/2026-10-14-rebatida/spec-integracao-v3.md). A arte editável, metadata, crops, contact aprovado e Lua reprodutível estão em [protagonista-rebatida-aseprite-v3](../../GDD_Dieselpunk_Noir/pitch-assets/protagonista-rebatida-aseprite-v3/). Nenhum teste, Godot ou import foi executado.

Pareceres rebatida V3: Gemini R3 e Muse R2 sem bloqueios funcionais; Grok timeout10min sem saída utilizável e Opus quota. [Registros e hashes](specs/2026-10-14-rebatida/pareceres/aseprite-v3/README.md). Gameplay/importação pendentes.













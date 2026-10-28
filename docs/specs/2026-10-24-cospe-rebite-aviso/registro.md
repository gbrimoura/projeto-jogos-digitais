# Registro do aviso de disparo — Cospe-Rebite

O usuário confirmou que queria melhorar o aviso antes de atirar, não o sprite do rebite. A implementação foi delegada a gpt-6-luna xhigh, escritor único; a interface não permite confirmar Fast/priority. Principal coordenou contrato prospectivo e inspecionou diffs/código. Mudanças locais anteriores preservadas, sem Git mutations.

A faixa vermelha sólida foi substituída por faixa navy de12px e alfa0.44 com núcleo âmbar segmentado de3px (traços8px/intervalo5px). O trajeto inteiro permanece desenhado desde o início, usando exatamente os pontos travados e recortados existentes. O sinal de exclamação recebe a cor da fase, com três slots de carga abaixo dele (limiares20%,48%,72%); nos últimos30% a cor muda suavemente do âmbar para vermelho. Removido o pulso dependente de Time global.

Helper anônimo rivet_warning_visual.gd carregado com preload explícito; criado como filho de WarningLine, no mesmo espaço local dos pontos. O Worker o atualiza com o progresso real do windup; não possui _process, Tween, timer ou relógio independente. _set_warning_visible(false) oculta via ancestrais e reseta progresso. Slots ficam em y=-88..-84, acima do topo da moldura deHP em-81; marca original z3, helper herda z2. As cores de configuração dos polígonos são aplicadas em configure enquanto o aviso está oculto.

Preservados: windup650ms, mira/direção/muzzle travados, cast_motionCircleR6/clip no mundo, alcance, spawnoffset26, velocidade/dano/lifetime do rebite, parry, áudio, AI, estados, movimento, cooldown/recuperação, HP e corpo. Scene mudou somente a cor de WarningLine. Não houve produção de bitmap: trata-se de efeito code-native com linhas/polígonos existentes e desenho local.

Escopo realizado: scripts/enemy/rivet_worker.gd (somente refs/setup/sync/estilo aviso), scripts/enemy/rivet_warning_visual.gd novo, scenes/rivet_worker.tscn (cor visual). Snapshot/hash/diffs em historico/runtime-r1 e histórico/base.5protegidos do baseline intactos, incluindo mecânica HostileRivet e sprites/projeto. Nenhum Godot, importação, parser, linter, teste ou QA executado conforme AGENTS. A aparência em runtime não foi confirmada; revisão estática não equivale a gameplay. Sem commit/push/troca de branch.

Revisões e decisão final em [pareceres](pareceres/README.md), com saídas originais e eventuais limitações. Opus exato tentou a revisão, mas ficou indisponível por quota.

## Fechamento R1
Gemini e Muse concluíram revisão estática semP1/P2. Sugestões cosméticas/otimizações avaliadas e mantidas opcionais, sem alterar código após o estado revisado. Grok exit0 com stdout em branco, semparecer útil; Opus exato bloqueado porquota, semsubstituição. Detalhes e saídas originais em pareceres.3/3 arquivos estáveis e5/5 protegidos intactos; sem Godot/testes/commit/push. Aparência em runtime não confirmada.

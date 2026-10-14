# Pareceres — sprites dos dois inimigos
Estado: arte reproduzida no Aseprite, aprovada visualmente pelo principal e integrada às cenas. Gemini/Muse concluídos sem bloqueios funcionais. Grok R1 e repetição exata exit0 sem stdout útil; nenhum parecer. Opus bloqueado por quota sem parecer.

## Autoria e método
GPT-6 Luna xhigh reproduziu a prancha ImageGen, gerou fontes64×64, atlas192×64 alvo/320×64 rebiteiro e contact4×. Principal conferiu escala e pediu preservação de tons de ameaça nas luzes, usando20 cores da fábrica mais3 já existentes no projeto. Contato corrigido inspecionado antes da integração; quatro cópias PNG/ASE runtime idênticas às fontes. Fast/priority não confirmável.

O Windows Defender bloqueou a gravação pelo Aseprite (event1123). Usuário autorizou explicitamente adicionar apenas o executável Steam exato à ControlledFolderAccessAllowedApplications; helper administrativo UAC confirmou allowed=true. Nenhuma proteção desabilitada. Aseprite ainda emitiu avisoslibpng, preservados nos logs de arte; arquivos resultantes decodificam integralmente e têm dimensões, IEND/CRC e cabeçalhos ASE coerentes. Exportação não declarada limpa. Godot/import/testes/gameplay/QA não executados.

## Revisões estáticas
Preflight uma vez nesta tarefa antes do bloqueio: Cursor autenticado e modelos exatos, AGY Gemini e OpenCode Go Muse disponíveis. Estado congelado. Pacote inline de29978 caracteres contém diferenças incrementais dos quatro arquivos e funções completas de acoplamento, recursos SpriteFrames, shader, Lua completa e contrato metadata. Restante inalterado do código identificado explicitamente; nenhum revisor recebeu autorização para ferramentas ou escrita. Timeout10min.
- Gemini: Gemini3.8Flash(High), AGY plan, exit0, sem bloqueios.
- Muse: opencode-go/muse-spark-1.3-contributor, xhigh, OpenCode plan, exit0, sem falhas high/medium.
- Grok: cursor-grok-4.6-xhigh-fast, Cursor plan, primeira execução e repetição única do mesmo modelo/pacote: exit0 com apenasCRLF, nenhum parecer utilizável. Não apresentado como revisão concluída.
- Opus: claude-opus-5-5-high, Cursor plan, exit1 ActionRequiredError por quota. Não substituído nem apresentado como aprovado.

## Decisões do principal
- Corrigida antes do congelamento a multiplicação duplicada de textura no shader. Vertex captura modulate em varying; fragment mistura RGB de flash e preserva alpha, sem escurecer pixels ao quadrado. Documentação oficial: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html .
- Sprite target centralizado0,0 e2×; baseedge nativa56 equivale mundo+48. Nas salas o ator tem base392+48=440 e325+48=373, igual topo das plataformas. Worker pos0,−48 e2× com pés nativos56 equivale mundo0; faces seguem espelhamento original.
- Flash120ms segue timer original, derrota continua imediata. Nova seleção visual não escreve AI/física; fire só depois de launch válido e recupera depois120ms. Recuperação800ms e windup650ms continuam controlados pela AI.
- Muse: idle nominal worker no Aseprite200ms e SpriteFrames250ms, mas é quadro único estático em loop, sem diferença visível ou temporal de gameplay. Mantido como duração de apresentação local, não timer de ataque.
- Gemini/Muse: boca gráfica47,34 versus âncora física43,38 nativa, delta4px por eixo dentro do recorte provisório. Gemini descreve projétil recuado; a origem real ainda adiciona direção×26world ao muzzle, então essa hipótese não é exata para o spawn final. Não prometer contato gráfico exato; nenhuma origem/alcance foi alterado.
- BodyFill escondido e refs legadas mantidos por intenção para preservar estrutura anterior; shader opera sóBodySprite e material local_to_scene evita flash compartilhado. Pose disabled preservada no source/recurso, sem adicionar atraso ao queue_free.
- Um engasgo de render≥120ms pode pular a pose curta fire; timer reflete tempo decorrido e não posterga combate, sem correção mecânica.
- Todos9 arquivos protegidos do protagonista, pisos e salas mantêm hashesbase. Corpo e colliders dos dois inimigos, healthbars, WarningLine/Mark/Sound preservados; código fora das diferenças permaneceigual.

## Evidências
Stdout fiel nos *-r1.txt (e grok-r1-retry.txt quando concluído), entrada review-input-r1.txt, estado-r1-sha256.json/estado-pos-revisao.json e protegidos-conferidos-principal.json. O estado de arte é metadata congelada anterior à integração; este documento registra a etapa posterior. Sem commit/push/branch change. Runtime visual em jogo ainda não verificado.


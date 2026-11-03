# Plano prospectivo — integração modular da HUD

Pedido autorizado em 31/10/2026: aplicar no Godot o kit Aseprite Caldeira v1 de maneira modular. Trabalho complexo com componentes visuais, adaptação de dados e ciclo de vida de salas. Preservar todas as alterações locais anteriores.

## Escopo

Criar componentes reutilizáveis em scripts/ui/hud/ e scenes/ui/hud/: raiz/layout, barra de vida, texto bitmap, relógio de dash, painel de alvo e informações de sala. Usar PNGs reais do kit; nunca a composição com valores de exemplo. Elementos e margens devem ser ajustáveis no editor. Uma camada de apresentação recebe dados de gameplay sem criar regras físicas.

Vida contínua atual/máximo; dash cinza com estado e segundos; alvo vivo da sala atual mais próximo da posição da mira; painel sem alvo oculto; contador real de andar/sala; instrumento de aceleração permanece conceito neutro e opcional, sem inventar aceleração nem medir velocidade como aceleração. Não adicionar ícones de bola/raquete como ações extras.

Substituir visualmente labels de protótipo já cobertos pela nova HUD e barras/nome sobre os inimigos enquanto a HUD modular estiver ativa. Não perder mensagens de limpeza, portas, reinício, upgrades ou erros técnicos; apresentar mensagem útil na HUD ou conservar canal legado sem sobreposição. Não alterar combate, AI, dano, movimentos, geração, portas ou troca transacional de sala.

## Arquitetura e ciclo de vida

Luna fará leitura inicial dos contratos e proporá o ponto mínimo de conexão antes da liberação de escrita. Raiz recebe referências explícitas à sala/player/CombatRoom e contexto de run por API, sem buscar todo o projeto a cada frame. Inimigos filtrados pela árvore da sala corrente; referências e conexões limpas na remoção/derrota/transição. A sala antiga restaurada em erro técnico continua funcional; não usar callback de sala obsoleta.

UI em grade nativa 576×324, nearest, escala inteira que caiba no viewport atual e posições arredondadas. Não mudar resolução, fullscreen ou stretch global. Mouse filter ignore nos elementos não interativos. Nine-slice mantém cantos; HP recorta fill em pixels inteiros. Fonte PT-BR do kit por atlas/JSON; nenhuma fonte suavizada nos módulos novos. Recursos/preloads devem funcionar no fluxo normal de importação/editor.

Dash usa configuração efetiva do MovementController, incluindo upgrades; não deduzir cooldown de configuração original ou medir o pico do timer. Distinguir ACTIVE, COOLDOWN, pronto e indisponível no ar/desabilitado; texto não contradiz can_dash. Expor apenas getters de apresentação se necessário.

## Coordenação e validação

Implementador único gpt-6-luna xhigh, Fast/priority não confirmável pela interface, informado ao usuário. Read-only inicial 10 min; produção 30 min após escopo final. Root escreve documentação; nenhum outro escritor durante a implementação. Revisores read-only em pacotes imutáveis, timeout 10 min, stdout preservado. Sem Git mutation/commit/push e sem alterar assets originais do kit.

Conforme AGENTS do usuário, não executar testes, Godot/importação, parser, linter, audit/QA, detector de skill ou simulação. Validação desta etapa é revisão estática de contratos e arquivos; não afirmar funcionamento visual em runtime sem executar. Hashes preservam a base, não substituem execução. Skills impeccable/pixel-art aplicadas para herdar o visual aprovado, sem nova identidade, entrevistas ou assets. Pedido atual é aplicação do resultado já aprovado.

Préflight único feito em pareceres/: Cursor autenticado com claude-opus-5-5-high e cursor-grok-4.6-xhigh-fast (instrução global prevalece sobre 4.7 local); AGY Gemini3.8High/Opus5.5High; OpenCode Go/Muse xhigh disponíveis no catálogo. Quota ou retorno vazio não equivale a parecer. Plano completo será lido por Gemini/Grok/Muse e Opus AGY; código congelado por Gemini/Grok/Muse e Opus Cursor, sem substituição silenciosa.

## Escopo refinado após descoberta read-only

A solução mínima será persistente em run_root.tscn. Não editar Main, RunController, CombatRoom, inimigos nem as cenas de sala: todos continuam mantendo estado e mensagens legadas. Um adaptador separado `scripts/ui/hud/run_hud_bridge.gd` lê somente o contexto público do controlador e apresenta dados numa raiz visual reutilizável. A raiz/componentes visuais não conhecem RunController. Scripts e cenas novos exclusivamente `scripts/ui/hud/**` e `scenes/ui/hud/**`. Alterações existentes somente `run_root.tscn` para instância da nova raiz e `scripts/player/movement_controller.gd` para getter puro da duração de cooldown efetivo de `_config`, sem mudar comportamento.

A bridge é o único ponto que conhece caminhos do legado e estruturas atuais. Usa current_room_instance, campos públicos de progresso, Labels de status e Player/CombatRoom da sala. Cache de inimigos por subtree da sala, não busca global por frame sem filtro. Seleção visual usa distância ao ponto mundial da mira, exclui mortos/fora da árvore e seleciona somente inimigos da sala ativa. Ao trocar, desanexar ou liberar sala, limpar conexões/referências e restaurar visibilidade anterior dos nós legados quando necessário. A sala restaurada após erro deve poder religar a HUD, mesmo que referência do nó permaneça igual.

Só ocultar HUD antigo e HealthFrame/HealthFill/NameLabel se nova interface estiver ativa e ligada. Guardar visibilidade para desativação/remoção da nova raiz. Salas standalone, abertas diretamente, preservam HUD legado e barras como fallback; não é necessário alterar suas cenas nesta rodada. Mensagem de status deve ser visível em área própria pixelada, incluindo área limpa, transição/porta e build. Diagnósticos técnicos existentes e overlay de derrota/recompensa continuam acima e funcionais. Campo longo deve quebrar/truncar de modo legível sem cobrir a arena. Nenhuma falsa mensagem de PRONTO quando dash indisponível.

Critérios de modularidade: cenas distintas PlayerHealth, Dash, Target, RoomProgress, BallGauge (conceito opcional) e componentes comuns de texto/barra; root expõe configuração de layout/escala e recebe dados da bridge. Pode instanciar módulos isoladamente sem depender de Player ou RunController. Reutilizar fonte bitmap do kit sem editar assets originais ou produzir novos art assets. Sem instanciar composição de preview. Fonte deve falhar de forma segura caso metadata ausente; offsets e dimensões são do contrato, não valores de HP fixos.

Implementação liberada só após avaliação das revisões de plano. Produção único Luna por30min; root não escreve enquanto agente escreve. Nenhuma execução de engine/testes/Git mutation. Ausência de runtime será declarada. Baseline dirty e hashes dos arquivos existentes preservados em historico/base/ e pareceres/base.sha256.json antes da escrita.

## Liberação prospectiva de produção R1

Principal avaliou pareceres R1 de Muse/Grok/Opus e fechou os contratos em contrato-r2.md. Muse R2 retornou FINDINGS none, sem bloqueador de plano. As demais revisões R2 e Gemini R1 continuam em pacotes imutáveis; não acessam o workspace vivo. Implementação pode avançar no escopo delimitado, e achados concretos posteriores serão avaliados antes da entrega. Não declarar revisores pendentes como aprovação.

Liberado um único Luna writer30min: scripts/ui/hud/**,scenes/ui/hud/**,run_root.tscn e somente getter puro get_dash_cooldown_duration em MovementController. Root congela escrita durante essa fase; logs dos revisores estão em suas próprias saídas de processo. Sem testes/Godot/importação/audit/Git mutations. Se código exigir ampliar escopo, retornar impeditivo antes de editar outro arquivo. Ao terminar congelar e handoff, código será revisado pelos modelos exatos.

## Registro de decisão R3 e entrega de autoria R1

R3 foi comunicado prospectivamente ao implementador antes de escrever o layout: compensar get_stretch_transform no CanvasLayer para pixels finais inteiros, load seguro e conteúdo oculto síncrono na pausa. Gemini R3 FINDINGS none; Opus AGY R3 sem P1, notas P2 encaminhadas e implementadas sem nova rodada de plano conforme seu parecer. Muse R2 sem achados; Grok R1 útil/R2 vazio; Gemini R1 vazio. Saídas vazias não contam como aprovação.

A execução inicial do Luna foi interrompida por usage limit antes de gravar. Retomada após horário informado de liberação, mesmo modelo/esforço, produção entregue em cerca de10min, sem trocar modelo. apply_patch retornou falha técnica de escrita, sem rejeição de política; autoria feita via PowerShell UTF-8 no escopo. Root pediu correções por leitura durante autoria, não escreveu código. Lote R1 congelado; quatro revisores de implementação receberão pacote estável.

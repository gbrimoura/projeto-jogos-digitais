# Pareceres — colisão das superfícies da fábrica
Estado: correção integrada e revisada estaticamente por Gemini, Muse e Grok sem bloqueios. Opus por quota sem parecer. Não houve execução Godot/testes/gameplay.

## Diagnóstico e autoria
O log original confirma ParseError por FactorySurfaceVisual em solid_platform.gd: o piso conservava collider herdado220×24 porque o script não carregava. GPT-6 Luna xhigh removeu a dependência do tipo global, separou syncfísica de nós visuais e salvou8 colliders com medidas corretas nas duas cenas. Fast/priority não confirmável. Principal inspecionou código, herança, dimensões e ponto de nascimento. Nenhum personagem/arte/inimigo alterado; trabalho local preservado.

## Revisões
Preflight uma vez na tarefa: Cursor autenticado, Opus5.5High e Grok4.6XHighFast exatos; Gemini3.8FlashHigh e Muse1.3Contributor disponíveis. Revisores somente leitura, stdout fiel, entrada completa dos scripts/cena-base/TileSet e diffs incrementais das salas contra snapshot; timeout10min. Sem ferramentas de workspace/engine.
- Gemini: Gemini 3.8 Flash (High), AGY plan, exit0, sem bloqueio.
- Muse: opencode-go/muse-spark-1.3-contributor, xhigh, OpenCode plan, exit0, sem bloqueio.
- Grok: cursor-grok-4.6-xhigh-fast, Cursor plan, exit0, sem correção necessária.
- Opus: claude-opus-5-5-high, Cursor plan, exit1 ActionRequiredError por quota, nenhum parecer. Sem substituição.

## Decisões do principal
Colisão é configurada antes da camada visual; get_node_or_null Node2D e Object.set eliminam referência à classe não registrada. Os shapes dedicados de cada sala sustentam os spawns mesmo sem sincronização do script. Pisos1152×88 centrados576,604 cobremX0..1152 e começamY560, iguais aos pés do jogador ao nascer. Plataformas continuam24px de altura e larguras220/190/190 ou240/190/170; walls/player/HUD/actors preservados.

Ressalvas de tipagem dinâmica e duas representações tamanho/shape são manutenção futura; propriedades atuais conferidas. Instance shapes não local_to_scene são recursos exclusivos; runtime duplica antes de alterar, sem compartilhamento em sync. PlatformA herda220×24 do PackedScene, igual ao shape salvo; não precisa repetir default. Grok supõe possível frame visual inicial incorreto por queue_redraw no filho: redraw é enfileirado e o _ready do pai sincroniza antes do desenho normal, sem evidência de defeito atual. Não houve código alterado após congelamento.

## Evidências e limites
Entradas/saídas em review-input-r1.txt e *-r1.txt; hashes estado-r1-sha256.json, estado-pos-revisao.json e protegidos-sha256.json. Snapshots e log original em historico. Opus continua sem revisão. Não executar testes/Godot sem pedido explícito conforme AGENTS.md. Nenhum commit, push ou mudança de branch.

## Direção inicial dos dois inimigos
Usuário confirmou os placeholders atuais. GDD de Primeiro Andar e Direção Visual consultados no Notion; silhueta deve comunicar função antes de detalhes. Proposta, não decisão final do GDD: alvo estacionário como máquina de contenção larga/vertical e rebiteiro como robô estreito com ferramenta presa ao braço. Metal cinza quente/ferrugem/vermelho queimado, pontos de ameaça laranja, sem copiar antena/olhos ciano do protagonista. Manter collider72×96 alvo e46×64 rebiteiro; escala visual2× é recorte inicial. Rebiteiro prepara650ms/recupera800ms; ponto de boca éX±22,Y−36 mundo relativo aos pés. Futura produção: referência ImageGen alinhada ao idle/ambiente atual, reprodução Aseprite, poses temporizadas e integração depois do alinhamento. Nenhum sprite foi gerado ou integrado nesta correção.

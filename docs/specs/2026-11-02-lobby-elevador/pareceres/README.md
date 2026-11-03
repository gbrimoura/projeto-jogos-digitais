# Revisões — lobby e elevador

## Coordenação e baseline
Implementação única pelo subagente GPT-6 Luna xhigh; Fast/priority não confirmável pela interface. Preflight feito uma vez nesta tarefa: Cursor autenticado/modelos exatos, AGY Gemini/Opus exatos, OpenCode Go credenciado/Muse1.3Contributor exato. Valores anteriores e mudanças locais preservados em cópias binárias/hashes de historico/. Plano prospectivo foi congelado antes de produto; versões anteriores preservadas. Principal coordenou refinamentos e avaliou pareceres, sem pedir nova aprovação já concedida pelo usuário.

## Plano
Pacote plan-input.txt imutável e hash correspondente.
- Gemini3.8FlashHigh/AGYplan: exit0 REVIEWED, reforçou ownership da pausa, freeze da gameplay antes de trocar cena, resultado ALWAYS e latch/rearm. Integrados em contratos finais prospectivos antes do GO.
- MuseSpark1.3Contributor/OpenCodeplan xhigh: exit0 REVIEWED-NO-GO até apertar contratos. Principal fixou ordem clear/unpause/change, saída integral para rearmar, retângulo interno sugerido, rótulos de erro e escopo de5arquivos antes de implementar; avaliação do principal, não aprovação Muse fabricada.
- cursor-grok-4.6-xhigh-fast/Cursorplan: exit0/stdout vazio, sem parecer.
- claude-opus-5-5-high/AGYplan: exit3 quota429, sem parecer. Não substituído pelo OpusCursor nem vice-versa.

## Implementação estável
Principal corrigiu via mesmo implementador, com versões substituídas preservadas: piso visual top560 e paredes32 alinhados às colisões; atlas de chão não usa coluna3 de canos; ResultOverlay90 abaixo do fade100; texto de resultado bitmap2x e centralização no botão. Depois disso produtos congelados, entrada completa implementation-input.txt (79.202bytes) + hash, e entradas inlineA/B preservadas.

- Gemini3.8FlashHigh/AGYplan: tentativa inicial por stdin retornou exit2 de usoCLI, não parecer. Reenvio por leitura do pacote imutável: impl-gemini-file exit0 PASS, semP1/P2. Revisão estática, não prova parser/runtime; não adotamos afirmação absoluta de ausência de qualquer bug. Não executamos testes sugeridos no handoff.
- MuseSpark1.3Contributor/OpenCodeplan xhigh: primeira tentativa com arquivo anexo terminou exit0, porém bloqueou leitura restante de external_directory no modo não interativo; não conta como parecer. Nenhuma permissão desativada/liberada ou leitura contornada. Reenvio seguro como conteúdo autorizado inline em2blocos completos, sem ferramentas: A (Lobby+visual+cena+referências) exit0 PASS; B (métodos novos do Controller+dependências) exit0 PASS-WITH-NOTES. Avaliação abaixo.
- cursor-grok-4.6-xhigh-fast/Cursorplan: não concluiu em6min, árvore exclusiva da revisão encerrada pelo principal (3processos); stdout/stderr parciais e metadados em impl-grok*. Sem parecer; sem código de saída nativo concluído inventado e sem repetição automática em outro modelo.
- claude-opus-5-5-high/Cursorplan: execução de disponibilidade nesta tarefa retornou exit1 ActionRequiredError por quota até03/11/2026; stdout/stderr preservados como opus-cursor.*. Revisão obrigatória PENDENTE, sem substituição ou dispensa.

## Avaliação crítica das notas Muse
1. Os símbolos listados como P1 a conferir em trecho parcial existem no arquivo completo: _technical_error_pause_owned, _dismiss_technical_error, _show_legacy_game_over_screen, RoomTransition.clear_pending_snapshot e LOBBY_SCENE_PATH. Não houve símbolo ausente identificado.
2. A nota de ausência de queue_redraw explícito em relayout não exige alteração: a fonte configura e enfileira desenho em ready; Control atualiza item_rect_changed quando muda de tamanho e CanvasItem solicita redraw nesse caso. Referências primárias consultadas, sem execução local: [Control::_size_changed](https://github.com/godotengine/godot/blob/master/scene/gui/control.cpp) e [CanvasItem::item_rect_changed](https://github.com/godotengine/godot/blob/master/scene/main/canvas_item.cpp). A consulta ao upstream não equivale à validação do binário local4.7.
3. Morte no fluxo atual de Main fecha a oferta e libera sua própria pausa antes de finalizar a morte; _owned_reward_pause legado do Controller não é ativado no código atual. Preservamos ownership de pausa em vez de remover pausas globais arbitrárias.
4. O fade antigo é descartado junto com a cena. O lobby novo inicia com alpha0; a sequência implementada usa fade de saída, sem promessa de um fade de entrada adicional. A ausência deste segundo efeito não bloqueia o ciclo aprovado.
5. Velocidade anterior ao congelamento pode retornar após falha de viagem; é um detalhe de movimento no retry, que exige sair inteiramente da cabine. Não gera nova tentativa automática nem altera HP/build. Overdraw inferior dos tiles é só visual.

## Verificações e limites
Root conferiu fonte, referências/ordem de camadas, diff contra baseline e hashes dos5produtos (final-products.sha256.json). project.godot mudou somente run/main_scene. preservation-20.json confirma20/20arquivos críticos anteriores intactos (inclui RunRoot10salas, Main, Player, geração, upgrades e HUD). Sem Godot/import/testes/parser/linter/auditoria/simulação/produção de novos PNGs. Sem commit/push, troca de branch ou limpeza. Funcionamento e aparência em execução permanecem não confirmados.

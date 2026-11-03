# Plano prospectivo — portas, sinalização e passagem

Pedido: remover labels de entrada/saída das fases; após eliminar todos os inimigos indicar a saída por setas pixeladas; corrigir a aparência da travessia de uma porta aberta, que parece entrada no chão. Trabalho complexo de apresentação de portas em quatro direções, com preservação de transição e mudanças locais.

## Recorte autorizado

Luna read-only identifica os pontos de desenho e propõe escopo mínimo; depois único implementador gpt-6-luna xhigh por30min, Fast/priority não confirmável pela interface (informado). Root escreve documentação e coordena revisão, sem outro escritor simultâneo. Alterações limitadas a apresentação de ExitDoor/SideDoorVisual, helper visual novo se necessário e overrides de labels nas cenas das duas salas. Main/RunController/HUD, colisão, AI, HP, builds, seeds e swap transacional ficam protegidos. Se for necessário editar outro arquivo, delimitar antes.

Remover os textos de orientação espacial em todas as portas (Entrance, Exit, terminal), sem remover a estrutura do nó se leitores existentes precisarem dela. Não confundir mensagens técnicas de recuperação: manter falhas detalhadas nos overlays existentes, não apagá-las da lógica. Labels antigos podem permanecer como nós invisíveis/vazios para compatibilidade, sem renderizar sobre a fase.

Indicador pixelado âmbar/creme com contorno escuro da paleta existente, formado na grade inteira, sem antialias e sem rotação fracionária de textura. Somente saída de fato liberada mostra indicação; entrada, bloqueada, terminal e busy não apontam como atravessável. Reaparecer após falha recuperável se saída está novamente disponível. Direções LEFT/RIGHT/UP/DOWN vêm do descritor real, não da posição no viewport. Evitar piscar ou interpolar movimento fracionário; se animado, usar passos inteiros e pulso discreto lento. Não exigir novo ImageGen para ícone simples nativo em código, sem export bitmap.

Corrigir leitura do vão com fundo escuro atrás do personagem e moldura/soleira claramente distintas do piso. Não deslocar o CharacterBody, o sprite inteiro ou collider para maquiar problema. Não mudar normal/linha de cruzamento, offsets de portal/gate, física, token, fade, lock/retry. A saída vertical inferior deve parecer um alçapão aberto, não um tile sólido sobreposto ao personagem. O ajuste deve respeitar piso topo560, centro lateral496, vãos64×128 e hatch256×96, inclusive teto. Separar oclusão de profundidade e borda frontal se leitura confirmar necessidade; não pôr todo retângulo opaco à frente do player.

## Validação e governança

Baseline local antes de escrever, snapshot com .gdignore em histórico, preservar mudanças locais e UID/import gerados pelo editor. Não commit/push/troca de branch. Não executar Godot/importação, testes, parser, linter, audit ou QA nesta tarefa, conforme AGENTS. A abertura produtiva do editor na tarefa anterior não é autorização geral de testes. Revisão estática e inspeção de fontes são os critérios desta etapa; limite visual em runtime será declarado.

Préflight único salvo: Gemini3.8High/Opus5.5High via AGY, Cursor autenticado com IDs exatos claude-opus-5-5-high e cursor-grok-4.6-xhigh-fast, OpenCodeGo/Musexhigh disponíveis no catálogo. Grok4.6 segue AGENTS global explicitamente colado pelo usuário e prevalece sobre4.7 local. Plano completo por Gemini/Grok/Muse/OpusAGY, código estável por Gemini/Grok/Muse/OpusCursor; quota/timeout/saída vazia não contam como aprovação. Revisão10min, handoffstdout sem relatórios extras de agentes.

## Contrato fechado após diagnóstico — antes da implementação

Luna confirmou como causa visual plausível (sem afirmar certeza de runtime) o desenho vertical inteiro em z_index1: DOWN cobre y556..652 enquanto o Player cruza com pés642. Ajuste é visual; não mudar trigger por centro, gate, colisão, piso ou geração. Na abertura, o fundo do poço deve ficar atrás do ator e a moldura deve mostrar borda/parede interna clara sem preencher a abertura à frente. O chão permanece em560, hatch inferior em604 e UP arte em16. As laterais mantêm soleira alinhada ao piso. Usar orientação explícita do portal, não deduzir somente flip_h; standalone deduzLEFT/RIGHT de flip_h e managed fornece direção.

Escopo write exclusivo: scripts/world/exit_door.gd, scripts/world/side_door_visual.gd, scenes/exit_door.tscn e somente overrides DoorLabel em scenes/main.tscn e scenes/second_room.tscn. Novo helper visual scripts/world/exit_direction_indicator.gd ou cena auxiliar apenas se simplificar; preferível desenho nativo no SideDoorVisual já existente. Main/RunController/topology/floorvisual/player/HUD/engineconfig/arte permanecem protegidos. Os dois scenes de sala só podem ter mudanças de Label.

Manter DoorLabel como nó vazio/invisível para preservar índices/overrides locais, e torná-lo opcional na atualização (o desenho não depende da label). Remover as strings de ENTRADA/SAÍDA e os overrides visíveis. Todas as apresentações da porta, incluindo terminal/busy, deixam de desenhar texto sobre a fase. Falhas técnicas gerenciadas já têm overlay; em standalone, encaminhar mensagem de report_transition_failure ao StatusLabel existente da CombatRoom, se houver, sem acrescentar label no mundo nem mexer no controlador. Essa escrita é só canal de apresentação de erro, mantendo mensagem/retentativa e lógica originais.

SideDoorVisual recebe bool show_exit_indicator e direção cardinal. ExitDoor calcula bool apenas se door_role==Exit, _room_is_cleared, não _terminal_complete, não _transition_busy; falha com retry continua apontando quando voltar a atravessável. is_open continua sendo apenas _room_is_cleared para portais disponíveis; busy mantém vão aberto, mas esconde seta. Entrance/terminal/bloqueada nunca mostram seta. Usar setters/métodos puros de apresentação; não rearmar crossing ao atualizar desenho.

Seta âmbar/creme com contorno, desenho em retângulos de pixels inteiros e transform cardinal inteiro; sem texto E, sem alpha pulsante/rotação float. Indicador posicionado no interior da sala antes do vão, alinhado à normal; variantes claras UP/DOWN eLEFT/RIGHT, sem ficar sob piso/teto, sem seguirflip_hduasvezes. Se animado só deslocamento inteiro e pulso discreto lento; animação não é necessária ao aceite. Paleta existente. Não criar novo bitmap/import para esse ícone geométrico.

Conservar todas as funções físicas/travessia/estado, retornos de erro e ordem de sinais/set_deferred. Não mudar fade; corrigir profundidade de desenho e abertura. Root revisará diferenças com baseline local, fontes estáveis terão revisão pelos quatro modelos exatos. Nenhuma execução de engine/testes autorizada nesta rodada; inspeção é estática.

## Liberação prospectiva de produção R1

Gemini e Muse R1 concluíram: sem bloqueio de plano. Principal aceita P2 Gemini de separar CanvasItems para profundidade/moldura/indicador e impedir flip duplo; implementador receberá as notas antes da escrita. Pode acrescentar helper scripts/world/door_foreground_visual.gd e/ou exit_direction_indicator.gd, se separar passagens de desenho de forma simples; somente a cena compartilhada instancia esses nós. Os cinco arquivos existentes e restrições de override seguem iguais. Não gerar novos bitmaps ou alterar arte do player.

OpusAGY/Grok de plano continuam lendo exclusivamente o pacote R1 congelado. Achados concretos posteriores serão avaliados antes de fechar entrega; nenhum parecer pendente conta como aprovação. Root libera único Luna writer por20min, escopo acima, e para de escrever durante autoria. Baseline dos arquivos existentes já salvo; revisão de implementação terá snapshot próprio e quatro solicitações exatas. Sem Godot/testes/audit/Git mutation.

## Correção prospectiva R2 — posição da seta vertical

Root leu o lote R1 congelado. Setas UP/DOWN estão em x=portal_offset+144, mas o vão acaba em offset+128: apontam para teto/piso sólido ao lado. Corrigir x ao centro do vão, deslocamento local0. UP mantém y=linha32+88=120, ponta84 dentro da sala. DOWN usa y=linha604-96=508, ponta544 acima do piso560. LEFT/RIGHT mantêm deslocamento48 para dentro e altura96 sobrecentro496. Não alterar cruzamento/gate/colisão/fade.

Liberar mesmo Luna único writer5min SOMENTE _indicator_offset em scripts/world/exit_door.gd. R1 salvo antes. Depois congelar R2 e revisão completa7arquivos. Sem engine/testes/Git.

Incidente: apply_patch do implementador criou arquivo vazio fora do repo, dentro da pasta de trabalho pai, no caminho C:/Users/danie/Documents/ChatGPT/TEC - Jogos/TEC - Jogos/projeto-jogos-digitais/scripts/world/exit_direction_indicator.gd. A tentativa de limpeza desse único arquivo pelo root foi rejeitada automaticamente antes da execução (CreateProcess Rejected, blocked by policy, sem motivo específico). Todo comando combinado foi rejeitado, portanto snapshot/plano dessa tentativa também não executaram; estas operações não destrutivas são realizadas agora separadamente. Não repetir remoção, movimentar ou tentar contornar. O residual permanece fora do projeto, não usado. O helper real está no repo correto.

Ajustes de contrato dos pareceres R1 foram enviados prospectivamente pelo chat durante autoria: duas camadas absolutas -1/+1, fundo visível no recorte real do piso, direção portal_direction, preservação de índices, leitor de label só ExitDoor e canal de status standalone. Reconfirmação Opus AGY R2 falhou429 RESOURCE_EXHAUSTED (quotaindividual, reset74h55m), sem parecer, não substituído. Código estável vai aos revisores exatos da implementação.

## Correção prospectiva R3 — espelhamento do fundo

Gemini e Muse de implementação R2 confirmaram os contratos funcionais e identificaram a mesma inconsistência cosmética: SideDoorVisual exporta flip_h mas o fundo não espelha as faixas de sombra/cobre, embora a moldura espelhe. Principal aceita o ajuste para coerência da cavidade LEFT com a moldura, sem tocar seta/cardinal.

Autorizar mesmo Luna único writer5min EXCLUSIVO scripts/world/side_door_visual.gd: setter flip_h com queue_redraw; no _draw aberto aplicar reflexão horizontal(−1,1), mantendo ângulo0 e restaurando transform no final. Não alterar retângulos, paleta, abertura, z, indicador ou cenas. Reflexão exata inteira, sem rotação fracionária. SnapshotR2 já preservado. Ao terminar congelarR3; revisão delta de poucas linhas pelos revisores disponíveis, sem repetir quota conhecida do Opus Cursor. Sem testes/Godot/Git/limpeza.

Grok R2 encerrou exit0 com stdout vazio, sem parecer utilizável. Opus Cursor R2 exit1 confirmou quota e erro secundário do updater promote-lock, preservados no stderr; não há parecer de implementação desse modelo e não foi substituído pelo plano AGY.

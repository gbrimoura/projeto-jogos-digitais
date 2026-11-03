# Plano prospectivo — compactar HUD

01/11/2026. Usuário relata HUD grande obstruindo a sala. Refinamento da interface existente, sem identidade/arte nova. Aplicar princípios de Impeccable/pixel-art: herdar o visual aprovado, reduzir massa e clutter, preservar leitura e pixels inteiros. Contexto da skill já carregado nesta conversa; não executar detectores/QA nem engine, conforme AGENTS.

## Escopo de implementação

Único GPT-6 Luna xhigh, timeout10min, Fast/priority não confirmável pela interface. Escrever SOMENTE scripts/ui/hud/hud_root.gd, scripts/ui/hud/run_hud_bridge.gd e scenes/ui/hud/hud_root.tscn. Preservar atual código local do bridge (inclusive visible_origin no transform e demais correções já presentes), lifecycle, dados HP/dash/alvo/progresso, pausa/fallback/mouseignore. Sem mudanças a gameplay, portas, gerador, Main/RunController, project.godot, sprites ou assets do kit. Baseline local copiado antes.

Objetivo é reduzir os módulos sem encolher toda a interface para o centro da tela. Trocar referência de ajuste físico da bridge de576x324 para960x540, mantendo floor do fit e escala FINAL inteira, compensação de stretch, origem final alinhada. Em1920x1080 escala final passa3→2: painéis144x40 passam432x120→288x80, redução33%linear e56%deárea. Em1152x648 escala2→1;4K escala6→4. Usar min1, sem escala fracionária final ou textura suavizada. Referência nova pode ser export configurável, com clamp seguro e cache atualizado quando muda.

A raiz visual deve receber tamanho lógico disponível calculado em pixels finais/escala inteira, e ancorar vida/dash no canto esquerdo, alvo central superior, salas/instrumento no canto direito. Usar toda área da viewport, não centralizar um canvas1152físico que faria os painéis invadirem o centro. RootControl min576x324 para telas pequenas; tamanho de estudo/editor960x540. Posições arredondadas, sem mexer em câmera/stretchglobal. Tamanhos dos painéis não mudam, somente a escala da camada e o layout. Preservar campos de ajuste atuais como offsets da referência576 ou documentar semântica dos anchors sem quebrar uso existente. Alvo/coluna direita devem considerar escala do módulo, pelo menos default1 e configuração2 se já exposta. O conteúdo continua no mesmo CanvasLayer, abaixo dos overlays e escondido na pausa.

Ocultar clutter: opção show_debug_details=false na raiz. Seed/contador de inimigos e build textual de diagnóstico ficam fora da apresentação padrão; as fontes e dados continuam disponíveis no modo debug. set_status recebe texto multiline atual: modo normal mostra só primeira linha sem perder mensagens úteis de área limpa/saída/falha; ENCONTRO ATIVO/PREPARANDO ENCONTRO podem ficar ocultos como redundantes. BuildText só visível debug. Status normal discreto, no rodapé com padding8, uma linha, sem atravessar painéis; debug mantém3linhas/rodapé. Não ocultar HP/dash/alvo/progresso nem mensagens/controles dos overlays técnicos e recompensas. Instrumento continua conceito oculto por default.

## Verificação e revisão

Tarefa escopada de layout, sem plano arquitetural novo; pós-implementação estável receberá quatro revisões somente leitura exatas: Gemini3.8High/AGY, Grok cursor-grok-4.6-xhigh-fast/Cursor (AGENTS global do usuário prevalece sobre4.7 local), Muse1.3Contributor/OpenCode xhigh e Opus claude-opus-5-5-high/Cursor. Préflight uma vez nesta tarefa; quota/saída vazia não contam como parecer. Revisão10min, stdout/stderr/exit preservados. Sem testes, Godot/importação, parser/lint/audit/detector, Git mutation, commit/push ou mudança de branch.

Principal fará leitura dos tamanhos, anchors e fórmulas em conjunto, preservação por hashes e coordenação de correções, sem alegar captura runtime. Handoffstdout STATUS/SUMMARY/CHANGED_FILES/TESTS/RISKS/NEXT_STEP. Nenhuma entrevista de nova identidade necessária: usuário já aprovou arte e agora pediu reduzir obstrução.

## Ajuste prospectivo R2 antes da revisão externa

Principal leu o lote R1. Default960x540 e anchors cumprem redução; foi identificada uma proteção insuficiente no export scale_reference_size: clamp1 permite configuração acidental1x1 produzir escala final1080 e Root mínimo576x324 enorme fora da tela. Fixar mínimo da referência em576x324, o mínimo nativo real da raiz, tanto no setter quanto no guard da fórmula. Valores normais960x540 não mudam. Também arredondar final_origin depois de calcular visible_origin para manter origem em pixel final inteiro, preservando a translação do viewport.

Mesmo Luna único escritor3min SOMENTE scripts/ui/hud/run_hud_bridge.gd nessas expressões. Não alterar layout/dados/lifecycle ou outros arquivos. SnapshotR1 preservado, R2 será congelado e receberá as quatro revisões de implementação. Nenhum teste/engine.

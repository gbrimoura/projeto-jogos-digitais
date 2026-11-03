# Plano — fullscreen padrão e direção inicial de HUD

**Estado:** implementação estática registrada; pareceres pendentes.

## Objetivo e limites

Iniciar o jogo em fullscreen padrão, com alvo de janela 1920×1080 e viewport lógico de 1152×648 para preservar o espaço de coordenadas das salas atuais, que não usam Camera2D. Manter a proporção 16:9. Não alterar cenas, assets, regras de jogo ou HUD nesta etapa.

O modo fullscreen 3 (fullscreen convencional, não exclusivo) ocupa o monitor na resolução corrente do sistema. Os overrides 1920×1080 descrevem a dimensão da janela inicial; não mudam a resolução configurada no sistema operacional.

## Proposta de configuração

- display/window/size/viewport_width=1152 e viewport_height=648.
- display/window/size/window_width_override=1920 e window_height_override=1080.
- display/window/size/mode=3.
- display/window/stretch/mode="canvas_items" e display/window/stretch/aspect="keep".

A proporção entre viewport e alvo de janela é 16:9, com escala 5/3. A documentação do Godot recomenda viewport para jogos com estética pixel art; canvas_items é mantido nesta etapa para preservar o modo já usado pelo projeto. Registrar e avaliar visualmente a possível suavização/artefato de escala em trabalho posterior.

## Direção inicial de HUD

A direção conceitual está em spec.md. Ela não autoriza nem inclui implementação da HUD, ajustes de cenas ou definição das regras econômicas que o GDD deixa pendentes.

## Preservação e validação

Snapshot anterior à edição: historico/project.godot.pre-fullscreen; SHA-256: 03CCF4541ED2B21FDBB63DE735B35984FE706A4DA11FFD3A768184FA9B71A4CC.
Hash SHA-256 final de project.godot: C580893946F6D8CE92C6E38E342FD7395A3E168CD837B01954F0A00734180DAD.
Diff semântico: overrides anteriores 1152×648 movidos para viewport_width/height; overrides de janela agora são 1920×1080; adicionado mode=3 e aspect=keep; stretch/mode continua canvas_items.
Diff textual congelado em historico/project.godot.fullscreen.diff.

Validar apenas por leitura estática do diff e dos valores finais. Não executar Godot nem testes. O agente principal coordena os pareceres e atualiza o índice docs/README.md.
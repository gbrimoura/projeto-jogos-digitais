# Especificação — fullscreen padrão e direção inicial de HUD

**Estado:** configuração estática aplicada; revisões pendentes. HUD é somente direção conceitual.

## Display

| Chave | Valor | Efeito pretendido |
|---|---:|---|
| display/window/size/viewport_width | 1152 | Preserva a largura lógica atual das salas. |
| display/window/size/viewport_height | 648 | Preserva a altura lógica atual das salas. |
| display/window/size/window_width_override | 1920 | Alvo de tamanho da janela inicial quando o jogo estiver em janela. |
| display/window/size/window_height_override | 1080 | Alvo de tamanho da janela inicial quando o jogo estiver em janela. |
| display/window/size/mode | 3 | Inicia no modo WINDOW_MODE_FULLSCREEN, sem fullscreen exclusivo. |
| display/window/stretch/mode | "canvas_items" | Mantém o modo de stretch 2D que o projeto já usa. |
| display/window/stretch/aspect | "keep" | Preserva 16:9; outras proporções podem receber barras. |

O modo fullscreen ocupa a resolução corrente/nativa do monitor. O alvo 1920×1080 e seus overrides não forçam uma mudança no modo de vídeo do sistema operacional. O viewport continua em 1152×648 para manter as coordenadas de desenho existentes.

A escala de 1152×648 para 1920×1080 é 5/3. A documentação oficial do Godot recomenda stretch viewport para estética pixel art e alerta que canvas_items pode gerar artefatos porque desenha 2D na resolução-alvo. Este incremento conserva canvas_items, já existente no projeto e explicitamente delimitado para esta mudança; a nitidez precisa de avaliação visual em execução futura. Não foi feita avaliação em runtime. Fonte da semântica das configurações: [ProjectSettings do Godot](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html).

## HUD — direção inicial, não implementada

O GDD04 §9 pede uma HUD discreta com slots, componentes e cargas, além de duas moedas distintas. O protótipo atual repete elementos de HUD entre RunRoot e CombatRoom; a proposta futura deve apresentar esses dados uma vez, com hierarquia simples:

- No alto à esquerda: vida em segmentos com aparência mecânica; três ícones compactos — um ícone de bola que varia entre pronta, em voo e em retorno, mais ícones de rebate e dash com suas recargas reais.
- No alto à direita: andar/sala e inimigos, em tratamento discreto.
- Mostrar o aviso transitório “ÁREA LIMPA” quando a sala for concluída; ele não representa uma área vazia permanente.
- Build compacta com apenas os itens adquiridos; sem slots vazios fictícios.
- Prever duas moedas visualmente distintas para uma etapa futura, quando a economia estiver implementada; elas não entram na primeira versão da HUD.

Direção visual sugerida: metal, navy, cobre e creme, com formas arredondadas de linguagem cartoon. A próxima etapa precisa resolver a duplicação existente e detalhar os componentes autorizados pelo GDD. Nenhum elemento de HUD ou regra de jogo foi alterado nesta etapa.

## Fora do escopo

Cenas, scripts, assets, câmera, layout de sala, gameplay, economia e resolução de vídeo do sistema operacional permanecem fora desta alteração. Não executar Godot ou testes nesta etapa.
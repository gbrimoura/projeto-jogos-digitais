# Especificação de integração

A referência de arte é assets/ui/hud_caldeira_v1, contrato e metadados da rodada Aseprite. Os valores 3/5 e 4/6 da prévia são exemplos e jamais devem ficar embutidos na HUD runtime. O usuário escolheu vida em barra contínua com valores, cooldown em relógio cinza com frase, inimigo próximo da mira em painel fixo e contador de salas. Aceleração ainda não tem regra de gameplay definida.

Aceite estático: componentes independentes e nomeados; configuração de posição/escala; raiz sem autoridade sobre gameplay; valores reais e limpeza de referências; não duplicar HUD legada; erros/transições/rewards preservados; recursos no caminho correto; ausência de execução não solicitada. Standalone e run gerenciada devem continuar utilizáveis.

APIs oficiais consultadas: https://docs.godotengine.org/en/stable/classes/class_ninepatchrect.html (margens e cantos), https://docs.godotengine.org/en/stable/classes/class_canvasitem.html (desenho em _draw e nearest), https://docs.godotengine.org/en/stable/classes/class_texture2d.html (regiões de textura). O projeto declara Godot4.7. Nenhum upgrade de engine será feito.

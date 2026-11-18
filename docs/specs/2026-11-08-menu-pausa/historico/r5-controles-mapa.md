# Incremento visual do menu de pausa — 15/11/2026

O Painel de Caldeira mostra controles em keycaps desenhadas em pixel art, inclusive a tecla contextual R. As teclas de direção usam setas de quatro pixels, e o mouse destaca a zona de mira, clique esquerdo ou direito para cada ação.

Na run, a lateral apresenta o mapa do andar atual com coordenadas fornecidas pelos descritores procedurais. As ligações e salas anteriores aparecem em ciano, e a sala ativa em âmbar. Salas futuras não aparecem. O lobby mantém os controles em uma grade mais ampla.

A implementação altera scripts/ui/pause/pause_menu.gd e acrescenta get_pause_minimap_data() a scripts/world/run_controller.gd. Validação de runtime não realizada.

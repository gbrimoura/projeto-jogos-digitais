# Especificação — HUD compacta

Painéis nativos continuam Player144x40, Dash144x40, Alvo144x40 e Salas84x36. Fonte5x11, avanço6. A redução desejada é da escala e ocupação na tela, sem rasterizar menor ou borrar arte.

No fullscreen1920x1080, referência960x540 produz escala física2, raiz disponível960x540: vida(8,8), dash(8,52), alvo centrado x408, salas x868. Esses são valores derivados de padding8 e tamanhos atuais, não uma resolução global nova. Emoutrasjanelas calcular anchors pelo espaço real. Mensagens úteis permanecem, diagnósticos são opt-in, e os invariantes de pausa/binding/callbacks/HP estão fora do escopo de mudança.

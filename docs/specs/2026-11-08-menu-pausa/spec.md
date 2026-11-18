# Especificação prospectiva

ESC abre o menu no lobby e na run quando disponíveis, e retorna de páginas ou confirmações. A primeira ação é retomar, com os controles de teclado e mouse visíveis ao abrir. Outras pausas, resultados e transições mantêm prioridade. A confirmação de saída alerta sobre a perda da tentativa e começa com foco em cancelar.

Configurações de escala gráfica, tela cheia ou janela, tamanho de janela, VSync, volume e mudo persistem em ConfigFile próprio. Em tela cheia usa-se o monitor; a resolução escolhida refere-se à janela e pode ser limitada à área utilizável. O comando Limpar save aparece indisponível para o futuro progresso permanente; nenhum histórico, estatística ou arquivo de progresso é criado ou excluído.

A navegação aceita teclado e mouse. A duração pretendida de uma tentativa é aproximadamente 20 minutos, sem temporizador imposto. Sem testes ou execução do Godot nesta tarefa.

## Incremento de controles e minimapa — 15/11/2026

A página CONTROLES apresenta cada comando com teclas em keycaps pixeladas e um desenho de mouse com o botão usado realçado. O atalho contextual R também aparece em keycap. O mapa da run desenha as coordenadas reais da rota procedural do andar atual, inclusive trechos verticais. Ele mostra somente salas já visitadas, numeradas, com a sala atual em destaque, e se atualiza na próxima pausa. No lobby, o espaço pode ser usado pelos controles sem mapa. Os marcadores e conexões seguem a paleta do Painel de Caldeira.
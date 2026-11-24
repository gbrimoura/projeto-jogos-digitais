# Supervisor-Caldeira

- Encontro único no fim do primeiro andar. Arena fixa, sem sorteio de plataforma, decoração, inimigo, rota interna, prop ou orientação de saída.
- Máquina suspensa com dois pistões, manômetro, olhos e escotilha de pressão. As posições da colisão de teto, chão e plataformas permanecem iguais durante o encontro. O estado da carcaça muda com o combate.
- Vida inicial de 22 e transição no limiar 11. Valores provisórios de balanceamento. Fase 1 alterna mira de rebites e coluna de vapor. Fase 2 alterna purga baixa e alta, com rajadas. O retângulo de dano e o aviso são derivados da mesma região. Uma purga causa no máximo um dano por ativação. As válvulas mudam a segurança da arena sem mover os sólidos.
- A janela anunciada de vulnerabilidade aceita dano normal da bola. Rebites redirecionados para o chefe também causam dano e ajudam a abrir o núcleo. A rebatida é uma vantagem opcional.
- Grupo de inimigo e sinal de derrota seguem o contrato do CombatRoom. Ataques ficam suspensos com a pausa e são cancelados ao trocar de fase ou derrotar o chefe. A recompensa e a saída de combate seguem o fluxo da run existente.

- Revisão de arte e movimento. Atlas de 16 poses, visor e cores da fábrica, deslocamento em trilho e animações sincronizadas à mira, ao disparo e às purgas. [Implementação e validação](historico/movimento-e-animacao.md).
- As purgas têm carga nas bordas e descarga em faixas de vapor. O chefe chama até um Cospe-Rebite por fase, sinaliza a chegada e tenta novamente se o ponto estiver bloqueado. [Implementação e validação](historico/purgas-e-reforcos.md).

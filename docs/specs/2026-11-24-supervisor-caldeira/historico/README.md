# Validação do Supervisor-Caldeira

O Godot 4.7.2 foi executado na cópia isolada autorizada em 24/11/2026. A importação registrou o aviso preexistente de UID duplicado entre `scenes/main.tscn` e uma cena de referência do cenário.

- Seeds `42`, `4162699858` e `20261124`. Os descritores procedurais diferem. O piso, as duas plataformas, a posição inicial, o chefe e a direção da porta coincidem.
- 23 verificações por seed. O pulo básico alcança a plataforma. A bola física acerta o núcleo aberto. Um rebite físico redirecionado atinge o chefe. Um golpe forte para no limiar da fase 2 e a porta continua trancada. A purga baixa poupa a plataforma, e a purga alta acerta quem permanece sobre ela. Derrotar o chefe encerra os riscos, oferece a recompensa e permite sair.
- A run roteirizada da seed `42` percorreu as 13 etapas, incluindo as duas lojas, a luta em duas fases, a vitória e o retorno ao lobby. Ela usou assistência de combate para se concentrar na progressão.
- Conferência de viewport 1920×1080 em execução com captura de início, transição, purga baixa e vitória. A barra do chefe fica na HUD.
- Valores de vida, cadência e tempo de abertura são provisórios. O desafio ainda precisa de avaliação em jogo manual com builds distintas.
- Verificação complementar de exposição no piso. A purga baixa reduz 1 ponto de vida do jogador no chão. A purga alta preserva o jogador no chão.

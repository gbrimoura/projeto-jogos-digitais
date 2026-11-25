# Primeiro chefe da fábrica

Consulta de design ao Claude Opus 5.5 High, via Claude Code, antes da integração. Objetivo de validar o Supervisor-Chefe com arena fixa, redirecionamento e mudança de espaço seguro.

1. Criar uma arena autoral própria e ligá-la à vaga de chefe do RunController. A rota procedural entrega o jogador por um elevador fora de cena. Spawn, piso, plataformas, arte, chefe e porta direita têm posições fixas.
2. Usar a luta em duas fases do Supervisor-Caldeira. A fase inicial alterna rajadas rebatíveis com purga em coluna. A segunda troca o espaço de fuga para o plano vertical. A transição interrompe o ataque atual. O rebite devolvido favorece uma abertura, e a bola tem janelas previsíveis para vencer sozinha.
3. Reusar CombatRoom, Player, HostileRivet, recompensas e avanço da run. Descartar dano excedente apenas na passagem entre fases e preservar vida e build da run.
4. Criar sprite autoral de caldeira suspensa, com carcaça fechada, núcleo aberto e blindagem danificada. Integrar sala de pressão própria, aviso sonoro e retrato local.
5. Com autorização do usuário, conferir numa cópia isolada. Comparar seeds, alcançar a arena pelo fluxo real, cobrir as duas fases, ataque telegrafado, retorno do projétil, derrota da unidade e vitória.


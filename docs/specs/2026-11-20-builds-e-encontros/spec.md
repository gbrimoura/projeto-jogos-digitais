# Especificação · Combustão, Fragmentação e pressão dos encontros

## Cartas novas

| Família | Carta | Requisito | Efeito do recorte |
| --- | --- | --- | --- |
| Combustão | Brasa Persistente | Bola Incandescente | Estende em 0,25 s o tempo das brasas da bola principal. |
| Combustão | Fornalha | Bola Incandescente | Rastro da bola principal causa 2 de dano por inimigo em cada voo. |
| Fragmentação | Leque de Estilhaços | Bola Fragmentária | Expande cada braço da divisão de aproximadamente 23° para 40°. |
| Fragmentação | Núcleo de Estilhaços | Bola Fragmentária | Aumenta cada fragmento de 1 para 2 de dano direto. |
| Fusão | Chuva de Brasas | Bola Incandescente e Bola Fragmentária | Os dois fragmentos deixam rastros breves de fogo de 1 de dano por inimigo. |

As cinco especializações têm um nível. As cartas-base e os boosts atuais mantêm seus caps. Pré-requisitos usam IDs persistidos e são aplicados pelo catálogo. A fusão não aumenta o total de fragmentos, não se propaga aos disparos derivados e não transfere Fornalha para os fragmentos. Combustão e Fragmentação continuam combináveis com o catálogo original em runs em que o jogador escolher outras cartas.

## Seleção e estado

- `UpgradeCatalog` monta até três opções distintas. Reserva de família só se aplica à primeira oferta de recompensa ou quando há pelo menos uma continuação elegível. A Forja Magnética ocupa a primeira vaga quando elegível. A continuação ou a carta inicial ocupa no máximo uma vaga e usa os pesos de raridade com desempate pela seed. As vagas restantes preservam variedade entre cartas novas e evoluções quando ambas existem e preenchem o restante pelo sorteio ponderado. A loja mantém seu sorteio sem reserva de família e aplica os mesmos pré-requisitos.
- `RunBuild` continua representando níveis por ID. A mesma regra de prerrequisito deve proteger listagem e confirmação. Snapshots anteriores com IDs novos ausentes começam com níveis zero.
- `BallLauncher` fixa os efeitos no `ProjectileConfig` por lançamento. `RicochetBall` limita à primeira colisão no cenário e aos dois fragmentos já previstos. Spawn de fragmento e dano de rastro continuam sujeitos às travas de fim de sala.

## Encontros

| Combates | O que tentar |
| --- | --- |
| 1–2 | Tranca-Lata e Cospe-Rebite dos pontos autorais validados. |
| 3–6 | Dupla original e até um reforço, conforme encaixe seguro. |
| 7–10 | Dupla original, até um reforço e chance de 60% de tentar outro. |

A tentativa adicional respeita distâncias mínimas de 275 px da entrada e 150 px entre posições de atiradores. Um apoio pode receber mais de um somente se houver espaço real entre os pontos válidos. A lista de apoios é ordenada para manter a escolha por seed. O último encontro, lojas e cenas de desenvolvimento mantêm a composição dedicada. Cada unidade recebe o nível do descritor; contagem, derrota e sucata continuam em `CombatRoom`.

O Cospe-Rebite usa, por consulta à mesma sala, a presença de outro Cospe-Rebite em preparo como condição para ceder o aviso. A espera é recalculada conforme os estados, sem dependência de lock persistente. Testa um ângulo de tiro dentro dos limites do apoio, inclusive fora do alcance atual. Ao encontrar linha de tiro, estima a posição horizontal do alvo 0,32 s à frente, com deslocamento de até 66 px, e trava a direção apenas depois de conferir alcance e linha de visão. A abertura do ataque continua sinalizada. O Tranca-Lata estima a separação no fim do preparo usando a velocidade atual do jogador, limitada ao desvio que cabe no raio do golpe. Reavalia a referência viva antes de encaminhá-la para funções tipadas.

## Critérios de aceite

- A mesma seed e histórico de escolhas produzem as mesmas ofertas e composições.
- É possível iniciar e aprofundar as duas famílias, ou convertê-las em fusão, durante os dez combates.
- A primeira carta de família aparece cedo. Caps, compras, recuperação da run e uma seleção por recompensa continuam válidos.
- Encontros intermediários ou finais usam mais corpos quando o layout permite, com atiradores alternando a preparação. A saída só abre depois da última eliminação e da recompensa.
- A área de golpe, o rebite, fogo e os fragmentos continuam legíveis e as fases do ataque aparecem antes de aplicar dano.

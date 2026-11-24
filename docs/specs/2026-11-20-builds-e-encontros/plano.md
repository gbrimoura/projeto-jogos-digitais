# Plano de builds e encontros da fábrica

Base de gameplay: `c417614`, integrada à main em `d6930cd`.
Escopo: aprofundar Combustão e Fragmentação e aumentar a pressão das salas com Tranca-Lata e Cospe-Rebite. Esta rodada usa os recursos visuais das famílias existentes. Magnetismo e Forja Magnética permanecem disponíveis.

## Frente 1 · Progressão com famílias

1. Dar continuidade às duas cartas iniciais com duas especializações independentes por família e uma fusão entre elas. Reusar IDs e tetos existentes, inventário, aquisição, apresentação e snapshot.
2. Reservar uma vaga da primeira recompensa de sala para uma das duas cartas iniciais, escolhida pela seed. Em recompensas posteriores, reservar uma vaga para uma continuação desbloqueada de uma família já iniciada. Preservar espaço para ofertas de outras famílias e para a Forja Magnética já elegível.
3. Aplicar os efeitos no snapshot do lançamento e no ciclo de colisão já utilizado. Manter teto de fragmentos, trilhas curtas e frequência de dano limitada para preservar leitura e desempenho.
4. Usar títulos, descrições e tópicos curtos em PT-BR. Continuar aplicando prerrequisitos na aquisição direta e na geração da loja. As primeiras cartas continuam disponíveis sem pré-requisitos.

## Frente 2 · Densidade e decisão inimiga

1. Manter os dois inimigos originais nas salas comuns. Nas etapas intermediárias, tentar um reforço. No fim do andar, sortear a tentativa de um segundo reforço, com redução natural quando o mapa não oferecer apoio seguro.
2. Reusar validação de plataformas, margem de travessia e distâncias entre unidades. Considerar espaço já ocupado por reforços, ordenando os apoios para manter o resultado estável pela seed.
3. Ampliar a capacidade do Cospe-Rebite de buscar linha de tiro no seu apoio e variar a direção de aproximação. Permitir um único aviso de rebite por vez na sala. Enquanto aguarda, o atirador pode continuar procurando ângulo. A regra de pressão a distância preserva o aviso antes do disparo e a direção travada.
4. Manter a navegação por plataformas do Tranca-Lata, reduzir situações em que desiste de perseguir por uma referência obsoleta e usar a velocidade real de fuga do jogador ao avaliar se vale iniciar o golpe. A área de dano e a checagem de linha de visão continuam explícitas.

## Sequência de validação

- Cartas e loja: ofertas sem duplicação, teto e pré-requisitos respeitados, continuação elegível aparece sem eliminar a opção de trocar de direção, compras incompatíveis recusadas.
- Projéteis: progressão de cada família, fusão com exatamente dois fragmentos, dano aceito uma vez por inimigo e rastro por projétil, contato bloqueado por geometria e limpeza na transição.
- Encontros: comparar início, meio e fim em pelo menos três seeds, com rotas laterais e verticais. Verificar apoio, contagem, distância da entrada, visibilidade dos inimigos, pausa, crédito de sucata e liberação da saída.
- IA: conferir perseguição em desnível, disparo após reposicionamento, alternância de avisos com dois atiradores e espaço para o jogador reagir.
- Balanceamento: observar duração dos encontros e facilidade de completar uma build em dez combates antes de fixar números da campanha.

Os números da especificação são parâmetros do primeiro recorte. A execução de Godot/playtest depende da autorização de teste exigida pelo AGENTS.md.

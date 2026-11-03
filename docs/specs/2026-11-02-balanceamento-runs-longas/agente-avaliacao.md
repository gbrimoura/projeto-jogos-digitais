# Agente de avaliação por reforço — próxima fase, não implementado/treinado

Pedido: agente que joga para avaliar balanceamento, confirmado pelo usuário em02/11. Esta etapa de balanceamento não executa Godot, instala ML nem lança treino. Os contratos abaixo deixam a integração concreta para uma fase própria; não são uma promessa de compatibilidade ou resultados.

## Tecnologia candidata
Godot RL Agents é um projeto independente que integra Godot e backends de RL; seu guia indica Stable-Baselines3 como caminho para Windows. Verificar a revisão do addon e a compatibilidade exata com o Godot4.7 do projeto antes de instalar. PPO é candidato inicial pela ação discreta proposta, não escolha validada por experimento. Fontes primárias: [repositório Godot RL Agents](https://github.com/edbeeching/godot_rl_agents), [guia SB3 do projeto](https://github.com/edbeeching/godot_rl_agents/blob/main/docs/ADV_STABLE_BASELINES_3.md).

## Ambiente a construir
Adapter isolado e opt-in de avaliação, sem mudar a IA inimiga ou os controles do jogo normal. Reset cria run nova com seed e perfil explícitos, limpa jogador/build/bola/projéteis/pausas/transições e espera primeira sala válida. Step avança um número fixo de ticks de física, com decisões e reação limitadas para comparar com jogadores. Deve usar as mesmas regras de movimento, cooldown, rebatida e bloqueio de lançamento que o jogador; nunca teletransportar, anular cooldown, alterar HP ou forçar saída durante a avaliação.

Observações estruturadas propostas: posição/velocidade/vida máxima e atual do jogador, dash/cooldowns e estado da bola; posições/vidas/fases de preparação visíveis dos inimigos; ameaças/projéteis próximos; geometria local visível/plataformas/aberturas; estado da sala e opções da oferta. Normalizar e usar máscaras para objetos ausentes; evitar futuro da geração/RNG ou informação oculta. O tamanho de observação e limites de entidades precisam ser definidos pelo adapter, sem cortar silenciosamente ameaças fora do vetor.

Ações candidatas MultiDiscrete([3,2,2,2,2,16,3]): mover esquerda/parado/direita; pular; dash; lançar; rebater; direção de mira em16ângulos; opção de carta0..2. Na seleção de carta só o último campo produz ação; gameplay congelado pela pausa legítima. Botões devem produzir bordas de pressionar/soltar compatíveis com o input atual, não callbacks de ataque diretos que contornem guardas. Adicionar limites de repetição/reação ao desenho do agente; o número de ângulos é provisório e deve ser comparado à mira humana.

Fim: vitória real da run, morte ou limite operacional de episódio. Erro técnico de layout/transição é falha técnica separada, nunca derrota de combate nem vitória. Se houver falha técnica, interromper/excluir o episódio da aprendizagem e contabilizar o erro; não oferecer reset com recompensa que incentive explorar falhas. O primeiro adapter deve controlar esse contrato antes do treinamento.

## Reward e métricas separados
Reward candidato baseado em sala concluída uma única vez por identificador e vitória real, com custo pequeno de tempo/dano/morte. Não pagar repetidamente por bater em inimigo, curar, rebater bola própria, gastar dash ou reapresentar oferta. Não usar saldo de HP como dano recebido: cura pode ocultar dano, então usar eventos de dano aceito. Os pesos ainda não foram definidos nem otimizados.

Registrar localmente por episódio: revisão do perfil/build, seeds de ambiente e treino, duração/ticks, andar/sala/nível, HP entrada/saída, dano aceito/causado, acertos, rebatidas e dashes, escolhas com rank antes/depois/cap e tipo de recompensa, mortes/vitórias/falhas técnicas. Eventos únicos por sala/aquisição; snapshot não replica métricas nem cura. Sem telemetria externa nesta proposta.

## Avaliação justa
Separar seeds de treino e de avaliação e executar várias seeds/políticas. Comparar configuração anterior/candidata nas mesmas seeds/horizontes; 4/32 e horizontes longos suportados são cenários de avaliação, não duração final do GDD. Medir taxa de conclusão com incerteza, dano e tempo por sala/nível, distribuição de escolhas e efeito de remover um upgrade por vez. Políticas distintas (ofensiva, ricochete, rebatida e sobrevivência) ajudam a revelar dominância; uma política muito forte não representa o jogador novo. Comparar com sessões humanas antes de concluir que está divertido/justo.

Currículo proposto: movimento e plataformas; acertar bola; rebater; enfrentar cada inimigo; escolher cartas e atravessar portas; andar completo; runs maiores. PPO não consegue avaliar builds que não aprendeu a usar, portanto separar falha de aprendizagem de dificuldade real.

A documentação SB3 recomenda avaliação em ambiente separado e múltiplas sementes; a ciência de reward mostra que maximizar o objetivo pode explorar lacunas da especificação. Fontes: [RL Tips SB3](https://stable-baselines3.readthedocs.io/en/master/guide/rl_tips.html), [Specification gaming — DeepMind](https://deepmind.google/blog/specification-gaming-the-flip-side-of-ai-ingenuity/).

## Antes de executar
Implementar/revisar adapter e coleta opt-in, verificar dependências/versões e fixar orçamento de episódios/tempo/CPU/GPU com o usuário. Obter autorização explícita para engine/testes/treinamento conforme AGENTS. Até lá, nenhum percentual de vitória, desempenho do modelo ou simulação de balanceamento deve ser apresentado como medido. O teto técnico de220aquisições pode crescer com novas configurações, independentemente dos caps curtos das cartas.
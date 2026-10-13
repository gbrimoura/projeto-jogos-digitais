# Selenite Tower — histórico de mudanças do loop de jogo

**Consolidado em:** 13 de outubro de 2026  
**Projeto:** roguelite 2D desenvolvido em Godot  
**Branch de trabalho informada:** `feature/game-loop-assets`

Este documento reúne as alterações relatadas e confirmadas nas conversas sobre o loop de jogo, incluindo a conversa anterior. Ele distingue os sistemas testados dos que ainda precisam de validação.

## 1. Visão geral do jogo

O projeto acompanha um robô de entregas que precisa subir uma torre e levar uma encomenda até seu destino. O combate usa uma bolinha lançada pelo jogador, capaz de ricochetear e atingir inimigos. A estrutura planejada para a run é de três salas comuns seguidas por um chefe em cada andar, com derrota se a energia do jogador chegar a zero e vitória ao concluir o desafio no topo.

## 2. Base que já existia antes das alterações recentes

Antes da implementação da progressão da run, o projeto já contava com:

- movimentação do personagem, mira e lançamento da bolinha;
- lógica de ricochete, dano por impacto e retorno da bolinha para permitir um novo lançamento;
- um alvo de treinamento com vida e sinal de derrota;
- uma sala de combate que identifica inimigos pelo grupo `combat_enemy`, acompanha derrotas e emite `room_cleared` quando a sala fica vazia.

O alvo de treinamento foi usado como inimigo provisório para testar o ciclo de combate. Ele não representa, por si só, um inimigo com inteligência artificial ou padrões de chefe.

## 3. Progressão da run e salas

Foi criado o controlador de run em `scripts/world/run_controller.gd` e a cena inicial `run_root.tscn`, contendo o espaço da sala e a HUD da run.

O controlador organiza a progressão configurada com:

- **8 andares** por run;
- **3 salas comuns por andar**, seguidas por uma sala de chefe;
- intervalo de **1,5 segundo** entre a conclusão de uma sala e o carregamento da próxima;
- carregamento de cenas de sala comum ou de chefe conforme a etapa;
- avanço automático após o sinal `room_cleared`;
- atualização da HUD para exibir andar, etapa e estado do encontro.

O projeto foi configurado para iniciar `run_root.tscn` ao executar com **F5**. A usuária confirmou que a sequência de salas e o início pela cena da run funcionaram.

## 4. Recompensas e telas de resultado

Foi adicionada a tela de escolha de recompensa após o chefe, além das telas de resultado para conclusão e derrota, incluindo a opção de tentar novamente.

Também foram implementados bônus de recompensa para dano, velocidade e raio da bolinha. Os valores registrados nas alterações são **+25% de dano**, **+15% de velocidade** e **+15% de raio**, com intenção de manter os bônus nas salas seguintes.

**Validação pendente:** ainda não foi confirmado em teste de jogo que cada bônus altera o comportamento ou os atributos efetivos e permanece ativo nas salas seguintes. A progressão visual da recompensa está confirmada; o efeito prático precisa ser verificado.

## 5. Energia, dano, derrota e reinício

Foi adicionada energia/vida ao jogador, com valor máximo de **5**, representação visual em barra e lógica de dano por proximidade do alvo provisório. Os parâmetros informados para esse dano são **1 ponto por segundo** quando o jogador está a até **72 pixels** do alvo.

Como o jogador é recriado ao carregar uma sala, o controlador da run passou a guardar a energia atual e restaurá-la no próximo jogador. Assim, a energia não volta ao máximo automaticamente ao trocar de sala.

Quando a energia chega a zero, a run termina e apresenta a tela de derrota. A opção **Tentar novamente** reinicia a run.

### Testes confirmados

- o jogador recebe dano e a energia diminui;
- a energia atual é preservada entre salas;
- ao esgotar a energia, aparece `RUN ENCERRADA`;
- a opção de tentar novamente reinicia a partida.

## 6. Efeitos visuais e interface

- Foi criado o script `scripts/projectile/impact_spark.gd` para o efeito de impacto da bolinha.
- As cenas e scripts do projétil e do alvo foram alterados durante a integração das melhorias de combate e feedback visual.
- A HUD de progresso e estado do encontro foi incluída na cena da run.
- Foi observado que alguns textos da HUD ficavam sobrepostos. A usuária decidiu deixar esse ajuste visual para depois, pois não impedia o funcionamento do jogo.

## 7. Correções feitas durante a implementação

Durante a edição do controlador da run, houve erros de sintaxe causados por texto incorreto em uma declaração. A linha foi corrigida para `var floors_per_run: int = 8`, e a usuária confirmou que o projeto voltou a executar normalmente.

## 8. Arquivos alterados ou adicionados

Na última verificação de estado do Git compartilhada na conversa, foram listados:

**Arquivos modificados:**

- `README.md`
- `project.godot`
- `scenes/ricochet_ball.tscn`
- `scenes/training_target.tscn`
- `scripts/player/ball_launcher.gd`
- `scripts/player/player.gd`
- `scripts/projectile/ricochet_ball.gd`
- `scripts/world/training_target.gd`

**Arquivos e diretórios novos:**

- `run_root.tscn`
- `scripts/projectile/impact_spark.gd` e seu arquivo `.uid`
- `scripts/ui/` — scripts das telas de recompensa e resultado
- `scripts/world/run_controller.gd` e seu arquivo `.uid`

Naquela saída do Git, **nenhum arquivo apareceu marcado para exclusão**. Esta lista reflete o `git status` compartilhado naquele momento; ela não substitui uma nova verificação do estado atual do repositório.

## 9. Estado dos testes e próximos pontos de validação

### Confirmado pela usuária

- lançamento, ricochetes, retorno e novo lançamento da bolinha;
- sequência e avanço entre salas;
- inicialização da run por F5;
- energia, persistência entre salas, derrota e reinício;
- telas de recompensa e de resultado adicionadas.

### Ainda a validar

- confirmar que os bônus escolhidos após o chefe têm efeito mensurável nas salas seguintes;
- percorrer uma run até o chefe final e confirmar a conclusão completa da torre;
- desenvolver e testar inimigos e chefes com comportamentos próprios, além do alvo provisório;
- revisar a sobreposição visual dos textos da HUD.

## 10. Observação sobre o GitHub

As alterações foram trabalhadas na branch `feature/game-loop-assets`. Ao tentar enviar as mudanças por HTTPS, o GitHub recusou a senha da conta, pois operações Git exigem autenticação por um método compatível, como GitHub CLI, token ou SSH. O resultado mais recente relatado foi uma falha de autenticação no `push`; não há confirmação nesta conversa de que o envio ao GitHub tenha sido concluído.

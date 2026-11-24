# Impactos, ricochetes e velocímetro

- A bola principal recebe 10% da velocidade de lançamento a cada ricochete aceito, até 160% pelo bônus base. Turbina e Punho continuam compondo seus multiplicadores, com máximo teórico de 312% do lançamento no recorte atual.
- A rebatida restaura o orçamento de ricochetes, redireciona o voo e preserva a velocidade alcançada e o tempo de vida restante. A contagem de paredes que controla Fragmentação e as melhorias de dano segue separada.
- O deslocamento restante no quadro usa a velocidade nova pelo tempo ainda disponível. O trabalho que excede o limite de colisões de um quadro carrega o tempo que já foi reservado no quadro anterior.
- Parede, dano aceito e rebatida têm faíscas, clarão de contato e formas distintas. A velocidade real intensifica efeitos de impactos rápidos. O tremor é aplicado ao canvas de jogo, limita o deslocamento a 3 px por eixo, dura até 130 ms e restaura a transformação na pausa e na saída da sala.
- O velocímetro usa o módulo da HUD Caldeira abaixo da informação de sala. Ponteiro interpolado, setores teal, âmbar e vermelho e leitura percentual representam a velocidade da bola principal em relação ao lançamento. A escala analógica dá mais espaço à aceleração comum. O medidor se recolhe no retorno.
- O diff foi verificado com `git diff --check`. Execução no Godot e calibração em partida seguem pendentes.

Ajuste posterior. O velocímetro agora permanece visível enquanto a HUD de jogo estiver ativa e mostra um inteiro em px/s. O retorno usa o deslocamento real por quadro de física. Sem bola em movimento, o mostrador indica 0. A escala fixa vai até 3800 px/s no ponteiro. O número reflete a velocidade real mesmo acima da escala.

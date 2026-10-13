# Especificação — animação frontal de pulo V2 e adendo vigente V3

## Estado e referência

O runtime vigente é V3: oito poses reproduzidas da prancha foram integradas em 12/10/2026; o principal aceitou o contact, as revisões estáticas da integração estão em andamento e a avaliação visual do usuário no jogo está pendente. O texto anterior desta especificação registra a V2 histórica, substituída esteticamente pelo usuário; a definição vigente está no adendo de integração runtime V3 ao final.

A V2 substitui as três poses estáticas da primeira integração por nove desenhos articulados. O principal inspecionou o contact de nove poses e aceitou a arte antes da integração. Foi removido um deslocamento duplicado no quadril que deixava um vão escuro entre segmentos. A revisão estática da implementação V2 e a avaliação visual do usuário ainda não foram registradas.

A identidade frontal continua usando capacete creme, visor escuro com olhos ciano, torso e proporções existentes. Braços, joelhos, tornozelos e botas mudam localmente sem aumentar os volumes ou criar membros desconectados.

## Arte e atlas

- Canvas de cada quadro: 64×64 px.
- Atlas horizontal: 1664×64 px, 26 quadros.
- Quadros 0–16 são extraídos do atlas runtime congelado e copiados pixel a pixel; as durações de idle, walk e dash permanecem iguais.
- Os quadros novos 17–25 formam nove poses:
  - 17–18 — subida: o tronco/cabeça acompanha o impulso em até 2 px; braços sobem em arco curto; pernas iniciam e aprofundam a flexão.
  - 19–20 — ápice: alternância da dobra das pernas e braços em follow-through. Cada quadro dura 45 ms no runtime.
  - 21–22 — queda: pernas abrem e estendem para apoio; braços equilibram a postura.
  - 23–25 — aterrissagem: no primeiro quadro o torso baixa 2 px e os braços acompanham; no segundo o torso baixa 1 px; o terceiro recupera a postura em 0 px. Joelhos e tornozelos cedem de forma coesa, mantendo as solas fixas. Duração total de 135 ms.
- A paleta amostrada mantém 27 cores e alpha binário. O filtro permanece pixel-perfect, sem interpolação.
- A direção nativa dos clipes de jogador é esquerda. O flip para a direita continua sendo aplicado por PlayerVisual; dash conserva a direção nativa para a direita.

## Clipes e seleção no runtime

O recurso SpriteFrames contém:

| Clipe | Quadros do atlas | Cadência | Loop |
|---|---:|---:|---|
| jump_rise | 17–18 | 85 ms/quadro | sim |
| jump_apex | 19–20 | 45 ms/quadro | sim |
| jump_fall | 21–22 | 85 ms/quadro | sim |
| jump_land | 23–25 | 45 ms/quadro | não |

Godot usa velocidade positiva para baixo. Player._physics_process continua passando velocity.y depois de physics_step em todas as chamadas. PlayerVisual atualiza essa velocidade mesmo quando o estado grounded não muda. Abaixo de −80 px/s seleciona subida; entre −80 e +80 seleciona ápice; acima de +80 seleciona queda. Com gravidade atual de 1600 px/s², a janela de ±80 px/s corresponde a aproximadamente 100 ms ao redor do ápice, suficiente para os dois quadros de 45 ms. Nenhum valor de física foi alterado.

A troca de fase chama play somente quando o nome do clipe muda. Rise, apex e fall repetem seus quadros por duração em SpriteFrames enquanto a fase permanece ativa; o runtime não tenta reiniciar um clipe interrompido em cada tick. A prioridade é morte > dash > ar > aterrissagem > walk/idle. O dash não é reiniciado pelas atualizações aéreas; speed_scale permanece 1.0 no ar e na aterrissagem.

A aterrissagem exige contato observado com o chão antes do ciclo aéreo e retorno ao chão após esse ciclo. Reset limpa o contato armado, o estado aéreo e qualquer clipe de aterrissagem. Um novo salto, dash ou morte cancela a compressão. Enquanto ela toca, a locomoção continua livre; ao concluir, o clipe volta ao walk/idle corrente sem restart por tick.

## Prévia

Os GIFs usam 13 quadros demonstrativos em cada direção: idle inicial, os nove desenhos de salto e idle final. A tela de 64×128 é exportada a 4× nearest para 256×512. O personagem sobe e desce em arco vertical; a translação só existe na prévia, não nos quadros de runtime. Para leitura visual, cada pose do ápice é segurada por 110 ms no GIF, embora o runtime use 45 ms por quadro. O manifest JSON é escrito manualmente pelo Lua e registra quadros, cadências e clipes.
## Adendo de integração runtime V3 — 12/10/2026

A fonte visual passa a ser protagonista-pulo-v3-referencia-v2-poses-64px.aseprite e sua folha PNG equivalente, ambas 8×64×64 px. A geração verifica que os pares Aseprite/PNG coincidem pixel a pixel. O atlas final contém 25 quadros em uma linha (1600×64); os frames 0–16 do snapshot V2 permanecem byte/pixel-exatos e com as mesmas durações.

| Clipe | Frames finais | Timing | Repetição |
|---|---:|---:|---|
| jump_rise | 17–19 | 110/95/110 ms | Não; mantém o último quadro |
| jump_apex | 20 | pose única | Não; mantém a pose |
| jump_fall | 21 | pose única | Não; mantém a pose |
| jump_land | 22–24 | 45 ms cada, 135 ms total | Não |

Direção nativa do pulo é esquerda, coerente com visor/frente do capacete e a maioria das poses; o impulso conserva sua assimetria original. Direções nativas existentes de idle/walk à esquerda e dash à direita são preservadas. A linha de contato do idle é y=56. As oito poses recebem deslocamento inteiro comum Y=-5; a compressão recebe compensação de registro adicional +1 px, ficando em Y=-4. Esse ajuste é somente translacional, sem redesenho, escala ou autofit individual.

A lógica existente de PlayerVisual já selecionava fases aéreas pela velocity.y (limiar ±80 px/s), só chamava play quando a fase mudava, mantinha prioridade death > dash > ar > land > walk/idle e limpava histórico de pouso no reset. Por isso, ela não foi modificada. Física e controles ficam intactos. A importação do editor terminou com exit 0; gameplay, testes e inspeção final no jogo não foram executados.

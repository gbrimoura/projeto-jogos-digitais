# Especificação — animação frontal de pulo

## Estado e referência

A composição parte do primeiro quadro do idle aprovado, preservando a identidade frontal: capacete creme, visor escuro com olhos ciano, torso e proporções. O contact refinado foi inspecionado e liberado pelo principal antes da integração. Revisão externa estática e validação visual no gameplay continuam pendentes.

## Arte e atlas

- Canvas por quadro: 64×64 px.
- Atlas horizontal final: 1280×64 px, 20 quadros.
- Quadros 0–16 são copiados do atlas runtime congelado; três quadros novos são anexados:
  - 17 — subida: botas recolhidas cerca de 2 px; braços em arco externo de 1 px e antebraços 1 px mais altos.
  - 18 — ápice: botas recolhidas 4 px; joelhos e tornozelos acompanham a dobra; braços abertos 2 px e antebraços 2 px mais altos.
  - 19 — queda: pernas deixam as botas prontas para apoio e braços equilibram a postura.
- As três poses mantêm leitura frontal, membros conectados, volume compacto, paleta amostrada de 27 cores e alpha binário.
- O espelhamento segue a regra já existente: idle/walk/jump nativos para a esquerda e `flip_h` para a direção oposta; dash continua nativo para a direita.
- Fonte editável: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo/protagonista-pulo.aseprite`; o Lua reproduz a geração desde `protagonista-pulo-input-atlas-1088x64.png`.

## Seleção da fase no runtime

A animação `jump` usa regiões x=1088, 1152 e 1216 no atlas, com 100 ms por quadro e seleção estática pelo `PlayerVisual`:

| Velocidade vertical | Quadro | Pose |
|---|---:|---|
| `velocity.y < -40 px/s` | 0 | Subida |
| `abs(velocity.y) <= 40 px/s` | 1 | Ápice |
| `velocity.y > 40 px/s` | 2 | Queda |

Godot usa velocidade positiva para baixo. `Player._physics_process` passa `velocity.y` após `physics_step`; `set_grounded` atualiza a velocidade em toda chamada, mesmo quando o booleano de chão não muda. Só troca quadro quando muda a fase. Não há antecipação nem atraso adicional de controle.

Prioridade visual: morte > dash > jump > walk/idle. O dash mantém o reinício já existente e não é interrompido por mudanças de fase aérea. No ar, `speed_scale` fica em 1.0. Ao pousar, a animação retorna ao walk/idle corrente sem reiniciar playback a cada tick. `reset_to_spawn` informa estado no chão e velocidade zero antes de reaplicar a apresentação.

## Prévia

Os dois GIFs usam o mesmo arco vertical e espelham a pose para as duas direções. As posições do personagem dentro da tela são apenas composição demonstrativa; o runtime continua usando exclusivamente a física existente.

# Especificação — protagonista idle e caminhada v4

## Arte e fonte

Canvas de 64×64 por pose, exportação 1088×64 e paleta de 27 cores com alpha binário. O idle ocupa os índices 0–5 e o dash 14–16; ambos são copiados pixel a pixel do atlas de entrada versionado em protagonista-walk-v4-input-atlas-960x64.png.

A caminhada ocupa os índices 6–13, é desenhada por articulação no script Lua e usa conteúdo nativo para a esquerda. As oito fases são contato, compressão, passagem e elevação para cada perna. O torso tem cerca de 19 px de largura, inclina-se para a frente, liga-se a um quadril estreito e usa braços com espessura legível em contrabalanço. A cabeça e a antena são copiadas literalmente do primeiro quadro do idle aprovado; a antena acompanha a passada com atraso horizontal de 1 px.

Na pose de apoio, boot_y=50 deixa a sola em y=56. Na pose em balanço, boot_y=47 eleva a sola para y=53. A elevação do corpo não desloca a bota de apoio.

## Índices e temporização

| Animação | Índices do atlas | Quadros e duração |
|---|---:|---|
| idle | 0–5 | 420, 140, 180, 140, 540 e 80 ms |
| walk | 6–13 | 8 × 75 ms |
| dash | 14–16 | 40, 40 e 60 ms |

## Cadência e apresentação

A velocidade base do ciclo é 260 unidades de mundo por segundo. Enquanto walk estiver ativo no chão e fora do dash, AnimatedSprite2D.speed_scale recebe clamp(abs(velocity.x) / 260, 0,65, 1,35). O ajuste é feito em cada atualização de velocidade sem reiniciar o quadro atual. Idle, dash, ar, morte e reset restauram speed_scale para 1,0.

O player mantém o critério existente: caminhar somente no chão, sem dash e com velocidade horizontal absoluta acima de 8. Física, colisão, combate e controles não mudam. A regra de facing existente mantém o walk nativo para a esquerda e o dash nativo para a direita.

## Estado e validações

Implementação v4 integrada; revisão estática externa pendente. A exportação do Aseprite e a importação do atlas pelo editor Godot 4.7.2 (headless --editor --import, status 0) são operações de integração concluídas. Não foram executados testes, gameplay no Godot ou quality audit.

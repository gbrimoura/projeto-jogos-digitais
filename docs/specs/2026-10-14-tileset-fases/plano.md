# Aplicação do tileset às salas — plano prospectivo

Estado: autorizado para implementação visual. A arte V3 e o recurso TileSet foram importados; esta etapa aplica o atlas existente às superfícies de main.tscn e second_room.tscn.

## Objetivo

Substituir a aparência placeholder de pisos e plataformas por metal fabril em escala 2×, sem alterar dimensões, posições, colisões, personagens, inimigos, HUD ou regras de jogo. Manter o preenchimento vetorial atual como fallback configurável.

## Frente de implementação

1. Criar este plano, a especificação e o índice de pareceres antes do código.
2. Criar um visual @tool que recorte e repita regiões do atlas factory_tileset_v1.tres com nearest-neighbor, mantendo as dimensões visuais exatas do SolidPlatform.
3. Conectar o desenho a SolidPlatform; sincronizar a prévia no editor após alterações de tamanho e permitir retornar aos visuais vetoriais.
4. Aplicar estilo de bloco somente aos pisos e estilo de plataforma às demais superfícies nas duas salas; ocultar a grade de protótipo e acrescentar decoração industrial discreta.
5. Inspecionar estaticamente o diff congelado. Não executar Godot, importação, testes ou gameplay nesta frente.

## Escopo

Arquivos de runtime permitidos: scripts/world/factory_surface_visual.gd, scripts/world/solid_platform.gd, scenes/solid_platform.tscn, scenes/main.tscn e scenes/second_room.tscn. Documentação limitada a esta pasta. Preservar todos os outros arquivos e o histórico existente.

## Aceite

- As duas salas exibem piso de bloco e plataformas com pontas visuais.
- O desenho é recortado em células de 32 px ampliadas a 2×, sem esticar a textura e sem ultrapassar o retângulo atual.
- O redimensionamento no editor atualiza textura e colisão existente; desativar a skin restaura os visuais vetoriais.
- Valores e nós de física, posições, dimensões, spawns, atores e HUD permanecem iguais.
- As grades deixam de aparecer e os detalhes decorativos têm contraste baixo e não recebem colisão.

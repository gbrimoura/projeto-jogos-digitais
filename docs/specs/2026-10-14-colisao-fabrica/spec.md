# Especificação — colisão das superfícies da fábrica

## Causa

A integração visual de `SolidPlatform` usava `FactorySurfaceVisual` como tipo global em `solid_platform.gd`. O log disponível registra erro de parse ao resolver esse nome, impedindo o carregamento do script. As dimensões corretas estavam somente na propriedade `SolidPlatform.size` de algumas instâncias. O collider da cena-base permanecia 220×24 até `_sync_geometry()` rodar; por isso o piso de 1152×88 podia ser visualmente largo e ter somente 220×24 de colisão.

## Solução

- Localizar o filho visual como `Node2D` e configurar suas propriedades exportadas por `Object.set`, sem referência de tipo global.
- Fazer `_sync_geometry()` configurar a forma retangular primeiro e tratar Fill, TopEdge e FloorDetail de forma independente e opcional.
- Declarar um recurso de forma dedicado em cada instância de superfície nas cenas, apontando o `CollisionShape2D` da instância para a forma salva. A forma é centrada no nó e tem o mesmo tamanho declarado na instância.

## Dimensões por instância

| Cena | Superfície | Colisão salva |
|---|---|---|
| main | Floor | 1152×88 |
| main | PlatformA | 220×24 |
| main | PlatformB | 190×24 |
| main | PlatformC | 190×24 |
| second_room | Floor | 1152×88 |
| second_room | WestPlatform | 240×24 |
| second_room | UpperPlatform | 190×24 |
| second_room | EastPlatform | 170×24 |

## Limites de validação

Somente leitura estática e inspeção de diff. Não executar testes, Godot, importação ou gameplay sem pedido explícito.

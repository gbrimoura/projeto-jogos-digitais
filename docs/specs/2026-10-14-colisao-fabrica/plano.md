# Correção da colisão das superfícies da fábrica — plano

Estado: implementação congelada; revisão estática pendente.

## Objetivo

Eliminar a falha de carga do script de SolidPlatform causada pela referência a uma classe global ainda não registrada no cache do projeto, e garantir que o collider de cada piso/plataforma seja salvo com as dimensões reais da instância. A física precisa corresponder à superfície representada mesmo quando o script visual não carrega.

## Evidência inicial

O log existente `Godot/app_userdata/Selenite Tower/logs/godot.log` registra em `solid_platform.gd:67` duas ocorrências de `Could not find type "FactorySurfaceVisual" in the current scope`, seguidas por `Failed to load script ... solid_platform.gd`. A cena-base salva `RectangleShape2D_platform` como 220×24; os pisos de `main.tscn` e `second_room.tscn` declaram 1152×88 apenas na propriedade exportada `size`. Como `_sync_geometry()` era o único lugar que propagava `size` para o `RectangleShape2D`, a falha de parse deixa o piso com collider de 220×24.

## Frente

1. Retirar o acoplamento de `solid_platform.gd` ao identificador global `FactorySurfaceVisual`; atualizar o collider independentemente da existência de filhos visuais.
2. Salvar um `RectangleShape2D` com dimensões explícitas em cada instância de superfície nas duas cenas, alinhado às dimensões declaradas no nó.
3. Preservar posições, spawns, atores, HUD, decoração e recursos de arte.
4. Fazer revisão estática do diff congelado. Não executar Godot, importação ou testes.

## Escopo

Scripts: `scripts/world/solid_platform.gd`, `scripts/world/factory_surface_visual.gd`. Cenas: `scenes/solid_platform.tscn`, `scenes/main.tscn`, `scenes/second_room.tscn`. O recurso `resources/environment/factory_tileset_v1.tres` pode ser consultado; só será alterado se necessário. Documentação apenas nesta pasta.

## Aceite

- O script de superfície não depende de `class_name` global resolvido por cache para localizar/configurar o visual.
- Alterar o tamanho atualiza o collider mesmo se os nós visuais não existirem.
- Cada collider de piso/plataforma fica persistido na cena com largura e altura iguais ao tamanho visual real da instância.
- Props decorativos permanecem sem física.
- Não há alterações fora do escopo nem execução do runtime/testes.

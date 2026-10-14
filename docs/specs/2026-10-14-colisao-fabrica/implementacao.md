# Implementação — colisão da fábrica

A causa foi confirmada em historico/logs/godot.log: duas falhas ao resolver o tipo global FactorySurfaceVisual em solid_platform.gd:67, seguidas da falha de parse do script. A forma padrão da cena-base mede 220×24; o script era o único responsável por aplicar à forma as dimensões de cada instância.

solid_platform.gd agora encontra o helper como Node2D, configura seus campos exportados via set e ajusta a forma retangular mesmo quando faltam nós visuais. factory_surface_visual.gd não declara mais a classe global que causava o acoplamento de cache. main.tscn e second_room.tscn agora persistem shapes dedicados, com medidas alinhadas a cada instância: pisos 1152×88; plataformas 220×24, 190×24 e 190×24 em main; 240×24, 190×24 e 170×24 em second_room.

A inspeção estática confirmou referências shape/subresource e contagem load_steps consistente em ambas as cenas. Posições e propriedades dos atores, spawns, HUD e decoração não foram alteradas nesta frente. Nenhum teste, importação ou comando Godot foi executado, conforme instrução.
# Plano — Porta embutida na parede

**Data:** 18/10/2026  
**Estado:** integração visual autorizada; runtime e engine permanecem sem validação.  
**Branch/base:** `corrigir-sprites-salas-plataformas`, HEAD `90b2e592bd70e1b2ff3e5828af8a9029031e1c66`, com o working tree local preservado.

## Objetivo

Substituir a porta vetorial solta no chão por um asset pixel art de porta industrial integrado à face da parede lateral. A abertura visual deve comunicar os estados fechado/aberto da porta de saída e continuar alinhada ao mesmo encaixe nas duas fixtures.

## Arte e montagem

- Reproduzir a referência ImageGen como guia, não como asset final, em Aseprite real usando Lua editável; manter a identidade dieselpunk, caixilho e silhueta comuns nos dois estados.
- Usar a paleta exata de 20 cores de `../GDD_Dieselpunk_Noir/pitch-assets/tileset-fabrica-v1/palette-fabrica-v1.json`. Fonte nativa de cada estado: 32×64 px; folha vertical: 32×128 px; escala runtime 2× = módulo visual 64×128 px.
- `Closed` mantém a veneziana fechada. `Open` recolhe a veneziana no lintel e deixa um vão escuro legível de pelo menos 44 px nativos em altura. A armação ocupa o mesmo canvas e registro nos dois estados. Sem texto incorporado.
- Exportar `.aseprite`, `.lua` reprodutível, PNG da folha, preview em 4× e montagem estática com amostras do atlas atual calculadas pelas coordenadas da parede. Preservar a referência original copiada no diretório do asset.

## Integração autorizada

- Alterar somente `scenes/exit_door.tscn`, `scripts/world/exit_door.gd`, e os overrides visuais da porta em `scenes/main.tscn` e `scenes/second_room.tscn`, além de adicionar `assets/environment/factory_v1/door/`.
- Manter intactos o `Area2D`, o sensor 96×108 em x=992..1088 relativo à sala para a saída, a interação E, os sinais, guards, unlock, lógica de transição e rótulos de estado.
- Na saída direita: Sprite2D centralizado no ponto global (1120,496), offset local (80,-26) relativo à porta (1040,522), escala 2×, dimensão visual 64×128, z positivo sobre o patch x=1088..1152/y=432..560. Espelhar horizontalmente a instância para trazer o indicador âmbar ao lado jogável.
- Na entrada esquerda: ponto global (32,496), offset local (-80,-26) relativo a (112,522), mesmo canvas/escala/encaixe e indicador voltado ao interior. Entrada continua fechada, bloqueada e sem sensor ativo.
- A parede de fundo e seus colliders permanecem contínuos. A arte `Open` comunica a abertura da saída para a transição existente; não abre fisicamente a parede nem autoriza remover/recortar colisores.
- Remover os polígonos/linhas visuais antigos. Manter o texto da porta fora do sprite, compacto e do lado jogável, sem mudanças de lógica.

## Sequência

1. Documentar especificação e congelar snapshots/hashes do estado local antes de tocar no runtime.
2. Reproduzir e inspecionar a arte em Aseprite após a referência ImageGen fornecida pelo principal.
3. Exportar folha/preview e uma composição estática da porta sobre os tiles reais da parede.
4. Atualizar a cena reutilizável, apresentação de estados e overrides visuais de entrada/saída dentro do recorte autorizado.
5. Congelar os arquivos e devolver para revisão somente leitura do principal/revisores disponíveis.

## Limites

Sem Godot, import, testes, quality audit, QA automatizado, alteração de colisões/física, atlas existente, regras de gameplay, index global, commit ou push. A inspeção permitida limita-se à arte PNG e à montagem estática.

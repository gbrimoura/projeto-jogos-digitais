# Porta horizontal da fábrica — V2

Asset pixel art horizontal embutido em painel de parede. A arte final foi desenhada em Aseprite usando o script Lua editável ao lado; a referência ImageGen é apenas guia visual e não compõe a textura do jogo.

## Arquivos

- `porta-fabrica-horizontal-v2.png`: spritesheet runtime de 320×80 px, com `Closed` no frame 0 e `Open` no frame 1. Cada painel/frame mede 160×80 px.
- `porta-fabrica-horizontal-v2.aseprite`: fonte editável da arte e das prévias.
- `porta-fabrica-horizontal-v2.lua`: desenho em pixel grid e exportação pelo Aseprite real; o padrão grava ao lado desta pasta resolvendo a raiz configurada (`p.root`), e `p.out` permite substituir o prefixo de saída.
- `porta-fabrica-horizontal-v2-preview-4x.png`: spritesheet ampliado 4× para inspeção visual, não usado no jogo.
- `porta-fabrica-horizontal-v2-montagem-estatica.png`: montagem estática do módulo nas duas extremidades, sobre a parede e o piso existentes, com o protagonista atual em primeiro plano. É uma composição de inspeção baseada no atlas por coordenadas, não uma captura do Godot. A legenda informa que a porta aberta à esquerda é só amostra e que a entrada no jogo permanece fechada.
- `referencia-porta-horizontal-v2.png`: cópia preservada da referência conceitual recebida.
- `../../../../docs/specs/2026-10-18-porta-parede/imagegen-prompt-horizontal-v2.txt`: prompt da referência, mantido na documentação da decisão.

## Contrato visual

Cada estado é um painel opaco de 160×80 px nativos; a porta fica integrada no retângulo `(16,8)` a `(144,72)`, com 128×64 px. As duas molduras compartilham escala e encaixe. No estado aberto, a folha recolhe em lâminas dentro do bolso lateral embutido. A abertura útil mede 80×48 px nativos, preservando 48 px de altura livre (96 px no jogo) sem deixar uma folha na margem externa do painel.

A arte usa somente as 20 cores da paleta existente `../../../../../GDD_Dieselpunk_Noir/pitch-assets/tileset-fabrica-v1/palette-fabrica-v1.json`, com alpha binário. O canvas de cada módulo é totalmente opaco para que a placa seja lida como parte da parede. A integração define filtro nearest (`texture_filter=1`) e escala 2×. O estado aberto representa acesso/transição visual; a parede física continua íntegra.

Na cena, a raiz da saída e seu sensor continuam nos pontos existentes. O painel da saída tem centro visual local `(-80,-26)`; o painel da entrada usa `(+80,-26)` e espelhamento horizontal para orientar o bolso à parede lateral. O sensor E permanece 96×108 e localizado junto ao lado jogável; a imagem não promete interação na largura inteira do painel. A entrada permanece fechada durante o jogo.

## Hashes

Os SHA-256 de cada arte, fonte e prévia acompanham `manifest.json`. Metadados `.import` podem estar presentes no checkout local; não fazem parte do asset-fonte, não foram editados e não houve execução de importação ou engine neste trabalho.
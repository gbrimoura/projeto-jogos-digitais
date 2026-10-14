# Plano — inimigos cartoon V2

**Estado:** arte Aseprite concluída e contato final aprovado pelo agente principal em 14/10/2026; integração/runtime pertence à etapa seguinte.
**Data:** 14/10/2026.

## Objetivo

Reproduzir a nova prancha `referencia-inimigos-cartoon-v2.png` para TrainingTarget e RivetWorker em sprites 64×64, com silhuetas cartoon limpas e legíveis. Esta é uma nova reprodução; preservar integralmente a versão V1 e seus recursos de runtime. Não recolorir ou adaptar a arte V1 como substituta da nova referência.

## Método

- Usar Aseprite 1.3.18.6 e um único Lua de lote para extrair as oito poses da prancha completa, aplicar nearest com um fator único por personagem, flood-fill de fundo neutro conectado às bordas, e quantizar às 14 cores-base selecionadas e preservar um swatch laranja amostrado da referência somente nos visores ativos (máximo observado: 15 cores opacas).
- Preservar contorno azul-preto, rosto/capacete/ferramenta conectados e alpha binário; fundo cinza da prancha fica transparente. Sem dithering, ruído especular ou pixels desenhados fora da referência.
- Gerar dois arquivos fonte `.aseprite`, dois atlas PNG RGBA, metadata com crops/bounds/contagens/registro/timings e um contato nearest 4× que compare o herói atual.
- Produzir somente em `pitch-assets/inimigos-cartoon-v2/`. A fonte ImageGen é read-only; V1 e os arquivos de jogo ficam intactos.
- Parar após geração e inspeção do contato. Não copiar para runtime, modificar cenas/scripts/recursos, importar, executar Godot/gameplay/testes/QA ou publicar.

## Alvos visuais

TrainingTarget: três poses na ordem idle, impacto, desativado. Escala de origem aproximada 8 px/nativo, corpo 35–36×44–45 nativo, eixo x=32 e base de borda y=56 fixa. Cabeça marfim grande, expressão angular laranja e um tubo grosso de manutenção.

RivetWorker: cinco poses na ordem idle, andando, mirando, disparo, recuperação. Escala aproximada 8 px/nativo, corpo 23×32, pés alinhados à borda y=56, virado à direita. Capacete vermelho com aba, face marfim, luvas/botas robustas e pistola de rebites compacta. A boca da ferramenta nas poses mirando/disparo deve ficar em (43,38)±2 pixels nativos sem separar a ferramenta da mão.

## Paleta e transparência

Usar cores existentes do protagonista, feedback de combate e paleta industrial: cremes `#F5E9D8`, `#CFC3B7`, `#FFFCF0`; outline/metal `#00000D`, `#373F4D`, `#192031`; vermelho `#F0524E`, `#FF7256`, `#D94B4B`; ferrugem em três tons `#70432C`, `#925A36`, `#B37949`; calor `#F5A84F` e, apenas no acabamento da ferramenta, `#FCC203`. Limite de 31 cores totais. Pixels são 0 ou 255 alpha.

## Baseline e handoff

`historico/base/` registra antes desta reprodução os quatro arquivos de inimigo, assets PNG/ASE, recursos SpriteFrames e shader existentes, mais hashes/snapshots das áreas protegidas do protagonista, pisos e salas. A etapa encerrou com arquivos de arte congelados e contato aprovado pelo principal. A integração seguinte pode copiar somente as quatro fontes PNG/ASE aprovadas para seus destinos já definidos; scripts, cenas, recursos e shader não precisam mudar se os frames 3/5 mantiverem a ordem.

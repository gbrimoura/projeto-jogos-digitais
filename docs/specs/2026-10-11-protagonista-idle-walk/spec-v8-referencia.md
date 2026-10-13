# Adendo prospectivo — caminhada V8 reproduzida da referência

**Estado:** V8 refinada, inspecionada pelo principal e integrada ao runtime. Godot import editor exit 0. Gemini/Muse/Grok concluídos sem defeitos concretos; Opus bloqueado por quota. Avaliação estética no jogo pelo usuário pendente. O contrato abaixo foi escrito antes da implementação e é preservado.

## Objetivo

Trocar somente os oito desenhos da caminhada frontal nos índices runtime 6–13 por poses reproduzidas da prancha AI gerada para esta tarefa em 12/10/2026. O movimento deve ler como passada frontal com transferência de peso, apoio claro, joelhos flexionando e recuperação; braços podem receber contrabalanço curto de até ±1 px nativo depois da reprodução, sem substituir ou redesenhar as poses das pernas.

## Contrato preservado

- Canvas de 64×64 px por pose, oito poses em ordem 4×2 de contato, compressão, passagem e elevação para cada lado.
- Atlas runtime de 25 quadros, 1600×64: idle 0–5, caminhada 6–13, dash 14–16 e pulo V3 17–24.
- Caminhada em loop, oito quadros de 75 ms e speed_scale existente.
- Sola de apoio em y=56 em todas as poses; registro horizontal coerente em torno do mesmo centro, sem jitter causado pelo layout da referência.
- Identidade e proporções compactas do idle frontal; largura máxima de 32 px; escala única e uniforme para todas as poses, sem auto-fit por quadro.
- Paleta runtime existente de 27 cores; saída com alpha estritamente binário e sem halos/linhas de fundo.
- Pixels e tempos de idle, dash e pulo permanecem idênticos ao snapshot historico/pre-walk-v8/runtime/. Não alterar física, movimento, input, colisões, combate, cenas, scripts visuais ou gameplay.

## Arte e aprovação

A referência original 1536×1024, grade 4×2, fica preservada em GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8/referencia-walk-v8-v1.png. A imagem usa alpha não binário e tem halo/fundo suave; a extração deve remover esse fundo sem erosão dos contornos, quantizar à paleta herdada e alinhar as poses por base comum. Se uma máscara simples e reproduzível não conservar a silhueta, interromper a extração e pedir nova referência sem fundo ao principal.

Antes de qualquer integração, entregar: fonte editável Aseprite, spritesheet 512×64, contact sheet ampliado com as oito poses e comparação com idle, JSON com limites/escala/registro e GIFs de inspeção para esquerda e direita. O contact e os GIFs precisam mostrar oito poses sem deslocamento artificial de corpo; o principal avalia a leitura de apoio, flexão, recuperação, escala e identidade.

## Critérios de aceite

1. Contato: pé de apoio estável em y=56; joelhos e deslocamento de peso legíveis.
2. Compressão: corpo mais baixo/peso reconhecível e articulação clara, sem exigir movimento de braço grande.
3. Passagem: pernas próximas do eixo central, sem silhueta estática repetida.
4. Elevação: perna em balanço dobrada/erguida com apoio do outro pé; nenhum quadro com ambos os pés parecendo flutuar.
5. Ciclo: transições e retorno ao primeiro quadro coerentes; escala e alinhamento estáveis.
6. Integração liberada apenas após inspeção visual do principal; importação Godot 4.7.2 pode confirmar recurso, sem executar testes ou gameplay.
## Resultado da implementação

A referência original foi preservada; extração Aseprite Lua em escala uniforme 9:1, alpha mínimo 224 e quantização à paleta de 27 cores. O principal rejeitou o primeiro contact por instabilidade de capacete/visor e pediu registro horizontal do corpo e cabeça original do idle. A fonte final mantém as pernas reproduzidas da prancha, substitui cabeça/antena/visor e conexão superior pelos pixels do idle e aplica bob de cabeça [0,1,0,-1,0,1,0,-1]. O balanço curto dos antebraços usa ciclo completo [1,1,0,-1,-1,-1,0,1] e sinal oposto no outro braço.

A composição foi corrigida para retirar restos da cabeça AI e separar cabeça/corpo sem duplicação em duas camadas reais na fonte editável. A metadata foi recalculada nos quadros compostos; apoio y56 em todas as poses. O principal inspecionou o contact final e liberou a integração. Isso não representa aprovação final do usuário.

Integrador integrate-walk-v8.lua lê o snapshot permanente pre-walk-v8 e substitui apenas 6–13 no PNG e Aseprite de 25 quadros. Idle, dash e pulo V3 têm pixels, durações e tags preservados. SpriteFrames, PlayerVisual, cenas, física e input não mudaram. Importação Godot 4.7.2 editor exit 0. Nenhum teste, gameplay ou quality_audit; GIF nominal75ms pode arredondar para centésimos, runtime mantém75ms.

Arquivos finais no diretório GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk-v8 usam sufixo v2: poses.aseprite, poses.png, metadata.json, contact-4x.png, contact-comparativo-4x.png e preview-esquerda/direita.gif. Referência e primeira reprodução preservadas. Fonte do extrator protagonista-walk-v8-v2.lua; fonte do integrador integrate-walk-v8.lua.

[Revisões da V8](pareceres/caminhada-v8/README.md).

## Correção localizada dos ombros — V3

O usuário reportou ombros quebrados. Removidos da camada da cabeça somente os11pixels laterais de pads/contorno da linha32(x24–28,x34–39), que duplicavam os ombros próprios do corpo e recebiam bob indevido. 88pixels nas8poses; bodyLayer intacta. Cabeça real/colar, braços, pernas, boots e cadência preservados. Fonte e previews com prefixo protagonista-walk-v8-v3-ombros. Principal inspecionou before/after8x e aprovou integração. Godot import final exit0/stderr vazio; sem gameplay/testes. [Pareceres e investigação da compressão](pareceres/ombros-v3/README.md): Gemini/Muse/Grok recebidos, hipótese Grok descartada por leitura de pixels; Opus por quota.

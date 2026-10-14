# Kit de cenário da fábrica — plano prospectivo

Estado: arte V3 e contato 4× aprovados visualmente pelo principal; atlas, fonte Aseprite, demo e TileSet independente preparados. O recorte de tamanho, quantidade de peças e limite de cores vale somente para este kit; não define padrão global nem regra final do GDD.

## Fontes e leitura do GDD

- [Arquivo Central](https://app.notion.com/p/3cf695c14e278028a60af8e6bd1a5710) e [Direção Visual](https://app.notion.com/p/3cf695c14e2781619978cd3ba62c5f94): estabelecem o jogo 2D lateral e a fábrica industrial decadente em estética dieselpunk noir dos anos 1930–40. Priorizam silhuetas e leitura das superfícies jogáveis sobre detalhe, com máquinas distantes e objetos sem função em planos de contexto.
- [Primeiro Andar](https://app.notion.com/p/3cf695c14e2780668784f80479cd0f9d): descreve o piso inicial como área de vapor e manutenção, com âmbar, ferrugem e cartazes de produtividade; esteiras, pistões e óleo são ideias de cenário, não autorização para introduzir nova física ou comportamento.
- O documento local [04-combate-e-builds.md](../../../../GDD_Dieselpunk_Noir/04-combate-e-builds.md) registra o protótipo parcial e a fantasia fabril, mas não fixa resolução, dimensão de tile ou paleta de ambiente. Seu estado é rascunho em desenvolvimento.

## Objetivo

Preparar um kit visual modular de metal de fábrica que substitua parte da leitura abstrata de piso/plataforma em estudos visuais posteriores, mantendo as superfícies ricocheteáveis e o protagonista legíveis. A etapa de arte reproduz a referência aprovada com pixels editáveis; a futura integração limita-se a disponibilizar um TileSet independente, sem editar cena principal, scripts, física ou regras de interação.

## Recorte provisório desta tarefa

A grade lógica de 32×32 px e 16 peças em atlas 4×4 foi proposta para este kit e confirmada na inspeção da referência V3. É uma escolha local da tarefa; o GDD não fixa essa resolução para o jogo. A organização proposta, em coordenadas zero-based (coluna, linha), é:

| Coordenada | Peça |
|---|---|
| (0,0), (1,0), (2,0) | terreno: topo esquerdo, topo meio, topo direito |
| (0,1), (1,1), (2,1) | terreno: lateral esquerda, preenchimento, lateral direita |
| (0,2), (1,2), (2,2) | terreno: base esquerda, base meio, base direita |
| (0,3), (1,3), (2,3) | plataforma: ponta esquerda, meio repetível, ponta direita |
| (3,0), (3,1), (3,2), (3,3) | painel de aço, cano horizontal, cano vertical, canto de cano |

O limite provisório de cor é até 20 cores opacas para o ambiente, com alpha apenas 0/255 quando houver transparência. A paleta deve ser própria para o cenário, escura, quente e desaturada: carvão, cinzas quentes e marrons escuros, com ferrugem/cobre em detalhes pequenos. A paleta de 27 cores do protagonista serve somente como referência de contraste e não deve ser uma obrigação de quantização para o ambiente. Reservar amarelo claro/ciano para sinalização realmente interativa e vermelho/laranja para ameaça; não transformar azul-ciano ou listras amarelas em decoração repetida que possa sugerir perigo falso.

O visual deve mostrar metal pesado, luz recortada e desgaste funcional (fuligem, ferrugem, remendos ou vazamento apenas quando a prancha e a escala permitirem). A linha superior da plataforma e a silhueta das bordas precisam continuar fáceis de distinguir do fundo; essa leitura é visual e não define colisão. Repetições em trechos de meio devem ser corrigidas localmente para conectar as bordas sem emendar juntas artificiais. Detalhes pequenos não podem competir com bola, inimigos ou robô.

## Etapas e portões

1. A referência ImageGen foi preservada sem sobrescrever e inspecionada quanto à composição, material, luz e escala; ela orientou a reprodução, mas não substitui o atlas.
2. O principal confirmou o recorte local 32×32 após inspecionar o contact; o GDD não fixa essa resolução para o jogo.
3. A prancha Aseprite, atlas 4× e demos foram inspecionados; após correções locais de emenda e alinhamento, o principal aprovou o contato V3. A reprodução preserva a identidade da referência.
4. A cópia pixel-exata aprovada foi colocada no runtime e o recurso TileSet editável independente foi preparado sem colisões.
5. A montagem isolada de piso/plataforma e idle atual do robô (recorte exato de 23×50 px) foi produzida para comparar escala; é apenas visual e não integra a cena principal.

## Entregáveis previstos

- GDD_Dieselpunk_Noir/pitch-assets/tileset-fabrica-v1/: referência ImageGen preservada; fonte Aseprite; Lua reproduzível; atlas PNG nativo e contact nearest; mapa de demonstração, manifest com nomes/coordenadas/usos, e README com decisões e hashes.
- assets/environment/factory_v1/: cópia runtime pixel-exata do atlas aprovado, sem retoque depois da aprovação.
- resources/environment/factory_tileset_v1.tres: TileSet separado, editável, tamanho lógico de tile correspondente ao recorte aprovado, atlas configurado para nearest e sem colisões definidas.
- A cena de amostra assets/environment/factory_v1/demo_editor.tscn mostra somente um Sprite2D com nearest e escala 2. Ela não é usada pela cena principal. Não alterar scenes/main.tscn, scenes/solid_platform.tscn, scripts/world/solid_platform.gd ou qualquer outro asset preexistente.

## Validação autorizada e limites

O principal conferiu visualmente a referência, o atlas 4×4 e uma montagem 2D de piso/plataformas em nearest ampliado, aprovando o contato V3. O manifest permite recompor cada peça por coordenada e o PNG runtime deve ser idêntico ao PNG aprovado. As plataformas usam largura exata de 32 px e alturas de 16/10/17 px; as saídas dos canos preservam proporção dentro da célula. Esta frente não executa testes, Godot, importação, quality audit, nem cria ou redefine colisões. Não acrescenta convenções de paleta ao GDD, física de esteiras/pistões/óleo, comportamento de cenário, nem decisões de layout final de fases.


## Encerramento do incremento visual

Arte V3 e recurso TileSet preparados. Gemini R1 e Muse R2 concluíram a revisão estática; Grok timeout3min e Opus quota. Os textos documentais foram corrigidos pelo mesmo GPT-6 Luna xhigh via OpenCode após quota na interface original. [Saídas, decisões e hashes](pareceres/README.md). Sem execução de Godot, testes ou importação; uso nas salas e colisões permanecem para etapa própria.


## Importação solicitada pelo usuário — 14/10/2026

Godot4.7.2 importou atlas/demo sem erros (exit0). TileSet carregado com16 células32×32 e textura128×128; prévia carregada. Nenhuma mudança nos8 arquivos de arte/recursos acompanhados por hash. [Logs, status e hashes](pareceres/importacao-2026-10-14/README.md). Sem execução de gameplay; colisões e montagem na sala permanecem para etapa própria.


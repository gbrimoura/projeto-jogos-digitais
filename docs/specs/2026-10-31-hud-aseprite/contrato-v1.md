# Contrato final v1 — prevalece sobre valores sugeridos anteriores

Este arquivo consolida as decisões antes da produção. Trechos R1/R2 anteriores são histórico; métricas e dimensões abaixo são as autoritativas. A referência é o Painel de Caldeira revisão04; nenhuma integração Godot.

## Saídas e ferramentas

Somente assets/ui/hud_caldeira_v1/** novos. Subpastas source/ (.aseprite/Lua), export/ (PNG/JSON/font/paleta), preview/ (folhas/contextos/overlay de estudo). .gdignore emsource epreview. Rootdocumentação; Luna único autor45min. Aseprite1.3.18.6 confirmado; produção Lua real com paramsANTESscript e root/path em argumentos separados. stdout/stderr e errosLua verificados como parte da geração. SemGodot/testes/parser/linter/auditQA/Git.

## Paleta e pixels

BaseHUD: #0E0D0E #0C1B29 #142C40 #203E50 #353B3B #4B555D #59636B #879198 #B6BEC3 #70432C #925A36 #B78342 #D2A75C #E8D8B5 #F4ECD8 #B84B42 #7D302E #52BAC7. Máscara de fonte branca#FFFFFF. Alpha0/255, hardedges, nenhuma interpolação. Retratos recortados preservam paletas originais (atlas próprio se preciso), exceção explícita ao conjuntoHUD. Cenário de contexto também preserva paletas preexistentes.

## Dimensões finais em pixels nativos

| Peça | Tamanho | Âncora da composição576x324 |
|---|---|---|
| Player |144x40|(8,8)|
| Dash |144x40|(8,52)|
| Alvo |144x40|(216,8)|
| Salas |84x36|(484,8)|
| Instrumento |84x60|(484,48)|
| Etiqueta CONCEITO de estudo |até74x15|acoplada abaixo do instrumento, layer própria|

Player/alvo aumentam de36 para40 para usar o retângulo completo da fonte sem depender de esconder linhas transparentes. Moldura9-slice24x24: cantos6x6, margens6, rebites inteiros nos cantos; conteúdo respeita inset6. Barras: frame96x14, interior(3,3,90,8). Fillisolado90x8, corâmbar/vermelho, sem texto. Exemplos3/5=54px,4/6=60px. Quantização visual roundnearest(clamp(HP/max,0,1)*width), usando floor(x+0.5), maxpositivo. Não é unidade de dano. Valores dinâmicos não colados na arte de produção.

Dash: icon16, gap4, clock24, gap4, bloco texto72 =120≤132 de interior. Texto em duas linhas12px: primeira DASH com tempo0,3s, segundaRECARREGANDO ouPRONTO. Clock24 cabe no interior28 de altura; não forçar três linhas. Ajustes de2px de posição permitidos para legibilidade, registrar rectangles no manifesto.

## Relógio e medidor

Clock24x24 tem17frames:index0=pronto/vazio;index16=recarga/cheio;remaining=index/16, elapsed=1-remaining. Revelação/esvaziamento horário desde12h; máscara cinza restante inicia no ângulo elapsed*360 e vai até360. Ponteiro indicaelapsed. Amostrar centro de cada pixel e raio inteiro consistente, evitando mudança de cobertura por algoritmos diferentes entreframes. Mappingfuturo frame=floor(clamp(remaining,0,1)*16+0.5). Não há segundos/duração física embutidos. PNGporstates e sheet/ASEtags permitem ajustar no futuro.

Dial largura37, pivô inteiro(18,18) relativo ao dial; semicirculoraio18 com suporte ao centro. Agulhas discretas de estudo (ex.9posesnormalizadas) pré-renderizadas/pivô documentado, semrotatefracionário de textura. Aceleração continua conceito sem unidade, fórmula, máximo ou timingdegameplay. Etiqueta conceitoseparada.

## Fonte e conteúdo

Fontemonocromática própria bitmap. Corpo5x7 em rows2..8, acentosrows0..1, cedilhay9..10. Célula5x11, advance6, lineheight12. baseline_from_top_zero_based=8 (última linha do corpo); BMFontopcionalbase=9. Estas métricas SUBSTITUEM explicitamente5x9/linha10 e quaisquer valores anteriores. Arquivos-fonte dos retratos são outro assunto, não métricas tipográficas.

Glyphs exatos: A..Z,0..9,sminúsculo, espaço, / , : . - %, ÁÀÂÃÉÊÍÓÔÕÚÇ. Labelsestudo:VIDA,DASH,RECARREGANDO,PRONTO,ANDAR,SALA,TRANCA-LATA,COSPE-REBITE,ACELERAÇÃO,DA BOLA,CONCEITO,ÁREA LIMPA. Texto branco emmask PNG; previews usam creme/cinza da paleta. Nomeslongos e valoresaté999/999 têm textrect/truncamento documentado, não significam limite deHP do jogo. Labels/previews separados das peças dinâmicas.

## Fontes e edição

Retratos24x24 recortados (sem escala) de frame0 dos PNGs: assets/player/player-animations.png; assets/enemy/training_target/training_target-atlas.png; assets/enemy/rivet_worker/rivet_worker-atlas.png. Autor escolhe janela de cabeça a partir de imagem real e registra crop exato, pixels preservados. Sem desenhar novas identidades.

Fonte de contexto: assets/environment/factory_v1/background_floor1/modular/context-seed-000.png. Código de produção do fundo e cenaPlayer mostram uso2x real; redução2x nearest dessa montagem de estudo recupera a grade576x324, e HUDtambém é2x ao aplicarnoespaçológico1152x648. Exportar contexto576, contexto1152 e preview3x1728x972 da grade nativa, sem afirmar runtime ou pixelperfectfinal1920.

Composição .aseprite em camadas por módulo/portrait/barra/fill/texto; cenário em layerreferência separada. Overlay transparente não contém fundo. layout.json descreve defaulttop e alternativa instrumento inferior(484,256), mantendo a proposta04 ajustável; autorização vem do pedido atual de ajustar distribuição a partir de jogosfamosos, não requer confirmação extra.

## Metadados

Cada elemento: id,file,native_rect,atlas_rect sempadding,pivot,margens/inner_rect se aplicável,state/frame se aplicável. Paddingatlas2px transparente ao redor de cada região. layout.json comrects/anchors/scale e notasdeestado; font.jsoncodepoint/rect/advance/metrics; portraits.jsonsource/frame/crop. app.versionreal no manifest. README descreve produção, ajustes, outputs e limites, sem declarar teste/audit passado. Estado semalvo é pendência deintegração; kit fornece moldura vazia, sem inventar lógica.

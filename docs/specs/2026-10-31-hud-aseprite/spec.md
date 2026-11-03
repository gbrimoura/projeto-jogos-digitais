# Especificação inicial do kit

## Identidade e componentes

Painel de Caldeira: navy escuro, rebites de cobre, creme, âmbar para vida do personagem, vermelho para vida do alvo, relógio/estado de cooldown cinza. Arte pixelada com contornos em degraus, sombras de2–3tons e fonte bitmap. Fonte e peças de arte originais/nativas; referência ImageGen não é textura pronta. Usar sprites reais para retratos, com crop documentado e pixels preservados, sem redesenhar identidades.

Requisitos confirmados: vida em barra contínua com atual/máximo, HP inimigo fixo do inimigo próximo da mira (com nome/retrato), dash com relógio cinza além da frase RECARREGANDO/PRONTO e segundos, contador de andar/salas, acelerômetro conceitual para futura aceleração da bola. Sem botões de bola/raquete, moedas, slots vazios ou novos sistemas. Regras de aceleração/escala/unidades permanecem pendentes.

Paleta local bloqueada, não paleta final do GDD: #0E0D0E #0C1B29 #142C40 #203E50 #353B3B #4B555D #59636B #879198 #B6BEC3 #70432C #925A36 #B78342 #D2A75C #E8D8B5 #F4ECD8 #B84B42 #7D302E #52BAC7 #FFFFFF (branco puro apenas máscara de fonte). Alpha0/255. Sem cores interpoladas. Composição de fundo/sprites reais pode conter as paletas preexistentes; não confundir com a paleta estrita das peças novas.

## Grade e dimensões de partida

Arte da HUD em resolução nativa metade do espaço lógico da sala: composição576x324, aplicação futura2x em1152x648. Referências de escala: personagens64x64 e tiles32x32 do projeto. Não alterar viewport nem prometer escala final pixel-perfect em1920x1080, que precisa tratamento na integração. Previews inteiros3x.

Painéis sugeridos: player144x32; dash144x28; alvo144x32; salas84x32; instrumento84x48; moldura9-slice24x24 com6px de canto. Fontes5x7 com linha9/acentos, avanço6. Ícone dash16x16; relógio24x24,17 passos0..16; retratos24x24 com crop sem escala fracionária; gauge semicircular ~36x20 com agulha separada e estados de estudo. Ajustes pequenos permitidos quando necessários à legibilidade, registrar no manifesto em vez de forçar texto para fora do painel.

Barra: trilho vazio e fill âmbar/vermelho em arquivos/layers separados; fill sem células e sem números colados, clipping em pixels inteiros pela razão HP/max. Corners/trilhos com margens explícitas e interior útil descrito. Preview3/5 deve preencher3/5; alvo4/6 preencher2/3, não comprimento aleatório. O tamanho do painel não depende da quantidade deHP. Não inventar unidades de dano/vida.

Fonte própria: A–Z,0–9, espaço e sinais /,:.-% além dos acentos necessários a ACELERAÇÃO e demais labels PT-BR. Exportar atlas e json com codepoint, rect e advance; .aseprite editável. Uma fonte BMFont .fnt opcional é permitida se consistente, sem integração Godot nesta etapa.

## Distribuição ajustável

Coordenadas nativas576x324 propostas: player(8,8); dash(8,44); alvo(216,8); salas(484,8); acelerômetro(484,44). Margem8px =16lógicos, centro do combate livre. Mudança intencional em relação à prancha04: instrumento sai do canto inferior direito para baixo das informações de sala, preservando leitura do chão e passagem lateral. Dimensões propostas permitem colunas e centro separados; verticalidade/procedural continua influenciando possíveis sobreposições durante jogo e exige avaliação futura. Não afirmar que esta composição é universalmente livre de oclusão em todas as seeds.

Todos anchors/rects e escala em layout.json; todos módulos separados em layers no arquivo de composição para reacomodar. O painel de alvo neste estudo se inspira na separação do chefe em Hades, mas o critério de seleção é a mira solicitado pelo usuário, não mecânica copiada de outro jogo. Nenhuma lógica de targeting é implementada agora.

## Arte editável e exportação

Kit deve conter painel base9-slice, variações ou exemplo de módulos, barras vazias e fills, dash pronto/disabled, clock com estados normalizados (convenção explicitada, não usar timing autoritativo), dial/agulha, retratos existentes recortados, bitmapfont, composição/overlay e folha de componentes. .aseprite com layers/tags identificados em nomes legíveis e .lua reprodutível. PNGs com padding/retângulos documentados para evitar bleeding no futuro atlas. Elementos dinâmicos separados das amostras. Nenhuma prévia pode ser chamada de runtime executado ou asset auditado. Sem escrita fora da pasta nova do kit pelo implementador.

## Refinamento prospectivo R2 — contratos fechados antes da produção

Aceitar ajustes concretos de Gemini/Muse/Grok: painéis player/alvo passam a144x36 e dash144x40, para interior9-slice de6px acomodar retratos/relógio24px e texto de recarga. Player(8,8), dash(8,48), alvo(216,8), salas(484,8), instrumento(484,44) em576x324. Dimensões restantes84x32/84x48; grade/margens são de estudo e editáveis. Conteúdo limitado ao interior, cantos6x6 contêm todos parafusos, sem rebite no trecho central esticável.

TrilhoHP96x14, interior90x8 com margem3. Fill separado90x8, sem números. Exemplos3/5=54pixels e4/6=60pixels exatos. Regra futura documentada: clamp(floor(larguraútil*HP/max+0.5),0,larguraútil), maxpositivo; é quantização visual, sem regra de dano. Extensões do trilho respeitam cantos e arredondamento explícito.

Clock24x24:17estados, índice0=PRONTO/vazio,16=RECARREGANDO/cheio; remaining=index/16. Revealar/limpar em sentido horário desde12h conforme elapsed=1-remaining. Máscara cinza restante começa no ângulo de elapsed e vai até completar a volta; ponteiro indica elapsed. Não é tempo em segundos, FPS ou cooldown do dash. Valores0,3s e durações de animação de estudo são amostras. Não criar novas cargas de ação.

Fontemínima: A–Z,0–9, s minúsculo para segundos, espaço, /,:.-%, e ÁÀÂÃÉÊÍÓÔÕÚÇ. São labels em maiúsculas: VIDA, DASH, RECARREGANDO, PRONTO, ANDAR, SALA, TRANCA-LATA, COSPE-REBITE, ACELERAÇÃO, DA BOLA, CONCEITO, ÁREA LIMPA. Body5x7, ascenderdeacento2px, glyphbounds5x9, avanço6, linha10, baseline8 (zero-based) para todos, sem mover baseline por acento. Compor rótulos semtexto fora do interior; ajustes mínimosdeposiçõesdocumentados.

Exceção explícita de paleta: molduras/barras/fontes/ícones novos usam paletaHUD fixa; retratos copiampixels das fontes originais e preservam sua paleta preexistente. Registrar path e crop exato24x24 de cada retrato no manifesto, sem redimensionar64→24 ou recolorir identidades. Composição de cenário também usa paletasoriginais, e não afirma limite19coresglobal doatlas com retratos. Podem ficar ematlas distinto para não confundir paletaHUD.

Fontes reais: assets/player/player-animations.png, assets/enemy/training_target/training_target-atlas.png, assets/enemy/rivet_worker/rivet_worker-atlas.png. Cropdeheadescolhidopeloautor aoinspecionarfonts e documentado, janela24x24 sem escala. Fundo: assets/environment/factory_v1/background_floor1/modular/context-seed-000.png (1152x648, redução2x inteira/nearest para576x324); context-seed-0.png não existe. Criar novos pais assets/ui apenas para abrigar pastaautorizada, sem tocarassets/enemyexistentes.

Manifestos sugeridos: palette.json, atlas.json (padding2px transparente, rectseparadoexcluipadding), layout.json (nativos/escala/anchors/interiores), font.json (codepoint/rect/advance/lineheight/baseline) e portraits.json (source/crop). README defineconteúdo editável versus montagemexemplos. Registrar app.version realAseprite na geração (ou metadadosdobinário), sem inventarversão.

## Refinamento final R2.1 — achados de Opus avaliados pelo principal

P1-1 fechado: dash144x40, interior132x28. Ícone16 + gap4 + clock24 + gap4 + texto72 =120px, dentro132. Texto em DUAS linhas: DASH e tempo na primeira (no mesmo bloco), RECARREGANDO ou PRONTO na segunda. Não colocar os três textos lado a lado em uma linha nem três linhas altas. Player/alvo144x36 comportam24px com margens6; salas84x36. Manter fileiras superiores y8; dash e instrumento y48. Este override prevalece sobre dimensões iniciais.

P1-2 fechado: fonte body5x7, acentos2px acima e cedilha2px abaixo. Célula5x11, baseline8 (linha de base zero-based), lineheight12, advance6. Letras sem acento mantêm o baseline. Dash usa duas linhas12px dentro28; salas duas linhas dentro24. Instrumento84x60: título ACELERAÇÃO em cima, DA BOLA abaixo, dial37px (largura ímpar, pivô central inteiro) com área21px de altura abaixo das labels. CONCEITO pode ser etiqueta separada de preview acoplada, não número ou regra final. Não cortar acentos para forçar altura.

P1-3 é condicional e não procede para os fontes reais lidos: scenes/player.tscn AnimatedSprite2D e RacketHead têm scale(2,2); contextPreview do Lua do fundo faz pasteNearest(...64x64...,2), bg2x e chão/plataformas2x. Logo os pixels do mundo e HUD são ambos nativos no576x324, exibidos2x em1152x648. A redução do contexto pré-renderizado1152→576 por amostra inteira 2 preserva essa grade; não é redimensionamento interpolado. Exportar também contexto1152x648/HUD2x para comparação no espaço lógico. Preview1728x972 é3x da grade nativa; não alegar ajuste final para1920x1080. Isto vem da leitura, não testeengine.

Layouts/posição: usuário autorizou estudar distribuição para ajustar. Não é preciso uma aprovação nova para mover o instrumento em uma composição de estudo; manter layers movíveis e documentar posição original inferior direita e alternativa superior direita, com ambos anchors emlayout.json. A geração terá a alternativa superior como preview; nenhuma cena real será alterada.

Fontes/retratos, relógio e fill seguemR2 explícito. Glyphset inclui s minúsculo; nomes atuais cabem, futuro nome longo tem área de recorte e truncamento por largura (layoutmetadata), sem inventar nomes novos. Capacidade de amostra numérica até999/999 é só limite visual de teste de desenho, nãoHPmáximo de jogo; números de produção são externos.

Estrutura final nova: source/ com Lua e .aseprite; export/ com PNGs/atlas/font/JSON/palette; preview/ com composição/contextos/folha. .gdignore novos emsource epreview para futura importação automática não tratar estudo como runtime. Sem abrirGodot ou forçarimports. Aseprite confirmado1.3.18.6 porVersionInfo; Lua registraapp.version. CLI root e script em argumentos separados/aspados, paramsANTESscript. Ler stdout/stderr e confirmar arquivos de saída da geração, sem audit/teste.

Fonte da instruçãoGrok4.6: texto AGENTS fornecido diretamente pelo usuário nesta conversa, seção “Grok4.6XHighFast viaCursorAgentCLI”; prevalece sobre4.7 local. Muse sempre opencode-go/muse-spark-1.3-contributor --variant xhigh --agent plan, registrado nos comandos/saídas. Nenhum substituto silencioso.

Ordem do writer:1paleta/molduras/barras;2fonte;3clock/gauge;4retratos;5atlas/metadados;6composições/previews. Timeout produção45min em vez30 diante do escopo integrado; informar se limite ameaçado e congelar resultado coerente, sem declararkitcompleto com arquivosfaltando. Sem agentes escritores adicionais no diretório compartilhado.

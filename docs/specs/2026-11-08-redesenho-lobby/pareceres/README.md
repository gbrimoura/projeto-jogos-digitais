# Pareceres — fundo original do lobby

Implementação delegada a GPT-6 Luna, esforço xhigh. A interface nativa não permite selecionar ou confirmar priority nesta execução. Prévia estática produzida no Aseprite com o idle do protagonista em 2× nearest, o piso em y=560 e a porta nos estados aberto, parcial e fechado. O PNG de produção é RGB 1672×941 e seu SHA-256 coincide com a fonte.

## Rodada inicial

- Snapshot do diff SHA-256 `dc862d36091d05d53536451d555ec4e09f49ca604d3ad9f86616295f903e6024`, árvore Git `106cd2dbf4ed0b1ea25f0fe0ee55771c0ce143a3`, base `3f879f09818d49fd36782b197dd653c17aada772`.
- Muse Spark 1.3 Contributor / xhigh via OpenCode 1.17.13, exit 0. Parecer útil, condicionado à conferência do encaixe e da renderização. A inspeção do principal verificou a cápsula 28×76 no vão 102×106, a cabine aberta no PNG, a largura e a altura da fonte e o filtro NEAREST definido no letreiro. O teste na engine ficou pendente.
- DeepSeek V4.1 Flash / max via OpenCode, exit 0, término por limite de saída, sem texto de parecer. Revisão adversarial pendente, sem substituição. Os eventos do OpenCode não expuseram metadados para confirmar modelo e esforço efetivos.
- Claude Opus 5.5 / high via Claude Code 2.1.319, exit 0. O modelUsage confirmou claude-opus-5-5. O parecer inicial apontou questões sobre a importação, o encaixe e a documentação. A conferência mostrou que o letreiro força NEAREST e comporta as duas linhas, a cena usa canvas_items e as constantes removidas não têm consumidores externos. O índice e a proveniência foram corrigidos. O diff do produto permaneceu idêntico entre as rodadas.

## Revisão final

- Snapshot do diff SHA-256 `b2cdc6754e545db51f34d5db2cdf98cf19dd49fe912cea3290fd32b8993fbed9`, árvore Git `23146fe7fafa519cba9630e242108189baac68ae`.
- Claude Opus 5.5 / high via Claude Code, exit 0. O modelUsage confirmou claude-opus-5-5. Aprovado no escopo estático. O esforço high foi selecionado na chamada e não é discriminado no modelUsage.
- O principal conferiu por leitura e composição estática que o piso coincide com a colisão, a arte cobre o lobby, as folhas não invadem a moldura e os indicadores permanecem visíveis durante o fechamento.
- A PNG nova precisa da importação normal do Godot antes da execução com cache limpo. Importação, parse e teste de embarque na engine continuam pendentes. O registro dos pareceres foi acrescentado após a revisão e não altera o produto.

Saídas originais e metadados de execução ao lado deste registro. Os revisores foram executados em modo somente leitura, com diffs inline e limite externo de 600 segundos por processo. A negação efetiva de ferramentas foi conferida no perfil plan do OpenCode. Claude usou restricted, MCP vazio e ferramentas built-in desabilitadas.

## Importação autorizada

Godot 4.7.2 executou a importação headless em 08/11/2026 com exit 0. A PNG do lobby gerou o metadado .png.import e o .ctex correspondente. A compressão é sem perda, sem mipmaps, e o SHA-256 da fonte permaneceu idêntico. Houve um aviso conhecido de UID duplicado entre scenes/main.tscn e a cópia de referência do fundo do primeiro andar. A partida e o embarque não foram executados.

## Correção do erro de parse em 08/11/2026

O Godot apontou bool no quarto argumento de draw_texture_rect_region em scripts/world/lobby_visual.gd:77. A correção remove esse argumento opcional e usa a modulação branca padrão. Os retângulos de destino e de recorte, bem como os demais bytes do script, foram preservados.

- SHA-256 do diff incremental revisado: ebc5a8c293ec0589782d3caa2904a91fa45db8e68bfb5e3ba268071359d3d9c2.
- SHA-256 do script corrigido: B340294AE3EF6578869456295F33EC3D6023C103D9D53814BF3592B5F35E9548.
- Implementação delegada a GPT-6 Luna xhigh. A interface não ofereceu seletor verificável de priority.
- Muse Spark 1.3 Contributor xhigh e DeepSeek V4.1 Flash max, via OpenCode 1.17.13, retornaram parecer favorável e exit 0, em série, com ferramentas negadas. Os metadados de modelo e variante efetivos não foram expostos.
- Claude Opus 5.5 High via Claude Code 2.1.319, modo restrito, exit 0 e revisão estática favorável. O modelUsage confirmou claude-opus-5-5, com high selecionado na chamada.
- A alteração de uma linha foi conferida por comparação com o original e git diff --check. O Godot não foi executado nesta correção.

## Harmonização da placa e do protagonista em 08/11/2026

- Implementação e correções com GPT-6 Luna xhigh. Priority não pôde ser selecionado na interface. A primeira frente foi encerrada no limite após entregar a primeira versão; outra frente Luna concluiu a integração e tratou os achados.
- Snapshot inicial SHA-256 852f938562d07123862d6a5b36272628d66caead740b55c37501b84dd7628fe0. Muse fez a revisão por leitura. DeepSeek atingiu o limite de saída sem parecer. Opus encontrou falta de espaço para a segunda linha do letreiro e ornamentos ocultos pela camada de esmalte. A verificação local também encontrou que o RacketVisual substituía o material no _ready, o que impedia a aplicação da paleta.
- Delta final SHA-256 3fd38da5b7f183add94c67d860e32c2af7147bc77f5bb2a8e3aff68b18919d62. A segunda linha ganhou tamanho secundário e espaço próprio. Os ornamentos ficam sobre o esmalte. O lobby troca o shader do mesmo ShaderMaterial criado pelo RacketVisual, preservando a máscara e a modulação do sprite. Os arquivos do fundo e do player compartilhado foram conferidos por SHA-256.
- Muse Spark 1.3 Contributor xhigh e DeepSeek V4.1 Flash max deram parecer favorável ao delta final em série com ferramentas negadas. Os eventos do OpenCode não expuseram os metadados de variante efetiva. Claude Code confirmou claude-opus-5-5 em modelUsage, com high selecionado, e aprovou a integração estática. Não há achado acionável restante. O gerador por basename só resolve a partir da própria pasta, onde o fallback '.' aponta ao local correto. Os guards do material são deliberados para que a aparência opcional não impeça carregar o lobby se a hierarquia do Player mudar. O caminho e o material atuais foram conferidos na leitura.
- Aseprite 1.3.18.6 regenerou a placa e a prévia estática 1152×648, que foi inspecionada. Godot 4.7.2 importou a revisão final com exit 0 e compressão sem perda. Segue o aviso conhecido de UID duplicado da cena antiga de referência. A partida e a aparência em movimento não foram executadas.

## Animação ambiente do fundo em 08/11/2026

- Implementação de GPT-6 Luna xhigh. A interface não ofereceu seletor verificável de priority. Snapshot SHA-256 do diff incremental 5292e4890bd112497342d2a6ed2e2c2689252378cc89cf72ea65723a9e833c3e. Os quatro hashes foram reconferidos após a revisão.
- O backdrop usa a PNG existente em Sprite2D com material local. As nuvens oscilam ±28 px da fonte em 36 s. A máscara tem transições nas faixas x=58..142, x=920..1020 e y=230..275; os 58 px mencionados no plano são a margem esquerda até o início da máscara. Seis pontos de luz têm pulsos locais de atenuação de até 22%. Os períodos 4, 6, 9 e 12 s fecham no ciclo de 36 s.
- Muse Spark 1.3 Contributor xhigh retornou parecer favorável condicionado à conferência em engine. DeepSeek V4.1 Flash max atingiu o limite de saída sem emitir parecer, apesar de exit 0. Os eventos do OpenCode não expuseram os metadados de modelo e variante efetivos.
- Claude Opus 5.5 High via Claude Code retornou parecer favorável com ressalvas estáticas e exit 0. O modelUsage confirmou claude-opus-5-5 e o esforço high foi selecionado. A busca local confirmou que nenhuma referência às variáveis removidas permaneceu. EnvironmentVisual não tem outro filho de cena, portanto adicionar reordenação preventiva não é necessário para o estado entregue. O project.godot não sobrescreve o rollover de TIME. A conferência da imagem confirmou que as construções ficam fora da zona amostrada.
- A PNG original mantém SHA-256 EFD6187F0BED422C2C21AE2380D1DB1B433A449894A38A0DF8D2152E133DE52C e seu cache de importação existente. A cena do lobby ficou idêntica à baseline deste incremento. Git diff --check passou. Sem execução, reimportação ou testes no Godot nesta rodada.

## Letreiro superior SELENITE TOWER em 08/11/2026

- Arte em Aseprite 1.3.18.6. O PNG de 128×22 foi reimportado pelo Godot 4.7.2 com exit 0 e compressão sem perda. SHA-256 final E2AE740E148F5A66A88568C12D0231FCA2276C677C5BC4240B829B1B604B6B29. Prévia estática 1152×648 inspecionada, com a placa em (893,111), sobre a fachada. O PNG do fundo e os shaders existentes conservam seus hashes. A partida não foi executada nesta rodada. O aviso conhecido de UID duplicado da cena de referência permanece.
- GPT-6 Luna xhigh fez a arte, a integração e os ajustes. A interface não expôs seleção de priority. Na rodada inicial 57f3f4fc8a04aebcfeb73d719b5dbb71ecf83c9d6d0d8cf1a1e75f2f2dbbdbfe, Muse conferiu o encaixe. O gerador foi ajustado para que a ausência da prévia antiga não impeça a geração dos assets.
- Snapshot R2 188ec6f32907a7d52ac18da8b7a5657152256a265341171c89113e84ad53d63a. Muse e DeepSeek deram parecer estático favorável. Opus apontou frisos cobertos pelo esmalte e a folga da última letra. Os frisos passaram para cima do esmalte, e os ornamentos ficaram separados da sombra do R.
- Delta final R3 05182826e1edf0dbbb84966921ea4f9d5499d2da249888778b5f83f7a5bdee8b. Muse Spark 1.3 Contributor xhigh e DeepSeek V4.1 Flash max retornaram parecer favorável em série, com ferramentas negadas. A saída do OpenCode não expôs metadados de modelo e variante efetivos. Claude Code confirmou claude-opus-5-5 no modelUsage, com high selecionado, e aprovou a correção. Os hashes do snapshot integrado foram reconferidos.

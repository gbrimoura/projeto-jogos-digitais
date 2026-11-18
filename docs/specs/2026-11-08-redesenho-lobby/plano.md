# Plano — fundo do lobby com arte original

Data: 08/11/2026. Status: implementação autorizada em branch redesenho-lobby.

## Objetivo

Integrar ao lobby a imagem gerada já aprovada e examinada pelo principal, mantendo o arquivo original byte a byte. A imagem substitui o backdrop, o piso visual e os limites laterais desenhados antes; a torre/elevador, oficina, cidade e piso embutido ficam como uma composição única. O alvo é preservar o fluxo de entrada no elevador e a física já existente.

## Geometria decidida

A fonte é RGB 1672×941, SHA-256 EFD6187F0BED422C2C21AE2380D1DB1B433A449894A38A0DF8D2152E133DE52C. Sua linha de piso está aproximadamente em y=808; o vão visível está em x=1317..1466 e y=655..807. O desenho usa origem (0,0), largura lógica 1152 e escala vertical 560/808 para que o topo do piso coincida com a colisão em y=560. A borda inferior estende cerca de 4 px além do viewport de referência, abaixo do piso; não se corta a torre nem se reamostra o arquivo de origem.

O vão lógico compartilhado é Rect2(908,454,102,106). A mesma constante do script visual alimenta o gatilho do lobby. Duas folhas opacas reutilizadas de V1 medem 51×106 no espaço lógico quando fechadas, encontram-se no centro do vão, deslizam durante o mesmo door_closed_fraction e são recortadas geometricamente ao retângulo do vão em todos os quadros. Nenhuma folha aparece sobre a moldura ou detalhes do fundo. O texto/plaque diegética pode ajustar somente sua colocação para apontar ao vão.

## Escopo

- scripts/world/lobby_visual.gd: textura normal do Godot; remover o atlas e as massas que a nova imagem substitui; compartilhar geometria; conservar luz/evento e interface pública existentes.
- scripts/world/lobby.gd: usar o mesmo retângulo do vão como área de entrada; preservar AABB, estado de vida/chão e a sequência de viagem.
- scenes/lobby.tscn: somente mover/redimensionar o nó de letreiro se a prévia confirmar necessidade.
- assets/environment/factory_v1/lobby_v2/**: uma cópia exata da imagem original e proveniência. Folhas vêm de lobby_v1, sem duplicação de PNG.
- docs/specs/2026-11-08-redesenho-lobby/** e docs/README.md: especificação, snapshots e registro do trabalho.

Filtros: linear na textura grande, que será ampliada levemente até 1920×1080; nearest nas folhas pixeladas; letreiro continua usando seu atlas nearest. Nada de trocar filtro de importação, paleta, mipmaps ou conteúdo da imagem.

## Fora do escopo

Sem alterações de física, colisões, câmera, spawn, jogador, controles, fluxo de cena, lógica da run, atlas/piso/laterais V1 ou addons. Não executar Godot, editor, importação, parser, testes ou lint. Sem commit, push ou mudança de branch.

## Sequência e aceite

1. Registrar o estado e hashes atuais em historico/baseline/ antes de editar produto.
2. Copiar a PNG fornecida byte a byte para lobby_v2/ e conferir hash igual à fonte.
3. Integrar imagem e vão compartilhado; atualizar letreiro somente se a prévia estática mostrar sobreposição relevante.
4. Fazer uma prévia estática fora da árvore res:// com personagem e limites de encaixe, se Aseprite real permitir.
5. Congelar diff/hash para as revisões somente leitura do principal.

Aceite: hash de origem idêntico; uma única cópia runtime; fundo completo composto em 1152×648 com piso visual em y=560; vão visual, folhas e gatilho usam a mesma geometria; as folhas fechadas cobrem o vão e nunca saem dele durante a animação; colisão e fluxo permanecem inalterados; arte do fundo não é redesenhada ou reamostrada.

## Adendo prospectivo — identidade da placa e paleta local do protagonista (08/11/2026)

Este incremento autorizado acrescenta, sem alterar o histórico anterior, uma plaqueta art déco de latão/esmalte escuro 94×30 produzida em Aseprite real com Lua reproduzível e fonte editável; troca a renderização da placa/HUD diegética existente por esse sprite, preservando as lâmpadas dinâmicas e o bitmap_text do status de transição. Acrescenta também uma grade sRGB moderada apenas no AnimatedSprite2D da instância do jogador no lobby, sem alterar o player global, frames, alpha, animações, controle, demais HUD/cenas ou a PNG original do fundo. Arte e fonte ficam em assets/environment/factory_v1/lobby_v2/sign/; o shader, se usado, e demais alterações permanecem nos caminhos de produto autorizados. A prévia estática Aseprite deve mostrar o fundo 1152×648, placa nova e o frame idle real no spawn a 2× nearest; registrarei explicitamente qualquer aproximação.

Baseline anterior ao produto, preservado fora do repositório em `C:/Users/danie/AppData/Local/Temp/codex-lobby-v2-palette-baseline-2026-11-08/` (`SHA256SUMS.txt`): `scenes/lobby.tscn` A3F0F5867DC3FB83E678CE71B7143649ABD23F505627A5A95415D887D54DD210; `scripts/world/lobby.gd` E2256337057FD5F3EA9BB3906C62A5C98AF78D11448CCA0FD415CBC265D03503; `scripts/world/lobby_visual.gd` D0FC15943FFE1D7B4A415C11A8B5C421E6FE7E36944375541F7CF17AB1CA3539; fundo PNG EFD6187F0BED422C2C21AE2380D1DB1B433A449894A38A0DF8D2152E133DE52C; prévia existente `lobby-v2-clean-open-preview-1152x648.png` AFF64A156E027EE44E3641313F4BC48AD2436662E2C1123AB2F6F7C7F8204ECE. Cópias binárias dos quatro arquivos e a prévia anterior estão no diretório citado. A hash da PNG será reconferida após a implementação.

## Adendo prospectivo — movimento ambiente do fundo (08/11/2026)

Acrescenta `BackdropMotion`, um `Sprite2D` filho do `EnvironmentVisual` com `show_behind_parent`, textura original sem alteração, escala `1152/1672` × `560/808`, filtro linear e `ShaderMaterial` local. O shader desloca horizontalmente apenas nuvens na faixa segura da fonte (x=58..1020, y<275), com margens esmaecidas de pelo menos 58 px em relação ao deslocamento máximo de 28 px. O seno percorre um ciclo real de 36 s e retorna à mesma posição/velocidade; esse período divide o rollover de 3600 s de `TIME`. Pulsos suaves e assíncronos escurecem no máximo 22% apenas pixels quentes dentro de áreas pequenas nas luzes da oficina, elevador e antenas; as frequências são múltiplos inteiros da fase de 36 s, portanto também fecham no rollover. A textura não se move como um todo: torre, postes, horizonte, alvenaria, jogador, placa, piso, câmera, colisões e fluxo continuam imóveis; os três LEDs de viagem seguem no código existente. Nenhum asset de imagem é criado. Sem execução/import/testes; validação do shader/runtime permanece pendente.

## Adendo prospectivo — placa de luxo SELENITE TOWER (08/11/2026)

Integra uma placa Sprite2D diegética e pixelada na fachada central, abaixo do farol, centrada em x=957 e no recorte aproximado x=893..1021, y=111..133. A arte 128×22 usa Aseprite real, fonte Lua reproduzível, chanfros e frisos simétricos de latão polido, esmalte petróleo e letras ouro claro com o texto exato `SELENITE TOWER`. A cena da placa mantém `z_index=-9`, filtro nearest e raiz Sprite2D; o PNG original, farol, antenas, núcleo, lógica/câmera/jogador e placa do elevador ficam preservados. A prévia estática parte da imagem harmonizada anterior e é salva com novo nome em Temp; não é validação de runtime.

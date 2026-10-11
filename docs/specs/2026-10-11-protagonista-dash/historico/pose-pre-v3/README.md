# Protagonista — dash v2

Esta revisão substitui a pose frontal inclinada por três desenhos novos de
movimento em perfil, mirando à direita (+X). O gerador usa grades de pixels e
traços articulados; não transforma, cisalha nem gira o sprite frontal. A fonte
de entrada continua sendo a caminhada v3, e seus doze quadros aprovados de idle
e walk permanecem intactos.

## Pose lateral

- O capacete creme/branco mantém antena e módulo lateral azul/amarelo. O visor
  preto fica na face voltada para +X e mostra uma única lente ciano.
- O tórax azul/amarelo e a cabeça se projetam à frente dos quadris.
- Os dois braços recuam durante o impulso. As pernas flexionam, uma atrás e
  outra à frente, ligadas aos quadris.
- Cada pose mantém uma bota próxima do apoio visual em y=56/57.
- Impulso, avanço e sustentação duram 40, 40 e 60 ms.

## Fonte, paleta e atlas

- Canvas: 64×64 px por quadro, alpha apenas 0 ou 255.
- Paleta: 27 cores existentes da arte aprovada do protagonista.
- Tags: idle em frames 1–6, walk em 7–12 e dash em 13–15; dash toca uma vez.
- O script restaura os intervalos das tags originais depois de anexar os quadros,
  pois o Aseprite expande automaticamente a última tag.
- Atlas horizontal: 15 quadros, 960×64 px; idle 0–5, walk 6–11, dash 12–14.
- Nome padrão da fonte combinada: protagonista-dash-v2.aseprite.

## Gerar a fonte combinada e o atlas

Use Aseprite 1.3.18.6. O parâmetro out indica a pasta de saída,
source_aseprite aponta para a fonte walk v3 e base altera o prefixo, se preciso.

~~~powershell
$ase = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
$assetDir = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash'
$walkSource = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk/protagonista-walk-v3.aseprite'
& $ase -b --script-param "out=$assetDir" --script-param "source_aseprite=$walkSource" --script (Join-Path $assetDir 'protagonista-dash.lua')
& $ase -b (Join-Path $assetDir 'protagonista-dash-v2.aseprite') --sheet-type horizontal --sheet (Join-Path $assetDir 'protagonista-dash-v2-spritesheet.png') --data (Join-Path $assetDir 'protagonista-dash-v2-spritesheet.json')
~~~

O PNG é o atlas horizontal de 960×64. A integração ao runtime e os arquivos
binários exportados são gerenciados pelo agente principal.

## Prévia horizontal demonstrativa

O script protagonista-dash-preview.lua usa o atlas
protagonista-dash-v2-spritesheet.png e cria por padrão
protagonista-dash-horizontal-v2.aseprite. A sequência mostra o robô correndo
para a direita, segurando a pose e retornando espelhado para a esquerda.

~~~powershell
& $ase -b --script-param "out=$assetDir" --script-param "source_sheet=$assetDir/protagonista-dash-v2-spritesheet.png" --script (Join-Path $assetDir 'protagonista-dash-preview.lua')
~~~

A prévia demonstra o deslocamento. O atlas do jogo mantém as poses ancoradas no
pivot e a física existente move o personagem. Esta alteração não muda controles,
velocidade, duração do dash, colisões ou cenas.

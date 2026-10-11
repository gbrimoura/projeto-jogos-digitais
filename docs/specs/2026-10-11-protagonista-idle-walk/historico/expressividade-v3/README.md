# Protagonista — caminhada frontal v2

Esta revisão corrige a articulação das pernas do ciclo walk. Ela preserva o
idle v2 aprovado quadro por quadro e reconstrói o quadro 0 de walk exatamente
a partir da mesma pose. A cabeça, o torso, a paleta de 27 cores e o uso no
Godot permanecem iguais.

## Animações

- **Idle:** seis frames de 420, 140, 180, 140, 540 e 80 ms, copiados do idle v2.
- **Walk:** seis frames de 100 ms (10 fps), total de 600 ms por ciclo.
- **Corpo:** braços alternam até 1 px; o corpo sobe 1 px nos mesmos quadros de
  balanço da bota (walk índices relativos zero-based 2 e 5).
- **Pernas:** as quatro linhas superiores do recorte de cada perna mantêm o
  quadril ancorado. O joelho e o tornozelo articulam por linhas de pixels com
  deslocamentos de até 1 px para dentro. Nos quadros walk de índices relativos
  zero-based 2 e 5 (3ª e 6ª poses), uma bota inteira sobe 1 px em cada passada; o
  pé oposto permanece apoiado. O deslocamento horizontal do pé é de no máximo
  1 px e retorna ao centro no arco da passada. Ao subir, o início da bota se
  sobrepõe intencionalmente ao tornozelo na linha y=53, fechando a junção sem
  abrir uma fenda nem acrescentar uma ponte separada de pixels.
- **Direção:** o Godot espelha o mesmo ciclo para a esquerda com `flip_h`.
  O idle mantém a orientação frontal aprovada.

As pernas continuam em camadas editáveis separadas. O script usa somente
pixels e cores já presentes no quadro aprovado; o quadro-base, as dimensões
64×64 e a integração no Godot não mudam. O metadata gerado pelo script registra
a articulação, os dois quadros de balanço, a sincronização do bob, os limites
de deslocamento e a regra de apoio alternado.

## Recriar no Aseprite

O projeto usa Aseprite 1.3.18.6. Passe caminhos absolutos para evitar depender
do diretório corrente. O nome padrão da nova saída é
`protagonista-walk-v2`, preservando os arquivos da revisão v1.

```powershell
$ase = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
$walkDir = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk'
$idleSheet = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-idle/protagonista-idle-v2-spritesheet.png'
& $ase -b --script-param "out=$walkDir" --script-param "idle_sheet=$idleSheet" --script (Join-Path $walkDir 'protagonista-walk.lua')
& $ase -b (Join-Path $walkDir 'protagonista-walk-v2.aseprite') --sheet-type horizontal --sheet (Join-Path $walkDir 'protagonista-walk-v2-spritesheet.png')
```

`palette.json` registra a paleta herdada. `protagonista-walk-metadata.json`
registra o layout, as durações, as regiões de máscara e os limites da correção
de pernas.

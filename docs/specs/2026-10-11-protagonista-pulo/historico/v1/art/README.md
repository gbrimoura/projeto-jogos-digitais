# Protagonista — pulo frontal

Três poses compactas de subida, ápice e queda, derivadas do idle frontal aprovado. Cabeça e torso mantêm a referência. Braços acompanham um arco curto; botas recolhem 2 px na subida e 4 px no ápice, e retornam à posição de apoio na queda.

- Fonte Aseprite: `protagonista-pulo.aseprite`
- Script: `protagonista-pulo.lua`
- Entrada congelada: `protagonista-pulo-input-atlas-1088x64.png`
- Atlas 20×64 px: `protagonista-pulo-spritesheet.png` / `.json`
- Contact: `protagonista-pulo-contact.png`
- Previews em arco vertical: `protagonista-pulo-preview-esquerda.gif` e `protagonista-pulo-preview-direita.gif`
- Metadata: `protagonista-pulo-metadata.json`

## Recriar com Aseprite 1.3.18.6

```powershell
$ase = 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe'
$dir = 'C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo'
$base = Join-Path $dir 'protagonista-pulo'
$input = Join-Path $dir 'protagonista-pulo-input-atlas-1088x64.png'
& $ase -b --script-param "out=$dir" --script-param "atlas=$input" --script (Join-Path $dir 'protagonista-pulo.lua')
& $ase -b ($base + '.aseprite') --sheet-type horizontal --sheet ($base + '-spritesheet.png') --data ($base + '-spritesheet.json')
& $ase -b ($base + '-preview-esquerda.aseprite') --scale 6 --save-as ($base + '-preview-esquerda.gif')
& $ase -b ($base + '-preview-direita.aseprite') --scale 6 --save-as ($base + '-preview-direita.gif')
```

Os GIFs movem o sprite verticalmente para demonstrar o arco. Essa translação e a linha de chão não fazem parte do atlas runtime; no jogo, posição e salto continuam sob a física atual do Player.

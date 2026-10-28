# Especificação — Porta lateral como abertura na parede

**Estado:** implementação visual autorizada em 18/10/2026; runtime permanece sem verificação.  
**Leitura:** `docs/README.md`, `AGENTS.md`, plano/spec/pareceres de geração de salas e plano/spec/registro anteriores da porta, e GDD `04-combate-e-builds.md` §3.4.

## Geometria visual

- Parede lateral esquerda: x=0..64; direita: x=1088..1152. As duas paredes visuais deixam de desenhar exatamente y∈[432,560) (128 px), atravessando toda a espessura lateral de 64 px e abrindo na borda externa da sala. A soleira termina no topo do piso y=560.
- O helper `factory_wall_visual.gd` tem parâmetros visuais exportados `opening_top` e `opening_height`; defaults não criam abertura para chamadas atuais fora das salas. Instâncias de parede nas duas salas recebem topo 432 e altura 128.
- Os tiles de parede são recortados na vertical no limite do vão, mantendo nearest e sem faixa por cima do corte. A parede física de 64×648 continua contínua e intacta.
- `SideDoorVisual` substitui `DoorArt`: é uma vista do túnel no perfil lateral, não um painel na parede de fundo. O recorte é escuro e tem lintel/ombreira discretos usando somente cores do tileset/paleta da fábrica. Estado fechado mostra grade/folha dentro do túnel; estado aberto deixa o buraco visível. O vão não é fechado por uma moldura frontal e a imagem não se estende pelo cenário. O parâmetro `flip_h` inverte apenas o desenho da entrada; a raiz Area2D não é espelhada.

## Posição e estado

- Área da saída preserva raiz `(1040,522)` e sensor 96×108 (x=992..1088 no mundo). Centro do visual lateral: `(1120,496)`, offset local `(+80,-26)`, retângulo global x=1088..1152/y∈[432,560).
- Área da entrada preserva raiz `(112,522)` e sensor desativado. Centro do visual lateral: `(32,496)`, offset local `(-80,-26)`, retângulo x=0..64/y∈[432,560). Orientação do acabamento aponta para o lado interno do túnel.
- Ordem de desenho: fundo z=-10; WallVisuals z=-1 omite a área; `SideDoorVisual` também fica efetivamente em z=-1 (instanciado depois das paredes), cobrindo somente o recorte; atores continuam z=1. O piso existente começa y=560 e cobre a base sem invadir a abertura. Nenhuma outra parede é recortada.
- Entrada sempre fechada e sem interação. Saída usa Closed enquanto bloqueada/ocupada e Open liberada/terminal, preservando label e comportamento já existentes. O desenho de buraco é somente visual: paredes físicas e sensor permanecem como estão, assim como E, sinais, transição e fluxo de sala.

## Critérios estáticos

1. Não há mais sprite/painel frontal estendendo-se na parede de fundo; a abertura se limita à espessura lateral de 64 px.
2. O recorte visual atravessa a faixa x=0..64 ou1088..1152 em y∈[432,560), rente ao piso e sem pixel de parede pintado por cima.
3. A montagem estática `assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png` mostra ambas extremidades e estados fechado/aberto usando atlas e cores existentes; não é captura do Godot.
4. Apenas `factory_wall_visual.gd`, helper visual local, `exit_door.tscn`, `exit_door.gd` (apresentação) e overrides visuais das portas/WallVisuals em `main.tscn` e `second_room.tscn` são alterados.
5. Cópias prévias e hashes refletem o estado local incluindo alterações anteriores; nenhuma mudança é desfeita.

## Whitelist da implementação

- `scripts/world/factory_wall_visual.gd` — clipping visual opcional com default sem abertura.
- `scripts/world/side_door_visual.gd` — visual exportado do recorte, sem gameplay.
- `scenes/exit_door.tscn` e `scripts/world/exit_door.gd` — substituir somente o nó/atualização visual da porta.
- `scenes/main.tscn` e `scenes/second_room.tscn` — exports das duas WallVisuals e overrides visuais das portas.
- `assets/environment/factory_v1/door/side-opening/` — somente Lua e montagem estática de inspeção.
- `docs/specs/2026-10-18-porta-lateral/` — plano, spec, histórico/snapshot e registro; a pasta de pareceres e o índice ficam a cargo do principal.

## Limites

Não executar engine, import, testes, quality_audit ou QA automatizado. Não alterar colisões, sensores, física, geração, Main/RunController, combate, plataformas, jogador, assets existentes, `.import`, plugin/editor ou GDD. O estudo anterior `assets/environment/factory_v1/door/porta-fabrica-horizontal-v2.*` permanece intacto, mas não é usado em runtime.
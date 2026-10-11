# Implementação — dash do protagonista

O script Aseprite acrescenta três poses à fonte walk v3 carregada em memória e
salva a combinação em `protagonista-dash-v1.aseprite`. A camada nova usa pixels
da pose-base, deslocados em coordenadas inteiras; valida alpha binário, paleta
herdada e limites do canvas. A tag `dash` cobre os quadros 12–14 e repete uma
vez. A fonte walk v3 original não é salva nem editada pelo script.

O recurso `SpriteFrames` registra regiões dash em x=768, 832 e 896, com tempos de
0,04/0,04/0,06 s e `loop=false`. `PlayerVisual` reinicia o primeiro quadro na
entrada do dash uma vez, mantém o último quadro após a animação terminar enquanto
o estado continuar ativo e volta ao estado visual adequado ao sair. O código de
física/controlador e a duração de gameplay não foram alterados.

## Processo e validação

Implementador: subagente desta tarefa. A interface de delegação não permite
selecionar ou confirmar o modo Fast/priority exigido; essa limitação deve ser
registrada pelo agente principal na consolidação. Os arquivos da frente foram
congelados para revisão estática pelo agente principal.

Não foram executados Aseprite, Godot, testes ou `quality_audit`. A exportação do
PNG/Aseprite combinado e a inspeção visual dos novos quadros foram atribuídas ao
agente principal. As revisões estáticas obrigatórias e a conferência manual em
runtime continuam pendentes; nenhum parecer está sendo declarado como recebido.

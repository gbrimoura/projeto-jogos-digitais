# Especificação — sentinela de contenção

**Estado:** implementado; valores de combate locais provisórios para o protótipo.
**Data:** 14/10/2026.
**Baseline:** arquivos antes da implementação preservados em `historico/base/`, com hashes em `sha256-before.json`.

## Comportamento

`TrainingTarget` permanece imóvel e mantém sua caixa física existente de 72×96, os 3 HP, o flash de 120 ms, o HUD de vida, os grupos `damageable` e `combat_enemy`, o método `take_damage` e o sinal `defeated`. Enquanto o jogador vivo está dentro do círculo e tem linha de visão, a sentinela começa um golpe centrado na própria posição mais `attack_center_offset`.

Parâmetros locais iniciais: raio/detecção 140 px, offset `(0,0)`, dano 1, windup 0,65 s, janela ativa 0,14 s e recuperação 1,4 s. A detecção usa o mesmo círculo do acerto: não há zona oculta maior do que o aviso. Um jogador pode sair durante o windup e evitar o ataque; um jogador que entrar durante a janela ativa pode receber um único pedido de dano naquela janela.

A silhueta circular nativa é visível durante WINDUP e ACTIVE; sua circunferência é desenhada no mesmo raio consultado pela física, com margem da shape query igual a zero. Ao entrar em RECOVERY, ela desaparece por fade curto e então se oculta. A sentinela não segue o jogador; o centro é capturado no início do golpe.

Durante ACTIVE, o corpo reutiliza a animação Cartoon V2 impact como pose do golpe, sem shader flash. O shader de flash permanece ligado somente pelo timer já existente de dano recebido; quando há sobreposição, esse flash mantém prioridade e não é cancelado pelo golpe.

## Consultas de física e dano

- As consultas ocorrem somente em `_physics_process`, contra corpos reais com grupo `player`, camada física 2 e método `take_damage`; a cápsula configurada em `CollisionShape2D` participa da sobreposição.
- O raio de visão parte do centro travado e termina no centro global do `CollisionShape2D` do jogador. Máscara World 1; paredes e plataformas bloqueiam o golpe.
- Cada instância de jogador pode receber no máximo uma tentativa por golpe. A deduplicação é por `get_instance_id()` e é limpa no próximo golpe.
- A chamada é `Player.take_damage(damage, self)`. O script do jogador e seu estado de invulnerabilidade não são alterados; nenhum HP é escrito diretamente.
- Um avanço de física que ultrapasse o windup ainda avalia o começo da janela ativa antes de avançar para recuperação, evitando pular o golpe.
- Morte/remoção do inimigo, morte/remoção do jogador ou saída do nó da cena corrente cancelam e ocultam a ação. `defeated` é emitido uma vez e o inimigo usa `queue_free()` como antes.

## Integração

A cena é compartilhada pelas salas atuais. A alteração mantém caminhos, root `StaticBody2D`, caixa de colisão, camada e grupos. Não há `Area2D` persistente que possa interceptar projéteis. O visual usa primitives nativas e reutiliza idle/impacto da arte Cartoon V2 já instalada.

## Limites

Os parâmetros não representam balanceamento final. A integração é estática por instrução: sem Godot, importação, testes, gameplay ou QA nesta tarefa. Avaliação de leitura do aviso e sensação do golpe permanece pendente de observação manual no jogo.



# Registro de implementação — sentinela de contenção

**Data:** 14/10/2026.
**Estado:** código congelado para revisão estática.
**Base:** versão Cartoon V2 publicada antes desta alteração. Os arquivos anteriores e hashes pré-código estão em historico/base/.

## Alterações

TrainingTarget agora é uma sentinela estacionária. Foram preservados o path, StaticBody2D, shape 72×96, 3 HP, flash de 120 ms, barra de vida, grupos damageable/combat_enemy, take_damage, defeated e queue_free.

AttackState define IDLE, WINDUP, ACTIVE e RECOVERY. Valores locais provisórios: raio 140 px, centro (0,0), dano 1, aviso 0,65 s, janela ativa 0,14 s, recuperação 1,4 s e fade 0,18 s. Detecção, desenho e acerto usam o mesmo círculo. A detecção usa a cápsula física do jogador na camada 2. A chamada take_damage mantém a invulnerabilidade e os estados de vida sob controle do PlayerHealth.

Durante WINDUP o corpo mantém idle; durante ACTIVE toca a animação existente impact sem reiniciar o clip por quadro. O flash de dano tem prioridade e a recuperação volta a idle. containment_attack_visual.gd desenha a área em vermelho/laranja com primitives nativas, sem class_name ou física própria. A área aparece no aviso e no ataque, faz fade na recuperação e se oculta.

## Contratos conferidos estaticamente

- O centro é fixado ao começar WINDUP. A sentinela não anda nem rastreia o jogador.
- As consultas e todos os timers do ataque rodam em _physics_process. O círculo é consultado em cada passo ACTIVE, permitindo entrada durante a janela.
- Cada instance ID recebe no máximo uma tentativa por golpe; guarda limpa no golpe seguinte, fim da recuperação ou cancelamento. O retorno booleano de take_damage controla o flash âmbar de confirmação.
- O raycast parte do centro travado e termina no centro global de CollisionShape2D do jogador. World mask 1 bloqueia o ataque em paredes e plataformas; o próprio inimigo (layer 8) fica excluído.
- Se um passo físico ultrapassar o windup, o código ainda consulta o instante de ativação antes de avançar para recuperação.
- Morte/remoção do jogador, remoção do alvo ou saída de qualquer um da cena corrente cancela o estado, oculta o efeito e limpa a guarda. A derrota do alvo emite o sinal uma única vez.
- As salas atuais já instanciam a mesma cena e usam os grupos preservados. Nenhum outro runtime foi editado.

## Revisão e validação

O estado foi conferido por leitura estática das fontes e da cena. Não houve execução Godot, import, runtime, testes ou QA conforme instrução da tarefa. O agente principal conduz as revisões estáticas sobre este estado congelado.

Raio, contraste do contorno e cadência continuam provisórios e aguardam avaliação manual de gameplay.

Resultado final: margem física corrigida para0.0; Gemini/Muse/Grok R2 sem defeitos remanescentes. Opus indisponível quota, revisão pendente. Estado local sem push; design V2 publicado primeiro em a19968fa. Saídas fiéis e avaliação em pareceres/README.md. Sem Godot/import/runtime/testes.

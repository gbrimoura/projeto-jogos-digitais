# Rebatida visual e bloqueio do disparo durante o parry

Estado: proposta prospectiva para integração mínima no runtime existente.

## Objetivo

Dar à rebatida uma animação visual legível em cinco momentos — preparo, varredura, contato, acompanhamento e retorno — mantendo a mira de 360° congelada durante a ação e a pegada presa ao personagem. Enquanto a janela física do parry estiver ativa, nenhum caminho de consulta ou tentativa de disparo pode aceitar um lançamento.

## Contrato

- Preservar a janela física existente (`active_duration`, padrão 0,20 s) e o cooldown de 0,55 s.
- A animação ocupa a mesma duração ativa informada pelo controller; interpolar as poses em vez de esticar os membros.
- No rig de chão, resolver o cotovelo pelo IK existente, manter os comprimentos dos segmentos e limitar a pegada aos alcances atuais. Em outras animações, preservar a âncora da mão nativa.
- `RacketController.is_swing_active()` expõe apenas o estado físico atual.
- `BallLauncher.is_launch_available()` consulta esse estado, cobrindo a interface de trajetória e chamadas diretas. Um clique durante a ação é consumido e não fica em fila.
- A prioridade de física existente do controller (-100) mantém o parry simultâneo ao disparo determinístico.
- Cancelar, resetar ou morrer limpa o estado ativo e libera o bloqueio.

## Limites

Alterar somente `racket_visual.gd`, `racket_controller.gd`, `ball_launcher.gd` e este registro documental. Sem mudanças de arte, atlas, cenas, shader, física de projéteis, detecção de parry, movimento ou janela/cooldown para acomodar a apresentação. Validação restrita a leitura estática e `git diff --check`; sem execução de Godot ou testes.

## Base

Snapshots dos três scripts autorizados antes da implementação em `historico/base/`.

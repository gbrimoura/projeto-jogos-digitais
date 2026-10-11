# Correção de orientação idle/walk

Usuário reportou direções invertidas ao andar. Idle/walk nativos apontam -X; dash +X. GPT-6 Luna xhigh corrigiu somente PlayerVisual: flip compara direção lógica com direção nativa da animação, e animation_changed reaplica ao trocar estado. Fast não confirmávelinterface. Física/input/atlas/arte/tempos inalterados. Inspeção estática do principal e git diff --check sem erros; nenhum teste/Godot.

Gemini3.8 Flash High AGY plan e Museopencode-go/muse-spark-1.3-contributor xhigh OpenCodeplan concluíram somenteleitura de fonteinlinecongelada, sem regressões concretas. Grokgrok-4.7-xhigh-fast Cursorplan atingiu timeout ajustado2min pelo escopocurto e foi encerrado sem stdout/parecer. Opusclaude-opus-5-5-high preflight confirmado autenticação/listagem, quota bloqueada, sem parecer/substituição. Stdoutfiéis e hashfonte aqui.

Regras estáticas conferidas: direita idle/walkfliptrue e dashfalse; esquerda idle/walkfalse e dashtrue. Transições sem troca de direção reaplicam flip pelo sinal sem reiniciarquadros nemrecursão. Reset/idle aéreo/morte mantêm orientação correspondente. Novas animações futuras precisarão declarar direção nativa própria se diferirem do default -X. Validação gameplay pendente. Nenhum commit/push.

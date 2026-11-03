# Ajuste pontual prospectivo — setas

Pedido: alinhar setas das portas horizontais e fazê-las piscar. Correção pequena de apresentação em dois scripts, sem plano arquitetural completo. Implementador único Luna gpt-6-luna xhigh; Fast/priority não confirmável. Preservar dirty. Sem Godot/testes conforme AGENTS.

Alinhar LEFT/RIGHT ao centro visual do vão (altura do SideDoorVisual), mantendo deslocamento horizontal48 para dentro. Não derivar seta da posição do viewport nem mudar travessia/gate/física. UP/DOWN preservam offsets atuais. Considerar visual_position local no standalone; managed tem centro visual lateral0. Arredondar posição final na grade inteira se necessário.

Piscar discreto e lento por fases binárias visível/apagado, sem alpha/escala/movimento fracionário. Sugestão ciclo1.2s, ligado0.8s e apagado0.4s; clock local só enquanto enabled em runtime. Configure repetida com enabled igual não deve reiniciar fase; ao habilitar começar aceso; ao desabilitar parar/resetar. Editor tool fica estático, sem piscar. Não alterar visible que carrega a elegibilidade da saída: blink apenas no draw. Preservar condições Exit+cleared+!terminal+!busy e retry, direção cardinal, paleta, desenhos e labels ocultas.

Escrita somente scripts/world/exit_door.gd (cálculo posição apresentação) e scripts/world/exit_direction_indicator.gd (piscar). Demais scripts/cenas/assets/Git proibidos. Snapshot antes/depois; revisões estáticas Gemini/Grok/Muse e Opus Cursor exato; quota/saída vazia não são aprovação. Timeout writer10min/revisão10min. Sem testes, engine, parser, linter, auditoria ou simulação.

# Integração prospectiva — raquete e parry visual

## Escopo

Substituir a raquete vetorial antiga por uma cabeça de pingue-pongue pixel art V4, com cabo curto e mão ligada ao ombro. Preservar atlas, SpriteFrames, movimento, mira de 360°, origem/física do disparo, detecção/cooldown do parry e prioridades atuais de hurt, dash, pulo e morte.

## Contrato visual

- Exportar a cabeça vermelha V4 em PNG/Aseprite 14×14, nearest, alpha binário; usar desenho de cabo e braço procedural em escala de pixel coerente.
- Idle e caminhada: mascarar somente pixels da mão/antebraço original em uma janela nativa do atlas, deixando a ombreira original visível; desenhar rig de dois segmentos preso à ombreira e ao grip. Não editar a textura/atlas existentes.
- Outras animações: desativar rig e máscara e prender somente o conjunto raquete à mão já desenhada, por âncora aproximada por animação/quadro. Morte oculta o conjunto; prioridade do corpo permanece inalterada.
- Parry: capturar a direção já congelada pelo controller; iniciar sequência de seis poses (~200 ms) em todo parry iniciado, inclusive sem acerto. Cancelamento/reset/morte limpa sequência.
- Disparo: iniciar somente depois que `try_launch` aceitou e instanciou a bola; evento visual recebe a origem aprovada e direção, nunca atrasa nem altera spawn. Começar no contato e seguir recuperação; o head visual limita aproximação para não cobrir a bola que nasce em `spawn_offset` e não promete colisão gráfica exata quando a parede encurta a origem.

## Evidência e limites

Referência editável V4 preservada em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-raquete-estudo-v4/`. As anchors do braço são uma adaptação runtime do estudo lateral e não mudam regras de combate. Validação somente por leitura/revisão estática; por instrução do repositório, não executar Godot, import ou testes sem pedido do usuário.

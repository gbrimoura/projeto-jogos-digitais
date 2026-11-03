# Decisões R3 e limites de apresentação

Decisões comunicadas no chat ao implementador antes da escrita do layout; este arquivo registra o resultado da coordenação, sem substituir os pacotes e saídas originais.

O fullscreen pode aplicar stretch fracionário mesmo sem chaves explícitas de viewport no projeto. Por isso a HUD compensa o transform de stretch no próprio CanvasLayer, calcula uma escala inteira no espaço final e mantém a raiz Control sem escala adicional. Usa Viewport.get_stretch_transform, cuja documentação oficial descreve esse uso para compensar escala de texturas pixeladas. Não há mudança em ProjectSettings ou câmera. Retângulo/transform são monitorados também no processamento, além do sinal de resize.

A árvore pausada esconde o conteúdo da HUD por um auxiliar PAUSABLE em NOTIFICATION_PAUSED. A bridge ALWAYS mantém o ciclo de vida, mas não escolhe outro alvo durante pausa. Esconder o conteúdo por pausa não equivale a desativar a raiz; desativação real restaura a interface legada. Overlays de derrota, vitória e recompensa têm mensagens e controles próprios. A HUD não cobre seus botões.

Fonte bitmap usa ResourceLoader.exists + load, e JSON.data, com metadados verificados antes de ocultar o legado. Campos opcionais não são preload obrigatórios. Morte tem prioridade sobre o estado do dash; disponibilidade aérea vem de can_dash, sem uma regra nova. O chefe usa a mesma derivação do controlador e mostra CHEFE, evitando 4/3. Retratos são por classe real dos dois inimigos, não pelo texto do nome.

Fontes oficiais consultadas pelo principal: https://docs.godotengine.org/en/stable/classes/class_viewport.html#get-stretch-transform, https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html, https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#when-setter-getter-is-not-called. Não houve execução de engine ou simulação.

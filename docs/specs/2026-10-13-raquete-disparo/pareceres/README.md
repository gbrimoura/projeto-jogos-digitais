# Pareceres — integração da raquete e disparo

Revisão somente leitura com fontes autorizadas inline; nenhum revisor executou testes, Godot ou editou o workspace. Preflight realizado uma vez: Cursor autenticado/modelos exatos listados; Gemini disponível no AGY; OpenCode Go autenticado/Muse listado. Implementador GPT-6 Luna xhigh, Fast/priority não confirmável. Snapshots preservam o estado local antes desta integração, sem commit/branch/push.

| Rodada / revisor | Ferramenta, modelo e esforço | Estado |
|---|---|---|
| R1 Gemini | AGY plan, Gemini 3.8 Flash (High) | done; correção de orientação IK e cancelamento avaliada/integrada |
| R1 Muse | OpenCode plan, opencode-go/muse-spark-1.3-contributor xhigh | done; sem P1; contorno de disco corrigido |
| R1 Grok | Cursor plan, grok-4.7-xhigh-fast | timeout após 10 min; encerrado, stdout vazio |
| R1 Opus | Cursor plan, claude-opus-5-5-high | blocked por quota; saída original opus-r1.txt |
| R2 Muse | Mesmo modelo/esforço; análise curta do gerador | done; helper inside_xy e contorno confirmados |
| R3 Gemini | Mesmo modelo/esforço; correções runtime inline | done; aprovação técnica, limitações visuais descritas |
| R3 Muse | Mesmo modelo/esforço; correções runtime inline | done; observações por contexto parcial resolvidas pelo principal |
| R3 Grok | Mesmo modelo/esforço; análise curta do incremento | timeout após 3 min; encerrado, stdout vazio |

As saídas originais estão nos arquivos `<revisor>-r<rodada>.txt`; arquivos vazios de Grok foram preservados. Hashes dos estados revisados: `estado-r1-sha256.json`, `estado-r2-sha256.json` e `estado-r3-sha256.json`. Não foi atribuído parecer ou aprovação ao Opus/Grok ausente.

## Decisões do principal

- Corrigida previamente a multiplicação duplicada de TEXTURE no shader: em Godot 4, COLOR no fragment já inclui textura e modulação ([documentação oficial](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html#color-and-texture)). O shader agora altera somente alpha, sem return antecipado, com floor para coordenadas de texel.
- Corrigido o vetor lateral do IK, que antes recebia referência colinear: agora usa direção preferida perpendicular e epsilon 0,0001. Limites físicos do desenho: segmentos 14/12 px; distância mínima 2,001 px e máxima 26 px; proteção de eixo nulo e sqrt mantida. Rebusca redundante do body por quadro removida.
- RacketController.cancel() emite swing_cancelled após zerar o estado; Player conecta a clear_transient. Morte e reset já limpam o estado: Player._on_died() chama clear_transient e health.died está conectado no ready. A observação Muse R3 de morte sem limpeza deriva do recorte parcial de fontes, não do código integrado.
- A alegação Gemini R1 de que dano não letal/guarda de entrada cancela automaticamente o parry físico foi rejeitada: o código atual só inicia hurt ou impede nova entrada; não cancela janela ativa. Nenhuma regra de hurt/parry/movimento foi alterada.
- A extensão da máscara até Y45 foi rejeitada após a inspeção do implementador: luva dourada chega a Y43, enquanto Y45 integra a silhueta do corpo. HAND_ANCHORS é aproximação de encaixe, não evidência de pixels. A janela X39–45/Y37–44 preservada evita apagar o corpo. Atlas uniforme 64 px por quadro, sem padding nesta fonte: hipótese Muse de atlas com padding não se aplica.
- Defeito real de índice linear no contorno do disco corrigido com inside_xy e limites de coordenadas. PNG e Aseprite regenerados, mantendo cores e tamanho.
- A recuperação segue a posição do personagem por projeto; fixar a cabeça no ponto mundial de spawn soltaria a pegada do corpo em movimento. Contato gráfico exato perto de paredes e flip/âncoras fora de idle/walk ainda precisam de avaliação visual em jogo. Nenhuma alegação de teste/runtime realizado.

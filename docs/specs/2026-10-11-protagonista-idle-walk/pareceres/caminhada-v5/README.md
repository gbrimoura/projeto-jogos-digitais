# Revisões estáticas — caminhada frontal v5

Implementação delegada ao GPT-6 Luna xhigh. Estado congelado original em estado-revisado.json; pareceres originais em gemini-stdout.txt, muse-stdout.txt e grok-stdout.txt. Os três revisores trabalharam somente sobre fontes inline, sem editar, executar testes ou inspecionar binários.

- Gemini 3.8 Flash High via AGY: contrato de atlas/cadência/facing consistente; LOW sobreposição local de perna e comentário antigo.
- Muse Spark 1.3 Contributor xhigh via OpenCode: contrato consistente; LOW comentário antigo.
- Grok 4.7 XHigh Fast via Cursor: contrato consistente; MEDIUM sobreposição da bota com joelho/tornozelo; LOW limite metadata28 vs spec32 e comentário antigo.
- Opus 5.5 High via Cursor, claude-opus-5-5-high: preflight desta tarefa bloqueado por quota; resultado original preservado em opus-preflight.txt. Sem parecer Opus e sem substituição silenciosa.

## Decisões do principal

Sobreposição: confirmada na fonte e avaliada com Luna. O remapeamento encurta o membro em balanço; a bota elevada pode substituir detalhes de joelho/tornozelo na mesma linha. O principal inspecionou o contact final e aceitou a pose nesta rodada, sem alteração de imagens. É uma limitação artística registrada, não aprovação visual do usuário nem garantia de ausência de deformação.

Declarações: Luna corrigiu comentário para oito poses, mensagem de status para arte integrada e limite declarativo para32 no Lua e metadata JSON.32 é limite da spec, não medição automática. Principal inspecionou as três linhas de delta e o JSON; fórmulas, PNG, Aseprite e GIFs permaneceram intactos. Esses ajustes declarativos posteriores não receberam novo parecer externo; estado-final.json registra hashes e delta exatos.

## Integração e limites

Aseprite export exit0 sem stderr; Godot4.7.2 import editor exit0 sem stderr após docs/.gdignore excluir snapshots históricos da descoberta de classes. PlayerVisual ativo em scripts/player/player_visual.gd. PNG runtime1088×64 SHA256722043ec65573ebead392a88ef1f35993c9f00e0ba0f1517d9a9e69100020996. Comparação RGBA reportada por Luna: zero divergências idle0–5/dash14–16. Nenhum teste ou gameplay executado. Avaliação visual do usuário pendente.

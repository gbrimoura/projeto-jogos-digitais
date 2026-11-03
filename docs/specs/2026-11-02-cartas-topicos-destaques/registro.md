# Registro — tópicos e valores destacados

Estado: implementação concluída e congelada para revisão somente leitura pelo agente principal.

A baseline byte a byte dos 11 alvos existentes foi arquivada em `historico/baseline/`; hashes SHA-256 em `historico/baseline-sha256.csv`. Antes de editar, conferi estaticamente os sete tópicos gerados pelo `UpgradeCatalog` e os ranks máximos reais nos recursos.

O card local usa `UpgradeStatText`, derivado de `HudBitmapText`, com o mesmo bundle de fonte bitmap local. Cada efeito inicia com `- ` ciano; linhas de continuação recebem dois espaços. Conteúdo limitado a 22 glifos por palavra-quebra e 24 no total. Valores atuais e `>` permanecem cinza; o benefício nominal ou valor novo, incluindo sinal/decimal/unidade `s`, fica amarelo. Condições “Até 3 paredes...” e “Uma vez por rebatida” continuam cinza. Não alterei `HudBitmapText`, mecânicas, `UpgradeCatalog`, recursos ou ícones.

A revisão manual de pior quebra considerou: Impacto 219→220 (23 glifos de conteúdo, duas linhas); Motor 2→3 (22 glifos, com `s`); Carga 219→220 (a comparação de 23 glifos em duas linhas mais a condição em uma); Pressão até rank 3 (valor e limite em no máximo duas linhas); Mola até rank 3 (rebotes e duração em no máximo duas linhas); Dínamo até rank 3 (comparação e condição em no máximo três linhas); Chassi até rank 95 (vida máxima mais cura em no máximo três linhas). As cores acompanham cada substring através da quebra. Esta conferência foi manual, não um teste de parser/runtime.

A fonte Aseprite dos três estados e os PNGs das molduras foram atualizados somente nas três marcas cobre isoladas de 2×2 em x=14..15, y=144..145, 158..159 e 172..173. O modo Aseprite foi executado com `preview_only=true` e `clean_frames=true`; a segunda execução terminou com exit 0 e atualizou apenas estados e duas prévias. Inspeção visual manual confirmou os tópicos/realces e as molduras. Logs: `assets/ui/upgrade_cards_v1/source/bullet-production.stdout.log`, `.stderr.log`, `bullet-production-r2.stdout.log` e `.stderr.log`; a falha inicial de escopo permanece registrada no primeiro par.

Alterações fora dos artefatos visuais autorizados: somente o renderer local, a cena da carta, o gerador Aseprite e o contrato/registro desta apresentação. Os dois contact sheets e sete ícones não foram tocados. Não houve Godot, import, testes, parser, linter, auditoria, render audit, simulação, commit ou push. A revisão obrigatória do agente principal permanece pendente; não há aprovação estética do usuário registrada.
## Resultado integrado
Removidos os três marcadores cobre quadrados de cada uma das molduras normal/focus/pressed, inclusive na fonte ASE. Tópicos agora começam com traço ciano, e continuação usa dois espaços alinhados. Benefícios nominais e novos valores das comparações aparecem em amarelo; valor atual, seta, texto e condições ficam cinza. A descrição permanece no estilo existente.

Renderização isolada em UpgradeStatText, aplicada aos três controles Topic0/1/2. Quebra com conteúdo22+prefixo2=24 glifos, até3linhas por carta. Cores por caractere seguem o tópico através das quebras. HudBitmapText e efeitos de gameplay não foram alterados.

Produção Aseprite R2 exit0, PNG inspecionado pelo principal, sem execução Godot/testes. Pareceres finais Gemini/Muse confirmaram os dois fixes; Grok sem parecer; Opus pendente por cota. Snapshots, pacote imutável, hashes e saídas originais preservados. Nenhum aceite estético do usuário foi presumido.

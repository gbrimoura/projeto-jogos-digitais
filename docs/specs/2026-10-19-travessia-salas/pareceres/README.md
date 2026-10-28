# Revisões — travessia andando e transição de sala

19/10/2026. Implementação delegada GPT-6 Luna xhigh; Fast/priority não confirmável nesta interface. Um escritor; principal coordena/revisa e persiste metadados. Runtime ainda não autorizado até análise arquitetural. Sem Godot/import/testes/QA/commit/push/branchchange.

Preflight único: AGY Gemini3.8FlashHigh/claude-opus5-5high listados; Cursor autenticado, cursor-grok-4.6-xhigh-fast e claude-opus-5-5-high exatos; OpenCodeGo credencial armazenada e MuseSpark1.3Contributor no catálogo. Credencial armazenada não comprova validade da API.

## Plano

R1 preservada pelo implementador em historico/r1. Principal identificou risco concreto: sem guardaexterna, falha com retrydesarmado ou passo maior poderia deixarPlayer sair do piso. R2 adicionou RightOuterGuard8×648 x1152..1160 nasduasfixtures e validador. Corpo continua dentro de1152x648 deviewport durantecruzamento; contenção exterior não amplia piso.

Entrada R2 completa inline: plano-r2-input.txt SHA256 2A5EB90BC6699FEE32CE3FC280D14D77911A3CCAC2078A46C65A01D88342CD6E. Revisores read-only sem ferramentas/comandos, timeout10min. Pacote e stdout/stderr/exit preservados. Muse retornou APIkeyexpired, semparecer; exit0wrapper nãoé aprovação. Gemini/Grok/OpusAGY ainda em andamento nesta anotação. OpusAGY plano não substituirá revisão CursorOpus da implementação.
## Plano R2: decisões e correções

Gemini favorável com precisões; OpusAGY apontou3P1reais: process_modeDISABLED removeCollisionObject pordefault; snapshotantesfade vazaemrestart; retrymanaged ambíguocom bossreward. Grok acrescentou risco de rearme/overlaypersistente; suas hipóteses dePlayerreutilizadonoManaged foram rejeitadas: _load_current_encounter instancia novaPackedScene/Player. RecompensalocalMain e bossRewardScreen jáexistente são fluxos distintos, não duplicar nemmoverporhipótese.

Principal confirmou PlayerColliderCapsule raio14/altura76, offset(0,-38): origemPlayer são pésY560, centrocolisorY522. Detectargeometria pelo centro transformado, nãoorigemdos pés. Substituir velocityfinal por deslocamentopositivo evita missao atingir OuterGuard. Collider28×76 cabe no túnel64×128 e alcançaX1120 antescontenção.

Fonte primária do comportamento disable_mode: [CollisionObject2D — Godot](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html). REMOVEdefault retira objeto da física com PROCESS_MODE_DISABLED; KEEP_ACTIVE mantém física. Principal verificou fonte oficial antes de adotarcorreção. Nenhuma execução deengine.

## Delta arquitetural R3

Entradaautoritativeroot `plano-r3-delta-input.txt` SHA256 E016C647B6E4AE6099134526F6F6403609FBA321551C1738CBAD7F0E5EC133C5. Fornecida inline imutável enquanto implementador persistia contrato documental, sem runtime. Gemini/Grok/OpusAGY encerraramP1/P2 e aprovaram com clarificações de mesmaescopo. Saídasoriginais preservadas. Opinões de blindagem/riscozero dosmodelos não são teste nemgarantia deengine.

Decisões finais: validaçãodeferred deevento latched+posiçãoatual; lockKEEP_ACTIVE→DISABLED, restoreprocess_mode→disable_modeoriginal; samplerforaPlayer/primeiraamostrainicializa; rollbackgateaberto/retryapósrecuo; snapshotapenasnopreto+owner/tokenválidos; waitnovacena atualready limitado120frames ecleanupsefatalpósswap; pausebloqueadaenquantobusy e restart/deathcancelam; normaldestruiçãoMainemswaplegítimonãolimpa snapshotcommitted. CancelTween deve liberar await/cleanup, nunca ficar pendente. Managedúnicofadeapósbossreward, pausecomownershipsem despausarGameOver; standalone semtreepause. Terminal supersedeunlock.

Principal autorizou fase2 nos7arquivosdeclarados após persistência prospectivaR3. Timeout30min, escritorúnicoGPT-6Lunaxhigh. Implementação terárevisãoestável própria por4revisores; planoOpusAGY não substituiCursorOpus. Semengine/import/testes/QA/Git.

## Execução da fase2

A fase1 documental foi produzida por /root/porta_parede. Após finalização dessa fase, mensagens send_message não iniciaram a etapa seguinte; principal corrigiu com followup_task. Na continuação, a execução apareceu pending_init sem alteração de fontes. Foi interrompida e teve todaautorização deescrita revogada. Principal iniciou /root/travessia_salas, GPT-6 Luna xhigh, fork none comcontexto compacto; status running e leituras R3 confirmadas. Único escritor runtime autorizado é /root/travessia_salas. Nãohouve substituição demodelo/esforço, somente de instância. Baseline pre-runtime permaneceválido; runtime estava inalterado no repasse. Timeout30min na implementação nova, semengine/testes/QA.

## Implementação R1 congelada

Sete fontes congeladas por GPT-6 Luna xhigh; pacote integral `implementacao-r1-input.txt`, SHA256 D6131B32FDEE6FDB6F6125C976E7DB9E2840E3D9591D2720A1E74F423FBA1BE2. Cópias em `implementacao-r1-snapshot/`, hashes em `implementacao-r1-hashes.json`; baseline é local, preservando alterações anteriores. Rodada read-only iniciada nos quatro modelos exatos, timeout10min; stdout/stderr/exit separados. Preflight já realizado nesta tarefa, sem repetição.

Cursor Opus 5.5 High: bloqueado por quota, reset informado pela ferramenta em 03/11/2026. Muse: chave API expirada. Ambos sem parecer; exit0 do wrapper não significa revisão aprovada. Gemini/Grok continuam pendentes nesta anotação. Nenhum revisor substituído, nenhum controle de permissão desativado.

Principal confirmou por comparação SHA256 que os10arquivos protegidos em `fora-escopo-hashes.json` seguem idênticos; incluindo Player, arte procedural da porta, gerador, inimigos e THIRDPARTY local. Sem Godot/import/testes/QA. Git status somente leitura, sem stage/commit/push/reset/branchchange.

## Achados do principal sobre R1

Dois P2 confirmados também pelo implementador em análise read-only: validação deferred/pós-lock deve exigir centro atual além da linha, não somente dentro do vão; timeout standalone com fonte ainda atual não pode ficar bloqueado pelo flag committed nem limpar snapshot antes de revalidar a fonte ao terminar o fade. Correções delimitadas autorizadas em ExitDoor/Main/overlay, preservando as outras fontes. Revisores R1 receberam somente o pacote/snapshot imutável, que permanece inalterado; não leem o runtime em correção. R2 terá delta próprio e revisão posterior. Fonte snapshot R1 e hashes continuam como prova do estado analisado.

## Resultado R1 externo e decisão

Gemini concluiu leitura integral do pacote (3948linhas), sem testes, e encontrou P1 real: `is_gate_open()` usava `not disabled`, invertendo aberto/físico. Principal confirmou diretamente e autorizou correção. P2 de apresentação managed também aceito: erro antes de busy e impedir rearme de falha sem retry, preservando armamento inicial managed. P2 de fluidez aceito como incremento delimitado: default de transition_delay passa de1,5s para0; overrides positivos permanecem, fade inicia imediatamente por padrão e HUD não mostra contagem0. Nenhuma mudança em recompensas/HP/build.

Grok encerrou exit0 com somente CRLF em stdout, sem parecer utilizável; não conta como aprovação. Saídas originais R1 e exits preservados. Cursor Opus continua bloqueado por quota e Muse por chave expirada, sem parecer. Implementador integra achados em R2 além dos2P2 do principal; haverá nova entrada/delta estável para revisão.

## Freeze R2 final e revisão delta

Implementador confirmou congelamento final por stdout após última edição e regeneração dos7hashes/tamanhos. Antes disso, a preparação do root detectou manifesto ainda em atualização e interrompeu a criação do pacote; nenhum revisor recebeu estado inconsistente. Entrada R2 final `implementacao-r2-input.txt`, 29584caracteres, SHA256 D737ADE8291EAE0CF29C78EF0241FCF3FBDAE43FFC22C7949DDF041F34C205A8. Inclui deltaexato R1->R2 dos4scripts, ExitDoor/overlay integrais, Main/Controller em contexto; cenas permanecem iguais a R1. Manifesto `implementacao-r2-hashes.json` e cópias `implementacao-r2-snapshot/`.

Gemini e Grok read-only solicitados no delta, mesmas ferramentas/modelos, timeout10min, saídas originais separadas. Opus/Muse continuam indisponíveis pelas falhas concretas já recebidas na tarefa; sem repetição de preflight ou substituição silenciosa. Integridade das7fontes e preservação dos10arquivos protegidos reconfirmadas por SHA256, prova `preservacao-final.json`. Nenhuma execução de Godot/import/testes/QA.

## Consolidação final — 19/10/2026

Gemini R2 concluiu leitura integral do delta imutável de29584caracteres: seis correções conferidas nos4scripts, sem P1/P2 concretos remanescentes. Root releu os fluxos afetados, confirmou semântica gate.disabled, linhaatual, rollbackrestrito, apresentação/rearme e delayzero; aceitou o encerramento estático desses achados. Frases absolutas do revisor sobre segurança/tipagem não substituem execução de engine. Linhas citadas pelo revisor são referências ao pacote, não números confiáveis dos arquivos runtime; use nomes de métodos e fontes congeladas como referência.

Grok R2 também encerrou exit0 com somente CRLF, sem parecer utilizável. Cursor Opus está bloqueado por quota até03/11/2026 e Muse por chave expirada; a revisão exigida desses modelos permanece indisponível e não foi substituída por aprovação fictícia. Stdout/stderr/exit de cada tentativa estão preservados. Não foram executados Godot, importação, testes ou QA.

Entrega técnica integrada em7fontes: passage lateral física condicionada a clear/recompensa/guard; atravessar andando sem E; fade180+220ms com default semespera adicional; persistência HP/build/chefes preservada; contenção/rollback/retry/terminal. Delegação: GPT-6 Luna xhigh implementou e corrigiu; principal coordenou, avaliou achados e consolidou documentação. Fast/priority não é confirmável na interface. Sem commit/push/stage/reset/troca de branch. Trabalho local anterior preservado.

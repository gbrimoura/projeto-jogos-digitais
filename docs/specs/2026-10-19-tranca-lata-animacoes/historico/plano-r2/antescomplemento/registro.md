# Registro — planejamento Tranca-Lata

**Data:** 19/10/2026.  
**Fase:** documentação prospectiva R2 e baseline; congelada para revisão.  
**Implementação de arte/runtime:** não iniciada nem autorizada nesta fase.

R1 do plano foi preservada sem alterações em historico/plano-r1/anteseditar/plano.md antes das emendas; SHA-256: `43DA7A424DAA2AA04AD293A265D6D38464CA5D5722E2AFE752A43A19ECB7D1FB`. R2 explicita o gate `spawn_pending`, a validação de `is_instance_valid` do suporte e o bind físico da exceção somente para o `SolidPlatform` efetivo em `motion_mode = FLOATING`, removendo a exceção anterior ao trocar suporte. O mask 3 continua ativo para outros World/Player; LOS e AOE seguem bloqueando no suporte. A patrulha para, inverte e pausa 0,25 s em qualquer colisão/limite; deslocamento efetivo menor que 0,01 px conta como zero, e aquisição de ataque/LOS ocorre antes do passo. Ataque zera movimento antes de capturar centro e selecionar windup; cancelamento oculta o centro antes de voltar a IDLE. O seletor visual muda apenas por nome/estado necessário; hit flash usa `flash_amount` existente. Sidecars `.import` e arquivos UID estão protegidos.

O plano e a spec mantêm a conversão prospectiva para CharacterBody2D, patrulha limitada ao suporte, sincronização às fases de ataque e integração das 12 poses. O nome visível é Tranca-Lata; identificadores técnicos TrainingTarget e node paths ficam preservados.

historico/base/ contém cópias byte a byte dos seis arquivos autorizados para uma fase runtime futura e sha256-before.json com os hashes conferidos contra as fontes no momento da cópia. A base captura o estado local já existente; scripts/world/main.gd e scripts/world/training_target.gd tinham modificações antes desta fase. Nenhum arquivo fora desta pasta documental foi editado por este agente. O arquivo pareceres/README.md pertence ao principal e permaneceu intocado.

Não foram executados Aseprite, Godot, importação, testes ou QA. Não houve alteração de Git. A revisão R2 permanece documental; arte e runtime ainda não estão autorizados.

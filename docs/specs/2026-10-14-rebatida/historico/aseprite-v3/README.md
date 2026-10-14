# Histórico da reprodução Aseprite v3

A pasta de arte `pitch-assets/protagonista-rebatida-aseprite-v3/` é nova. Não havia arte v3 anterior a preservar. A PNG de referência v2 permaneceu intacta; o atlas runtime só foi alterado depois da aprovação do contact. Os 28 frames anteriores estão preservados em `base-runtime/` e seus hashes constam em `SHA256SUMS.txt`.

## Rebatida V3 — integração de corpo+braço (14/10/2026)

O snapshot imutável usado para anexar a arte está em `base-runtime/`, cobrindo atlas PNG, fonte Aseprite, SpriteFrames e scripts/player/launcher/controller antes da integração. SHA-256 do estado-base em `SHA256SUMS.txt`. A arte V3 ficou congelada em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-rebatida-aseprite-v3/`; o contact foi aprovado pelo principal antes da edição do runtime. `source/integrar-runtime-v3.lua` reproduz a anexação após verificar a identidade dos pixels dos 28 frames antigos.

A integração final inclui frames 28–33 e a tag `parry_body`; os tempos são 30/35/25/25/40/45 ms, 200 ms total. Anchors e escala constam no JSON de metadata da arte. Os frames anteriores, tags e durações foram preservados. A animação corporal usa progresso físico do controller e respeita prioridades já existentes. Sem testes, Godot ou import.


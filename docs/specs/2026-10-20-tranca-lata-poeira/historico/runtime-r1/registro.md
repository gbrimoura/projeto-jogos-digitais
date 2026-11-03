# Registro R1 — poeira no ataque do Tranca-Lata

Data: 20/10/2026.

A cena `scenes/training_target.tscn` contém o filho `TrancaLataDust`, com `top_level = true`, processamento herdado (`process_mode = 0`) e camada global 2. `scripts/enemy/tranca_lata_dust.gd` mantém até 14 blocos opacos em grade de 2 px, usa `RandomNumberGenerator` privado, deriva para fora e para cima, reduz o tamanho em degraus e remove cada partícula em até 450 ms. A origem mundial do emissor é alinhada à grade de 2 px. `scripts/world/training_target.gd` chama `burst` uma vez em `_enter_active()` com a origem nos pés e chama `clear` em `_cancel_attack()`.

Arquivos congelados e cópias integrais em `snapshot/`. `diff-r1.patch` compara os dois arquivos existentes à base local e contém o arquivo novo integral. `sha256-r1.json` registra os hashes da base disponível, do estado final e das cópias.

Validação desta frente: leitura de fonte, diff e hashes. Nenhum Godot, import, teste, parser, gdlint ou QA foi executado. A inspeção visual em runtime permanece pendente. Revisões externas serão coordenadas pelo agente principal; ainda não há parecer nesta revisão.

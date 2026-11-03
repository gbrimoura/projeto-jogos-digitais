# Especificação — falha técnica recuperável

Fonte do problema confirmada por mensagem: GameOver genérico após _load_current_encounter rejeitar próxima cena. Falha precisa de Layout/seed para identificar validação específica; esta correção não afirma corrigir toda combinação procedural.

A troca passa a ter preparar, validar e só então substituir. Em falha, a run permanece não encerrada e a origem concluída existe; um erro específico pode repetir deterministamente até correção externa. Não trocar descriptor/seed nem oferecer vitória/derrota falsa. Permitir retry controlado, com estado de recompensa idempotente. Não expor logs enormes permanentemente sobre o combate: diagnóstico técnico em estado de falha, com texto legível e controles claros.

HUD conceitual permanece fora do runtime. Vida, dano, invulnerabilidade, ritmo, inimigos e quantidade de salas não mudam. Revisão estática não comprova compilação/jogabilidade.

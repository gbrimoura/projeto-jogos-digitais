# Delta exato do freeze R1 para R2

R1 é comparado pelo snapshot imutável em `pareceres/implementacao-r1-snapshot/`; seus hashes estão em `pareceres/implementacao-r1-hashes.json`. Os demais arquivos de runtime mantêm bytes e SHA-256 idênticos ao R1.

| Arquivo | SHA-256 R1 | SHA-256 R2 | Delta R2 |
|---|---|---|---|
| `scripts/world/exit_door.gd` | `aab8e700f1c51349f95faae003a86dff467531b940004fde5710900e511e94dc` | `e2274c171a5e55c6acce003a61ec4fc12d25ef7969f0ae72c2ea9a96160361a0` | Confirma gate aberto com `disabled`; exige centro atual `x >= line_x` e dentro do vão; impede rearmamento managed depois de falha; exibe mensagem de falha antes de busy e só mostra convite de retry quando retry está habilitado. Os retornos Variant do amostrador recebem anotações explícitas nos três pontos de uso. |
| `scripts/world/main.gd` | `46d8eb0d0db7e1c11791fee64da34e8b364b4cede86ab226653d95b5b77cb127` | `768d548c89ecc8ac745ebb6aebe73c7cf76b8f9383e7d0eaaf6a53d25b30ede4` | Adiciona rollback tardio dedicado, restrito a token/transição válidos e à fonte ainda ativa; só então reseta o commit e delega ao rollback existente, que limpa snapshot, restaura o Player e informa a porta. |
| `scripts/world/room_transition_overlay.gd` | `9bf7625e2a36f1caa72d02079d3f00e0501f7a4253e7406dad4e2fa7c97edbfc` | `0cfb9e90d671e9dc6b821e802b2065d0358b94ad8852527fec2e50516f69c0f5` | No timeout com fonte ainda ativa, mantém o snapshot durante o fade. No fim, chama o callback dedicado; se uma nova cena pronta já assumiu, preserva o snapshot. Se não há rollback válido nem destino pronto, limpa o snapshot como recuperação sem cena utilizável. |
| `scripts/world/run_controller.gd` | `f94a096dc0893ecc1a5ff386a813c3db32db4d7f98301846a4f7516616dced5e` | `db8c3a7358d1954ef08e3fa17a3db1e76395e170b5e2223e7a1b38dc47223c9a` | `transition_delay` passa a default/mínimo zero; só cria timer para override positivo e usa status de preparação quando zero, mantendo checagem do estado após eventual espera. |
| `scenes/exit_door.tscn` | `b3efba83e11e213b573add3422f8ab77722fcb61ce753dfe23cf6695a135f0d6` | igual | Nenhuma alteração R2. |
| `scenes/main.tscn` | `9e2ac76f5fc86084774266f4b9f0eb7c2d17734310a714f5725f665c28e7cce7` | igual | Nenhuma alteração R2. |
| `scenes/second_room.tscn` | `a70957b7fae7130ceb9aa40743e6b3dbc67587e23e533e41124d13076580c78d` | igual | Nenhuma alteração R2. |

`sha256.json` registra hashes e tamanhos R2 das sete fontes, incluindo EOF, junto com os hashes R1 e o baseline local.

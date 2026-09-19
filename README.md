# ArenaFit — Modelagem de Banco de Dados

**Disciplina:** Banco de Dados — C07  
**Professor:** Felipe Tagawa Reis  
**Entrega:** arquivo `.mwb` + este `README.md`

## Integrante

| Nome | Função |
|------|--------|
| Alvaro | Modelagem completa do banco (EER / `.mwb`) e documentação |

Projeto desenvolvido individualmente.

## Tema

**ArenaFit** é um sistema de gestão de academia. O banco armazena pessoas (alunos e instrutores), unidades, planos, equipamentos, modalidades e aulas, além das operações de assinatura e inscrição.

## Entidades principais (7+)

1. **Pessoa** — base da herança  
2. **Aluno** — especialização de Pessoa  
3. **Instrutor** — especialização de Pessoa  
4. **Unidade** — sede/filial da academia  
5. **Plano** — planos de mensalidade  
6. **Modalidade** — tipos de atividade (musculação, yoga, etc.)  
7. **Aula** — turma agendada  
8. **Equipamento** — aparelhos por unidade  
9. **Ficha_Medica** — avaliação 1:1 do aluno  
10. **Telefone** — atributo multivalorado de Pessoa  

## Relacionamentos (requisitos da disciplina)

| Tipo | Onde aparece no modelo |
|------|-------------------------|
| **1:1** | `Aluno` ↔ `Ficha_Medica` |
| **1:N** | `Unidade` → `Equipamento`; `Modalidade` → `Aula`; `Instrutor` → `Aula` |
| **N:M** | `Assinatura` (Aluno×Plano); `Inscricao_Aula` (Aluno×Aula); `Habilitacao` (Instrutor×Modalidade) |
| **Herança** | `Pessoa` → `Aluno` / `Instrutor` |
| **Recursivo** | `Instrutor.id_supervisor` → `Instrutor` (1:N); `Pre_Requisito` (Modalidade×Modalidade, N:M) |

### Tabelas intermediárias N:M (nomes definidos)

- **Assinatura** — vínculo Aluno ↔ Plano  
- **Inscricao_Aula** — vínculo Aluno ↔ Aula  
- **Habilitacao** — vínculo Instrutor ↔ Modalidade  
- **Pre_Requisito** — vínculo recursivo Modalidade ↔ Modalidade  

## Tipos de atributos (como em aula)

| Tipo | Exemplo no modelo |
|------|-------------------|
| **Simples** | `nome`, `cpf`, `email` |
| **Composto** | `endereco` → `end_rua`, `end_numero`, `end_bairro`, `end_cidade`, `end_cep` |
| **Multivalorado** | telefones → tabela `Telefone` |
| **Derivado** | `imc` (calculado a partir de `peso` e `altura`) |
| **Chave** | `id` / `id_pessoa` (PK) |

## Layers do diagrama

1. **01 - Pessoas (Herança)** — Pessoa, Telefone, Aluno, Instrutor, Ficha_Medica  
2. **02 - Estrutura** — Unidade, Plano, Equipamento  
3. **03 - Atividades** — Modalidade, Aula  
4. **04 - Relacionamentos N:M** — Assinatura, Inscricao_Aula, Habilitacao, Pre_Requisito  

## Arquivos do repositório

- `ArenaFit.mwb` — modelo EER no MySQL Workbench *(criar seguindo o passo a passo)*  
- `README.md` — este arquivo  
- `arena_fit_schema.sql` — script SQL de referência (opcional, para consulta)  
- `PASSO_A_PASSO_WORKBENCH.md` — guia detalhado de montagem no Workbench  

## Como abrir o modelo

1. Instale/abra o **MySQL Workbench**  
2. `File` → `Open Model...` → selecione `ArenaFit.mwb`  

-- ============================================================
-- ArenaFit - Sistema de Gestao de Academia
-- ============================================================

CREATE DATABASE IF NOT EXISTS arena_fit;
USE arena_fit;

-- ------------------------------------------------------------
-- LAYER: Pessoas (heranca Pessoa -> Aluno / Instrutor)
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Pessoa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    end_rua VARCHAR(120) NOT NULL,
    end_numero VARCHAR(10) NOT NULL,
    end_bairro VARCHAR(80) NOT NULL,
    end_cidade VARCHAR(80) NOT NULL,
    end_cep CHAR(8) NOT NULL
);

CREATE TABLE IF NOT EXISTS Telefone (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    ddd CHAR(2) NOT NULL,
    numero VARCHAR(9) NOT NULL,
    tipo ENUM('Celular', 'Residencial', 'Comercial') NOT NULL DEFAULT 'Celular',
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id)
);

CREATE TABLE IF NOT EXISTS Aluno (
    id_pessoa INT PRIMARY KEY,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    data_inicio DATE NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id)
);

CREATE TABLE IF NOT EXISTS Instrutor (
    id_pessoa INT PRIMARY KEY,
    cref VARCHAR(20) NOT NULL UNIQUE,
    especialidade VARCHAR(80) NOT NULL,
    data_contratacao DATE NOT NULL,
    id_supervisor INT NULL,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id),
    FOREIGN KEY (id_supervisor) REFERENCES Instrutor(id_pessoa)
);

CREATE TABLE IF NOT EXISTS Ficha_Medica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL UNIQUE,
    tipo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    restricoes TEXT NULL,
    peso DECIMAL(5,2) NOT NULL,
    altura DECIMAL(3,2) NOT NULL,
    data_avaliacao DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_pessoa)
);

-- ------------------------------------------------------------
-- LAYER: Estrutura
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Unidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    end_rua VARCHAR(120) NOT NULL,
    end_numero VARCHAR(10) NOT NULL,
    end_bairro VARCHAR(80) NOT NULL,
    end_cidade VARCHAR(80) NOT NULL,
    end_cep CHAR(8) NOT NULL,
    capacidade INT NOT NULL,
    CHECK (capacidade > 0)
);

CREATE TABLE IF NOT EXISTS Plano (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    duracao_meses INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    modalidade ENUM('Mensal', 'Trimestral', 'Semestral', 'Anual') NOT NULL,
    CHECK (duracao_meses > 0),
    CHECK (valor > 0)
);

CREATE TABLE IF NOT EXISTS Equipamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(60) NOT NULL,
    estado ENUM('Disponivel', 'Manutencao', 'Inativo') NOT NULL DEFAULT 'Disponivel',
    id_unidade INT NOT NULL,
    FOREIGN KEY (id_unidade) REFERENCES Unidade(id)
);

-- ------------------------------------------------------------
-- LAYER: Atividades
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Modalidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    descricao TEXT NULL,
    nivel ENUM('Iniciante', 'Intermediario', 'Avancado') NOT NULL
);

CREATE TABLE IF NOT EXISTS Aula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    data_aula DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    vagas INT NOT NULL,
    id_modalidade INT NOT NULL,
    id_instrutor INT NOT NULL,
    id_unidade INT NOT NULL,
    CHECK (vagas > 0),
    FOREIGN KEY (id_modalidade) REFERENCES Modalidade(id),
    FOREIGN KEY (id_instrutor) REFERENCES Instrutor(id_pessoa),
    FOREIGN KEY (id_unidade) REFERENCES Unidade(id)
);

-- ------------------------------------------------------------
-- LAYER: Relacionamentos / Operacional (tabelas N:M)
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Assinatura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_plano INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    status ENUM('Ativa', 'Suspensa', 'Cancelada', 'Encerrada') NOT NULL DEFAULT 'Ativa',
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_pessoa),
    FOREIGN KEY (id_plano) REFERENCES Plano(id)
);

CREATE TABLE IF NOT EXISTS Inscricao_Aula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_aula INT NOT NULL,
    data_inscricao DATE NOT NULL,
    presenca BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (id_aluno, id_aula),
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_pessoa),
    FOREIGN KEY (id_aula) REFERENCES Aula(id)
);

CREATE TABLE IF NOT EXISTS Habilitacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_instrutor INT NOT NULL,
    id_modalidade INT NOT NULL,
    data_certificacao DATE NOT NULL,
    UNIQUE (id_instrutor, id_modalidade),
    FOREIGN KEY (id_instrutor) REFERENCES Instrutor(id_pessoa),
    FOREIGN KEY (id_modalidade) REFERENCES Modalidade(id)
);

CREATE TABLE IF NOT EXISTS Pre_Requisito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_modalidade INT NOT NULL,
    id_modalidade_requerida INT NOT NULL,
    obrigatoriedade ENUM('Obrigatorio', 'Recomendado') NOT NULL DEFAULT 'Obrigatorio',
    UNIQUE (id_modalidade, id_modalidade_requerida),
    CHECK (id_modalidade <> id_modalidade_requerida),
    FOREIGN KEY (id_modalidade) REFERENCES Modalidade(id),
    FOREIGN KEY (id_modalidade_requerida) REFERENCES Modalidade(id)
);


-- =========================================================================
-- SEGUNDA ETAPA:
-- =========================================================================

INSERT INTO Pessoa (nome, cpf, email, data_nascimento, end_rua, end_numero, end_bairro, end_cidade, end_cep) VALUES
('Carlos Silva', '11122233344', 'carlos@email.com', '1998-05-10', 'Rua A', '100', 'Centro', 'Santa Rita do Sapucaí', '37540000'),
('Ana Souza', '22233344455', 'ana@email.com', '2000-08-15', 'Rua B', '200', 'Santa Rita', 'Santa Rita do Sapucaí', '37540000'),
('Marcos Lima', '33344455666', 'marcos@email.com', '1995-12-20', 'Rua C', '300', 'Novos Estados', 'Santa Rita do Sapucaí', '37540000'),
('Beatriz Alves', '44455666777', 'beatriz@email.com', '1999-03-25', 'Rua D', '400', 'Centro', 'Santa Rita do Sapucaí', '37540000'),
('João Pedro', '55566677889', 'joao@email.com', '2001-07-30', 'Rua E', '500', 'Klimt', 'Santa Rita do Sapucaí', '37540000'),
('Roberto Carlos', '66677788990', 'roberto@email.com', '1985-01-10', 'Av Principal', '10', 'Centro', 'Santa Rita do Sapucaí', '37540000'),
('Mariana Dias', '77788990011', 'mariana@email.com', '1990-04-12', 'Av Principal', '20', 'Centro', 'Santa Rita do Sapucaí', '37540000'),
('Fernanda Lima', '88899001122', 'fernanda@email.com', '1988-09-18', 'Rua das Flores', '30', 'Jardim', 'Santa Rita do Sapucaí', '37540000'),
('Lucas Mendes', '99900112233', 'lucas@email.com', '1992-11-22', 'Rua das Pedras', '40', 'Alto', 'Santa Rita do Sapucaí', '37540000'),
('Juliana Paes', '00011223344', 'juliana@email.com', '1987-06-05', 'Rua do Horto', '50', 'Horto', 'Santa Rita do Sapucaí', '37540000');

INSERT INTO Telefone (id_pessoa, ddd, numero, tipo) VALUES
(1, '35', '991111111', 'Celular'),
(2, '35', '992222222', 'Celular'),
(3, '35', '993333333', 'Celular'),
(4, '35', '994444444', 'Celular'),
(5, '35', '995555555', 'Celular');

INSERT INTO Aluno (id_pessoa, matricula, data_inicio, ativo) VALUES
(1, 'MAT2026001', '2026-01-10', TRUE),
(2, 'MAT2026002', '2026-02-15', TRUE),
(3, 'MAT2026003', '2026-03-01', TRUE),
(4, 'MAT2026004', '2026-03-10', TRUE),
(5, 'MAT2026005', '2026-04-05', TRUE);

INSERT INTO Instrutor (id_pessoa, cref, especialidade, data_contratacao, id_supervisor) VALUES
(6, '123456-G/MG', 'Musculação', '2020-01-10', NULL),
(7, '654321-G/MG', 'Crossfit', '2021-05-15', 6),
(8, '111222-G/MG', 'Pilates', '2022-03-20', 6),
(9, '333444-G/MG', 'Spinning', '2023-07-01', 7),
(10, '555666-G/MG', 'Muay Thai', '2024-02-10', 6);

INSERT INTO Ficha_Medica (id_aluno, tipo_sanguineo, restricoes, peso, altura, data_avaliacao) VALUES
(1, 'A+', 'Nenhuma', 75.50, 1.78, '2026-01-10'),
(2, 'O+', 'Alergia a fruto do mar', 60.00, 1.65, '2026-02-15'),
(3, 'B-', 'Problema no joelho', 82.30, 1.80, '2026-03-01'),
(4, 'AB+', 'Nenhuma', 58.40, 1.60, '2026-03-10'),
(5, 'O-', 'Hipertensão leve', 90.10, 1.85, '2026-04-05');

INSERT INTO Unidade (nome, end_rua, end_numero, end_bairro, end_cidade, end_cep, capacidade) VALUES
('Arena Fit Centro', 'Rua Principal', '100', 'Centro', 'Santa Rita do Sapucaí', '37540000', 300),
('Arena Fit Sul', 'Av Sul', '500', 'Industrial', 'Santa Rita do Sapucaí', '37540000', 200),
('Arena Fit Norte', 'Rua Norte', '300', 'Nova', 'Santa Rita do Sapucaí', '37540000', 150),
('Arena Fit Universitária', 'Av Inatel', '1000', 'Bela Vista', 'Santa Rita do Sapucaí', '37540000', 500),
('Arena Fit Express', 'Rua Comércio', '50', 'Centro', 'Santa Rita do Sapucaí', '37540000', 100);

INSERT INTO Plano (nome, duracao_meses, valor, modalidade) VALUES
('Mensal Basic', 1, 90.00, 'Mensal'),
('Trimestral Silver', 3, 250.00, 'Trimestral'),
('Semestral Gold', 6, 480.00, 'Semestral'),
('Anual Premium', 12, 900.00, 'Anual'),
('Mensal VIP', 1, 150.00, 'Mensal');

INSERT INTO Equipamento (nome, categoria, estado, id_unidade) VALUES
('Esteira Elétrica', 'Cardio', 'Disponivel', 1),
('Supino Reto', 'Força', 'Disponivel', 1),
('Bike Indoor', 'Cardio', 'Manutencao', 2),
('Puxador Alto', 'Força', 'Disponivel', 3),
('Leg Press 45', 'Força', 'Disponivel', 1);

INSERT INTO Modalidade (nome, descricao, nivel) VALUES
('Musculação', 'Treino de hipertrofia e força', 'Iniciante'),
('Crossfit', 'Treino funcional de alta intensidade', 'Avancado'),
('Spinning', 'Aula de bike indoor', 'Intermediario'),
('Pilates', 'Controle muscular e postura', 'Iniciante'),
('Muay Thai', 'Arte marcial tailandesa', 'Intermediario');

INSERT INTO Aula (titulo, data_aula, hora_inicio, hora_fim, vagas, id_modalidade, id_instrutor, id_unidade) VALUES
('Musculação Manhã', '2026-06-01', '07:00:00', '08:00:00', 20, 1, 6, 1),
('Crossfit Hard', '2026-06-01', '08:00:00', '09:00:00', 15, 2, 7, 1),
('Spinning Turbo', '2026-06-01', '09:00:00', '10:00:00', 10, 3, 9, 2),
('Pilates Solo', '2026-06-01', '10:00:00', '11:00:00', 12, 4, 8, 3),
('Muay Thai Fight', '2026-06-01', '18:00:00', '19:00:00', 25, 5, 10, 1);

INSERT INTO Assinatura (id_aluno, id_plano, data_inicio, data_fim, status) VALUES
(1, 1, '2026-01-10', '2026-02-10', 'Ativa'),
(2, 3, '2026-02-15', '2026-08-15', 'Ativa'),
(3, 2, '2026-03-01', '2026-06-01', 'Ativa'),
(4, 4, '2026-03-10', '2027-03-10', 'Ativa'),
(5, 5, '2026-04-05', '2026-05-05', 'Ativa');

INSERT INTO Inscricao_Aula (id_aluno, id_aula, data_inscricao, presenca) VALUES
(1, 1, '2026-05-28', TRUE),
(2, 3, '2026-05-28', FALSE),
(3, 4, '2026-05-29', TRUE),
(4, 5, '2026-05-29', TRUE),
(5, 2, '2026-05-30', FALSE);

INSERT INTO Habilitacao (id_instrutor, id_modalidade, data_certificacao) VALUES
(6, 1, '2019-01-10'),
(7, 2, '2020-05-15'),
(8, 4, '2021-03-20'),
(9, 3, '2022-07-01'),
(10, 5, '2023-02-10');


-- =========================================================================
-- CONTROLE DE ACESSO (DCL) - Criação de Usuários e Roles
-- =========================================================================
CREATE ROLE IF NOT EXISTS 'cargo_recepcao';
GRANT SELECT, INSERT, UPDATE ON `arena_fit`.`Aluno` TO 'cargo_recepcao';
GRANT SELECT ON `arena_fit`.`Plano` TO 'cargo_recepcao';

CREATE USER IF NOT EXISTS 'atendente1'@'localhost' IDENTIFIED BY 'senha123';
CREATE USER IF NOT EXISTS 'atendente2'@'localhost' IDENTIFIED BY 'senha123';

GRANT 'cargo_recepcao' TO 'atendente1'@'localhost';
GRANT 'cargo_recepcao' TO 'atendente2'@'localhost';
SET DEFAULT ROLE ALL TO 'atendente1'@'localhost', 'atendente2'@'localhost';

SELECT p.nome AS Aluno, a.matricula, fm.tipo_sanguineo, fm.peso, fm.altura
FROM Aluno a
JOIN Pessoa p ON a.id_pessoa = p.id
JOIN Ficha_Medica fm ON a.id_pessoa = fm.id_aluno;

SELECT u.nome AS Unidade, e.nome AS Equipamento, e.categoria, e.estado
FROM Unidade u
JOIN Equipamento e ON u.id = e.id_unidade;

SELECT p.nome AS Aluno, pl.nome AS Plano, s.data_inicio, s.status
FROM Assinatura s
JOIN Aluno a ON s.id_aluno = a.id_pessoa
JOIN Pessoa p ON a.id_pessoa = p.id
JOIN Plano pl ON s.id_plano = pl.id;


-- =========================================================================
-- OBJETOS PROGRAMÁVEIS 
-- =========================================================================
DELIMITER $$

CREATE VIEW vw_relatorio_alunos AS
SELECT p.id, p.nome, p.email, a.matricula, a.ativo
FROM Pessoa p
JOIN Aluno a ON p.id = a.id_pessoa;
$$

CREATE FUNCTION fn_total_gasto_aluno (p_idAluno INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_valor DECIMAL(10,2);
    SELECT SUM(pl.valor) INTO v_valor
    FROM Assinatura s
    JOIN Plano pl ON s.id_plano = pl.id
    WHERE s.id_aluno = p_idAluno AND s.status = 'Ativa';
    RETURN IFNULL(v_valor, 0.00);
END;
$$

CREATE PROCEDURE prc_cadastrar_aluno_completo(
    IN p_nome VARCHAR(100),
    IN p_cpf CHAR(11),
    IN p_email VARCHAR(120),
    IN p_data_nasc DATE,
    IN p_rua VARCHAR(120),
    IN p_numero VARCHAR(10),
    IN p_bairro VARCHAR(80),
    IN p_cidade VARCHAR(80),
    IN p_cep CHAR(8),
    IN p_matricula VARCHAR(20)
)
BEGIN
    DECLARE v_id INT;
    
    INSERT INTO Pessoa (nome, cpf, email, data_nascimento, end_rua, end_numero, end_bairro, end_cidade, end_cep) 
    VALUES (p_nome, p_cpf, p_email, p_data_nasc, p_rua, p_numero, p_bairro, p_cidade, p_cep);
    
    SET v_id = LAST_INSERT_ID();
    
    INSERT INTO Aluno (id_pessoa, matricula, data_inicio, ativo) 
    VALUES (v_id, p_matricula, CURDATE(), TRUE);
END;
$$

CREATE TRIGGER trg_valida_peso_ficha
BEFORE UPDATE ON Ficha_Medica
FOR EACH ROW
BEGIN
    IF NEW.peso <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O peso deve ser maior que zero.';
    END IF;
END;
$$

DELIMITER ;

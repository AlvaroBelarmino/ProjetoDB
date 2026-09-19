-- ============================================================
-- ArenaFit - Sistema de Gestao de Academia
-- Schema de referencia (espelha o modelo .mwb)
-- ============================================================

CREATE DATABASE IF NOT EXISTS arena_fit;
USE arena_fit;

-- ------------------------------------------------------------
-- LAYER: Pessoas (heranca Pessoa -> Aluno / Instrutor)
-- ------------------------------------------------------------

CREATE TABLE Pessoa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    -- atributo composto "endereco" expandido no modelo relacional
    end_rua VARCHAR(120) NOT NULL,
    end_numero VARCHAR(10) NOT NULL,
    end_bairro VARCHAR(80) NOT NULL,
    end_cidade VARCHAR(80) NOT NULL,
    end_cep CHAR(8) NOT NULL
);

-- atributo multivalorado: telefones de uma pessoa
CREATE TABLE Telefone (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    ddd CHAR(2) NOT NULL,
    numero VARCHAR(9) NOT NULL,
    tipo ENUM('Celular', 'Residencial', 'Comercial') NOT NULL DEFAULT 'Celular',
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id)
);

-- heranca / especializacao
CREATE TABLE Aluno (
    id_pessoa INT PRIMARY KEY,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    data_inicio DATE NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id)
);

CREATE TABLE Instrutor (
    id_pessoa INT PRIMARY KEY,
    cref VARCHAR(20) NOT NULL UNIQUE,
    especialidade VARCHAR(80) NOT NULL,
    data_contratacao DATE NOT NULL,
    -- relacionamento recursivo 1:N (instrutor supervisor)
    id_supervisor INT NULL,
    FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id),
    FOREIGN KEY (id_supervisor) REFERENCES Instrutor(id_pessoa)
);

-- relacionamento 1:1 (cada aluno possui no maximo uma ficha medica)
CREATE TABLE Ficha_Medica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL UNIQUE,
    tipo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    restricoes TEXT NULL,
    peso DECIMAL(5,2) NOT NULL,
    altura DECIMAL(3,2) NOT NULL,
    -- atributo derivado (IMC = peso / altura^2) documentado no modelo
    data_avaliacao DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_pessoa)
);

-- ------------------------------------------------------------
-- LAYER: Estrutura
-- ------------------------------------------------------------

CREATE TABLE Unidade (
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

CREATE TABLE Plano (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    duracao_meses INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    modalidade ENUM('Mensal', 'Trimestral', 'Semestral', 'Anual') NOT NULL,
    CHECK (duracao_meses > 0),
    CHECK (valor > 0)
);

CREATE TABLE Equipamento (
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

CREATE TABLE Modalidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    descricao TEXT NULL,
    nivel ENUM('Iniciante', 'Intermediario', 'Avancado') NOT NULL
);

CREATE TABLE Aula (
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
-- LAYER: Relacionamentos / Operacional (tabelas N:M nomeadas)
-- ------------------------------------------------------------

-- N:M Aluno x Plano  =>  Assinatura
CREATE TABLE Assinatura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_plano INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    status ENUM('Ativa', 'Suspensa', 'Cancelada', 'Encerrada') NOT NULL DEFAULT 'Ativa',
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_pessoa),
    FOREIGN KEY (id_plano) REFERENCES Plano(id)
);

-- N:M Aluno x Aula  =>  Inscricao_Aula
CREATE TABLE Inscricao_Aula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_aula INT NOT NULL,
    data_inscricao DATE NOT NULL,
    presenca BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (id_aluno, id_aula),
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_pessoa),
    FOREIGN KEY (id_aula) REFERENCES Aula(id)
);

-- N:M Instrutor x Modalidade  =>  Habilitacao
CREATE TABLE Habilitacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_instrutor INT NOT NULL,
    id_modalidade INT NOT NULL,
    data_certificacao DATE NOT NULL,
    UNIQUE (id_instrutor, id_modalidade),
    FOREIGN KEY (id_instrutor) REFERENCES Instrutor(id_pessoa),
    FOREIGN KEY (id_modalidade) REFERENCES Modalidade(id)
);

-- N:M recursivo Modalidade x Modalidade  =>  Pre_Requisito
-- (uma modalidade pode exigir outra como pre-requisito)
CREATE TABLE Pre_Requisito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_modalidade INT NOT NULL,
    id_modalidade_requerida INT NOT NULL,
    obrigatoriedade ENUM('Obrigatorio', 'Recomendado') NOT NULL DEFAULT 'Obrigatorio',
    UNIQUE (id_modalidade, id_modalidade_requerida),
    CHECK (id_modalidade <> id_modalidade_requerida),
    FOREIGN KEY (id_modalidade) REFERENCES Modalidade(id),
    FOREIGN KEY (id_modalidade_requerida) REFERENCES Modalidade(id)
);

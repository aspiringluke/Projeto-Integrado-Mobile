CREATE TABLE IF NOT EXISTS Tags (
    idTag INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(255),
    cor VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS Diagramas (
    idDiagrama INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Notas (
    idNota INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(255),
    pastas_idPasta INT,
    FOREIGN KEY (pastas_idPasta) REFERENCES Pastas(idPasta)
);

CREATE TABLE IF NOT EXISTS Pastas (
    idPasta INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Projeto (
    idProjeto INT PRIMARY KEY AUTO_INCREMENT,
    tag_idTag INT,
    sintese VARCHAR(100),
    notas_idNota INT,
    estilo JSON,
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag),
    FOREIGN KEY (notas_idNota) REFERENCES Notas(idNota)
);

CREATE TABLE IF NOT EXISTS Personagens (
    idPersonagem INT PRIMARY KEY AUTO_INCREMENT,
    informacoes_gerais JSON,
    aparencia JSON,
    historia JSON,
    psique JSON,
    tag_idTag INT,
    projeto_idProjeto INT,
    FOREIGN KEY (projeto_idProjeto) REFERENCES Projeto(idProjeto)
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

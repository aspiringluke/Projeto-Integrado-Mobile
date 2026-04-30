CREATE TABLE IF NOT EXISTS Tags (
    idTag INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(255),
    cor VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS Diagramas (
    idDiagrama INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Nota (
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
    nota_idNota INT,
    estilo JSON,
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag),
    FOREIGN KEY (nota_idNota) REFERENCES Nota(idNota)
);

CREATE TABLE IF NOT EXISTS Personagem (
    idPersonagem INT PRIMARY KEY AUTO_INCREMENT,
    informacoes_gerais JSON,
    aparencia JSON,
    historia JSON,
    psique JSON,
    tag_idTag INT,
    projeto_idProjeto INT,
    FOREIGN KEY (projeto_idProjeto) REFERENCES Projeto(idProjeto),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

CREATE TABLE IF NOT EXISTS Nos (
    idNos INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(100),
    diagrama_idDiagrama INT,
    FOREIGN KEY (diagrama_idDiagrama) REFERENCES Diagramas(idDiagrama)
);

CREATE TABLE IF NOT EXISTS Aresta (
    idAresta INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(200),
    diagrama_idDiagrama INT,
    id_no_origem INT UNIQUE,
    id_no_destino INT UNIQUE,
    forma_linha ENUM('seccionada', 'continua'),
    forma_ponta_origem ENUM('vazio', 'traingular', 'quadrada', 'circular'),
    forma_ponta_destino ENUM('vazio', 'traingular', 'quadrada', 'circular'),
    FOREIGN KEY (diagrama_idDiagrama) REFERENCES Diagramas(idDiagrama),
    FOREIGN KEY (id_no_origem) REFERENCES Nos(idNos),
    FOREIGN KEY (id_no_destino) REFERENCES Nos(idNos)
);

CREATE TABLE IF NOT EXISTS nos_has_tags (
    nos_idNos INT PRIMARY KEY,
    tag_idTag INT PRIMARY KEY,
    FOREIGN KEY (nos_idNos) REFERENCES Nos(idNos),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

CREATE TABLE IF NOT EXISTS notas_has_tags (
    notas_idNotas INT PRIMARY KEY,
    tag_idTag INT PRIMARY KEY,
    FOREIGN KEY (notas_idNota) REFERENCES Nota(idNota),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

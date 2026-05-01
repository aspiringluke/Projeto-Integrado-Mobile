CREATE TABLE IF NOT EXISTS Tags (
    idTag INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    cor VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS Diagramas (
    idDiagrama INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS Pastas (
    idPasta INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Nota (
    idNota INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    pastas_idPasta INTEGER,
    FOREIGN KEY (pastas_idPasta) REFERENCES Pastas(idPasta)
);

CREATE TABLE IF NOT EXISTS Projeto (
    idProjeto INTEGER PRIMARY KEY AUTOINCREMENT,
    tag_idTag INTEGER,
    sintese VARCHAR(100),
    nota_idNota INTEGER,
    estilo TEXT,
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag),
    FOREIGN KEY (nota_idNota) REFERENCES Nota(idNota)
);

CREATE TABLE IF NOT EXISTS Personagem (
    idPersonagem INTEGER PRIMARY KEY AUTOINCREMENT,
    informacoes_gerais TEXT, 
    aparencia TEXT,          
    historia TEXT,           
    psique TEXT,             
    tag_idTag INTEGER,
    projeto_idProjeto INTEGER,
    FOREIGN KEY (projeto_idProjeto) REFERENCES Projeto(idProjeto),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

CREATE TABLE IF NOT EXISTS Nos (
    idNos INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(100),
    diagrama_idDiagrama INTEGER,
    FOREIGN KEY (diagrama_idDiagrama) REFERENCES Diagramas(idDiagrama)
);

CREATE TABLE IF NOT EXISTS Aresta (
    idAresta INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(200),
    diagrama_idDiagrama INTEGER,
    id_no_origem INTEGER UNIQUE,
    id_no_destino INTEGER UNIQUE,
    forma_linha TEXT CHECK(forma_linha IN ('seccionada', 'continua')), 
    forma_ponta_origem TEXT CHECK(forma_ponta_origem IN ('vazio', 'traingular', 'quadrada', 'circular')),
    forma_ponta_destino TEXT CHECK(forma_ponta_destino IN ('vazio', 'traingular', 'quadrada', 'circular')),
    FOREIGN KEY (diagrama_idDiagrama) REFERENCES Diagramas(idDiagrama),
    FOREIGN KEY (id_no_origem) REFERENCES Nos(idNos),
    FOREIGN KEY (id_no_destino) REFERENCES Nos(idNos)
);

CREATE TABLE IF NOT EXISTS nos_has_tags (
    nos_idNos INTEGER,
    tag_idTag INTEGER,
    PRIMARY KEY (nos_idNos, tag_idTag), -
    FOREIGN KEY (nos_idNos) REFERENCES Nos(idNos),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

CREATE TABLE IF NOT EXISTS notas_has_tags (
    notas_idNota INTEGER, 
    tag_idTag INTEGER,
    PRIMARY KEY (notas_idNota, tag_idTag), 
    FOREIGN KEY (notas_idNota) REFERENCES Nota(idNota),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

final String _databaseName = "wireframe.db";

Database getConnection()
{
    final Database conn = sqlite3.open(_databaseName);
    return conn;
}

void verifyDatabaseExistance()
{
    // verify whether the db file exists or not
    // if it doesn't, open a connection and create
    // all the necessary tables
    final databasePath = _databaseName;
    if(!File(databasePath).existsSync())
    {
        final conn = getConnection();
        conn.execute(
            """
CREATE TABLE IF NOT EXISTS Tags (
    idTag INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    cor VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS Diagramas (
    idDiagrama INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Nota (
    idNota INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    pastas_idPasta INTEGER,
    FOREIGN KEY (pastas_idPasta) REFERENCES Pastas(idPasta)
);

CREATE TABLE IF NOT EXISTS Pastas (
    idPasta INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Projeto (
    idProjeto INTEGER PRIMARY KEY AUTOINCREMENT,
    tag_idTag INTEGER,
    sintese VARCHAR(100),
    estilo JSON,
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

CREATE TABLE IF NOT EXISTS Personagem (
    idPersonagem INTEGER PRIMARY KEY AUTOINCREMENT,
    informacoes_gerais JSON,
    aparencia JSON,
    historia JSON,
    psique JSON,
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
    FOREIGN KEY (diagrama_idDiagrama) REFERENCES Diagramas(idDiagrama),
    FOREIGN KEY (id_no_origem) REFERENCES Nos(idNos),
    FOREIGN KEY (id_no_destino) REFERENCES Nos(idNos)
);

CREATE TABLE IF NOT EXISTS nos_has_tags (
    nos_idNos INTEGER PRIMARY KEY,
    tag_idTag INTEGER NOT NULL,
    FOREIGN KEY (nos_idNos) REFERENCES Nos(idNos),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);

CREATE TABLE IF NOT EXISTS notas_has_tags (
    notas_idNotas INTEGER PRIMARY KEY,
    tag_idTag INTEGER NOT NULL,
    FOREIGN KEY (notas_idNotas) REFERENCES Nota(idNota),
    FOREIGN KEY (tag_idTag) REFERENCES Tags(idTag)
);
            """
        );
        conn.close();
    }
    
}

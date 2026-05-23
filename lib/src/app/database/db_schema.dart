import 'package:sqlite3/common.dart';

const String dbFullSchemaSql = """
CREATE TABLE IF NOT EXISTS Tags (
    idTag INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    cor VARCHAR(10),
    grupoTag_idGrupoTag INTEGER,
    FOREIGN KEY (grupoTag_idGrupoTag) REFERENCES GrupoTag(idGrupoTag)
);

CREATE TABLE IF NOT EXISTS GrupoTag (
    idGrupoTag INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    cor VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS Diagramas (
    idDiagrama INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Nota (
    idNota INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(255),
    descricao TEXT,
    cor VARCHAR(15),
    metadata TEXT,
    pastas_idPasta INTEGER,
    FOREIGN KEY (pastas_idPasta) REFERENCES Pastas(idPasta)
);

CREATE TABLE IF NOT EXISTS Pastas (
    idPasta INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR(100),
    cor VARCHAR(15),
    pastas_idPasta INTEGER,
    metadata TEXT,
    FOREIGN KEY (pastas_idPasta) REFERENCES Pastas(idPasta)
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
CREATE TABLE IF NOT EXISTS Conversa (
    idConversa INTEGER PRIMARY KEY AUTOINCREMENT,
    mensagens TEXT,
    titulo TEXT
);
""";

void initializeSchema(CommonDatabase conn) {
  conn.execute(dbFullSchemaSql);

  _ensureColumn(
    conn,
    tableName: 'Pastas',
    columnName: 'pastas_idPasta',
    definition: 'INTEGER REFERENCES Pastas(idPasta)',
  );
  _ensureColumn(
    conn,
    tableName: 'Pastas',
    columnName: 'metadata',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Nota',
    columnName: 'metadata',
    definition: 'TEXT',
  );
  _ensureColumn(conn, tableName: 'Projeto', columnName: 'titulo', definition: 'TEXT');
  _ensureColumn(conn, tableName: 'Projeto', columnName: 'corCapa', definition: 'TEXT');
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'corDestaque',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'imagemCapa',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'imagemDestaque',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'tagsJson',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'fixado',
    definition: 'INTEGER DEFAULT 0',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'ordemNaoFixada',
    definition: 'INTEGER DEFAULT 0',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'modoVisualizacaoPersonagens',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Projeto',
    columnName: 'colunasGradePersonagens',
    definition: 'INTEGER DEFAULT 3',
  );
  _ensureColumn(conn, tableName: 'Personagem', columnName: 'nome', definition: 'TEXT');
  _ensureColumn(
    conn,
    tableName: 'Personagem',
    columnName: 'corDestaque',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Personagem',
    columnName: 'payload',
    definition: 'TEXT',
  );
  _ensureColumn(
    conn,
    tableName: 'Personagem',
    columnName: 'fixado',
    definition: 'INTEGER DEFAULT 0',
  );
  _ensureColumn(
    conn,
    tableName: 'Personagem',
    columnName: 'ordemNaoFixada',
    definition: 'INTEGER DEFAULT 0',
  );

  _ensureTimestampColumns(conn, 'Nota');
  _ensureTimestampColumns(conn, 'Pastas');
  _ensureTimestampColumns(conn, 'Projeto');
  _ensureTimestampColumns(conn, 'Personagem');

  _ensureColumn(
  conn,
  tableName: 'Conversa',
  columnName: 'titulo',
  definition: 'TEXT',
);
}


void _ensureColumn(
  CommonDatabase conn, {
  required String tableName,
  required String columnName,
  required String definition,
}) {
  final hasColumn = conn.select("""
      SELECT 1
      FROM pragma_table_info('$tableName')
      WHERE name = '$columnName'
      LIMIT 1
      """).isNotEmpty;

  if (hasColumn) return;

  conn.execute("""
      ALTER TABLE $tableName
      ADD COLUMN $columnName $definition
      """);
}

void _ensureTimestampColumns(CommonDatabase conn, String tableName) {
  for (final column in const ['createdAt', 'lastModified', 'lastAccessed']) {
    _ensureColumn(
      conn,
      tableName: tableName,
      columnName: column,
      definition: 'TEXT',
    );
    conn.execute(
      """
        UPDATE $tableName
        SET $column = COALESCE($column, ?)
        """,
      [DateTime.now().toIso8601String()],
    );
  }
}

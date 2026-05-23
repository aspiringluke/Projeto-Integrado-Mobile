class ConversaModel {
  final int? idConversa;
  final List<Map<String, dynamic>> mensagens;

  ConversaModel({
    this.idConversa,
    required this.mensagens,
  });

  Map<String, dynamic> toMap() {
    return {
      'idConversa': idConversa,
      'mensagens': mensagens,
    };
  }

  factory ConversaModel.fromMap(
      Map<String, dynamic> map) {

    return ConversaModel(
      idConversa: map['idConversa'],
      mensagens:
          List<Map<String,dynamic>>
          .from(
            map['mensagens']
          ),
    );
  }
}
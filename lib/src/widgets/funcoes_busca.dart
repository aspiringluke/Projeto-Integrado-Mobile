import 'package:flutter/material.dart';

class FuncoesBusca extends StatelessWidget {
  const FuncoesBusca({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        child: Card(
            child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    ElevatedButton(onPressed: null, child: Text("A")),
                    ElevatedButton(onPressed: null, child: Text("B")),
                    SearchBar(hintText: "Digite aqui...", constraints: BoxConstraints(maxWidth: 220, minHeight: 40),)
            ],)
        )
    );
  }
}
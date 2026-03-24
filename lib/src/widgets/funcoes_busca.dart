import 'package:flutter/material.dart';

class FuncoesBusca extends StatelessWidget {
  const FuncoesBusca({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
                ]
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Buscar...",
                  hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProjectCard extends StatefulWidget {
  final String title;
  
  const ProjectCard({super.key, this.title = "Projeto 1"});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _toggleExpand,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(16),
                          bottom: _isExpanded ? Radius.zero : const Radius.circular(16),
                        ),
                        image: const DecorationImage(
                          image: NetworkImage('https://picsum.photos/seed/flower/400/100'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: const Radius.circular(16),
                            bottom: _isExpanded ? Radius.zero : const Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 40, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              _isExpanded ? "Ver menos..." : "Ver mais...",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_isExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history, size: 16, color: Colors.black54),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Última Modificação: dd/MM/aaaa hh:mm, há xxx atrás.",
                                  style: TextStyle(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
                                onPressed: () {},
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFFDF6EB8), width: 2)),
                            ),
                            child: const Text(
                              "Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas, iaculis massa nisl malesuada lacinia integer nunc posuere.",
                              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              _buildTag("Tag 1", const Color(0xFFF8BBD0)),
                              const SizedBox(width: 8),
                              _buildTag("Tag 2", const Color(0xFFBBDEFB)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildCircle(),
                                  const SizedBox(width: 4),
                                  _buildCircle(),
                                  const SizedBox(width: 4),
                                  _buildCircle(),
                                ],
                              ),
                              const Icon(Icons.swap_horiz, color: Colors.black54),
                            ],
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 10,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2F5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.push_pin_outlined, color: Colors.black54, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

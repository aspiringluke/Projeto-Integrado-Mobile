part of '../pages/characters_section.dart';

class _CharactersMockRepository {
  const _CharactersMockRepository();

  List<_CharacterCardData> fetchCharacters() {
    return const <_CharacterCardData>[
      _CharacterCardData(
        name: 'Personagem 1',
        alias: 'Vulgo Personagem 1',
        accent: Color(0xFFE4C2D7),
        avatarColor: Color(0xFFF4B37E),
        icon: Icons.person_rounded,
        birthYear: 2002,
        birthDay: 21,
        birthMonth: 3,
        heightCm: 168,
        weightKg: 58,
        quote: 'Frase de efeito do personagem.',
        synopsis: '',
        seed: 11,
      ),
      _CharacterCardData(
        name: 'Personagem 2',
        alias: 'Vulgo Personagem 2',
        accent: Color(0xFFD9D4E9),
        avatarColor: Color(0xFF7EA7F4),
        icon: Icons.person_rounded,
        birthYear: 1998,
        birthDay: 8,
        birthMonth: 11,
        heightCm: 182,
        weightKg: 74,
        quote: 'Outra frase de efeito do personagem.',
        synopsis: '',
        seed: 23,
      ),
      _CharacterCardData(
        name: 'Personagem 3',
        alias: 'Vulgo Personagem 3',
        accent: Color(0xFFE7E0B7),
        avatarColor: Color(0xFFF4B37E),
        icon: Icons.person_rounded,
        birthYear: 2001,
        birthDay: 19,
        birthMonth: 7,
        heightCm: 175,
        weightKg: 67,
        quote: 'Frase de efeito do personagem.',
        synopsis: '',
        seed: 37,
      ),
    ];
  }
}

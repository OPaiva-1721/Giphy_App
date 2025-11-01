import 'package:intl/intl.dart';

/// Funções auxiliares
class Helpers {
  /// Formata número com separador de milhares
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'pt_BR').format(number);
  }

  /// Formata bytes para string legível
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Formata data relativa (ex: "há 2 horas")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return 'há ${(difference.inDays / 7).floor()} sem';
    } else if (difference.inDays < 365) {
      return 'há ${(difference.inDays / 30).floor()} meses';
    } else {
      return 'há ${(difference.inDays / 365).floor()} anos';
    }
  }

  /// Formata data completa
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(dateTime);
  }

  /// Formata data e hora
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime);
  }

  /// Trunca texto com reticências
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Valida email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Gera cor aleatória baseada em string
  static int colorFromString(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash & 0x00FFFFFF | 0xFF000000;
  }

  /// Retorna emoji de raridade
  static String getRarityEmoji(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return '⚪';
      case 'rare':
        return '🔵';
      case 'epic':
        return '🟣';
      case 'legendary':
        return '🟡';
      default:
        return '⚪';
    }
  }

  /// Retorna cor de raridade
  static int getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 0xFF9E9E9E;
      case 'rare':
        return 0xFF2196F3;
      case 'epic':
        return 0xFF9C27B0;
      case 'legendary':
        return 0xFFFFEB3B;
      default:
        return 0xFF9E9E9E;
    }
  }
}


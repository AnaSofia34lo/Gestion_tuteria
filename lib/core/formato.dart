/// Formatos de fecha en español sin dependencias adicionales.
class Formato {
  Formato._();

  static const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  static const _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// "vie 13 nov · 10:00 – 11:00"
  static String franja(DateTime inicio) {
    final l = inicio.toLocal();
    final fin = l.add(const Duration(hours: 1));
    return '${_dias[l.weekday - 1]} ${l.day} ${_meses[l.month - 1]} · '
        '${_dos(l.hour)}:00 – ${_dos(fin.hour)}:00';
  }

  static String fecha(DateTime d) {
    final l = d.toLocal();
    return '${_dias[l.weekday - 1]} ${l.day} ${_meses[l.month - 1]} ${l.year}';
  }
}

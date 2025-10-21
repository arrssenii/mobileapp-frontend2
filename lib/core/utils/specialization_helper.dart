class SpecializationHelper {
  static String normalize(String specialization) {
    final spec = specialization.toLowerCase();
    
    if (spec.contains('гинеколог')) return 'Гинеколог';
    if (spec.contains('кардиолог')) return 'Кардиолог';
    if (spec.contains('хирург') || 
      spec.contains('травматолог') || 
      spec.contains('ортопед') || 
      spec.contains('нейрохирург') || 
      spec.contains('торакальный') || 
      spec.contains('абдоминальный') || 
      spec.contains('сосудистый') || 
      spec.contains('пластический')) {
    return 'Хирург';
  }
    if (spec.contains('офтальмолог') || spec.contains('окулист')) return 'Офтальмолог';
    if (spec.contains('онколог')) return 'Онколог';
    if (spec.contains('эндокринолог')) return 'Эндокринолог';
    if (spec.contains('терапевт') || spec.contains('семейный врач')) return 'Терапевт';
    
    return 'Терапевт'; // По умолчанию
  }
}

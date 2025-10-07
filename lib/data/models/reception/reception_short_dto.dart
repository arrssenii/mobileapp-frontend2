class ReceptionShortDTO {
  final int id;
  final int patient_id;
  final String date;
  final bool is_smp;

  ReceptionShortDTO({
    required this.id,
    required this.patient_id,
    required this.date,
    required this.is_smp,
  });

  factory ReceptionShortDTO.fromJson(Map<String, dynamic> json) {
    return ReceptionShortDTO(
      id: json['id'],
      patient_id: json['patient_id'],
      date: json['date'],
      is_smp: json['is_smp'],
    );
  }
}
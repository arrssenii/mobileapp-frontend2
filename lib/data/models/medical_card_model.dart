class MedicalCard {
  final String? additionalPhone;
  final String? address;
  final String? age;
  final AttendingDoctor? attendingDoctor;
  final String? birthDate;
  final Certificate? certificate;
  final String? displayName;
  final String? email;
  final LegalRepresentative? legalRepresentative;
  final String? mobilePhone;
  final String? patientId;
  final Policy? policy;
  final Relative? relative;
  final String? snils;
  final String? workplace;

  MedicalCard({
    this.additionalPhone,
    this.address,
    this.age,
    this.attendingDoctor,
    this.birthDate,
    this.certificate,
    this.displayName,
    this.email,
    this.legalRepresentative,
    this.mobilePhone,
    this.patientId,
    this.policy,
    this.relative,
    this.snils,
    this.workplace,
  });

  factory MedicalCard.fromJson(Map<String, dynamic> json) {
    return MedicalCard(
      additionalPhone: json['additional_phone'] as String?,
      address: json['address'] as String?,
      age: json['age'] as String?,
      attendingDoctor: json['attending_doctor'] != null
          ? AttendingDoctor.fromJson(json['attending_doctor'] as Map<String, dynamic>)
          : null,
      birthDate: json['birth_date'] as String?,
      certificate: json['certificate'] != null
          ? Certificate.fromJson(json['certificate'] as Map<String, dynamic>)
          : null,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      legalRepresentative: json['legal_representative'] != null
          ? LegalRepresentative.fromJson(json['legal_representative'] as Map<String, dynamic>)
          : null,
      mobilePhone: json['mobile_phone'] as String?,
      patientId: json['patient_id'] as String?,
      policy: json['policy'] != null
          ? Policy.fromJson(json['policy'] as Map<String, dynamic>)
          : null,
      relative: json['relative'] != null
          ? Relative.fromJson(json['relative'] as Map<String, dynamic>)
          : null,
      snils: json['snils'] as String?,
      workplace: json['workplace'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'additional_phone': additionalPhone,
      'address': address,
      'age': age,
      'attending_doctor': attendingDoctor?.toJson(),
      'birth_date': birthDate,
      'certificate': certificate?.toJson(),
      'display_name': displayName,
      'email': email,
      'legal_representative': legalRepresentative?.toJson(),
      'mobile_phone': mobilePhone,
      'patient_id': patientId,
      'policy': policy?.toJson(),
      'relative': relative?.toJson(),
      'snils': snils,
      'workplace': workplace,
    };
  }
}

class AttendingDoctor {
  final String? attachmentEnd;
  final String? attachmentStart;
  final String? clinic;
  final String? fullName;
  final String? policyOrCertNumber;

  AttendingDoctor({
    this.attachmentEnd,
    this.attachmentStart,
    this.clinic,
    this.fullName,
    this.policyOrCertNumber,
  });

  factory AttendingDoctor.fromJson(Map<String, dynamic> json) {
    return AttendingDoctor(
      attachmentEnd: json['attachment_end'] as String?,
      attachmentStart: json['attachment_start'] as String?,
      clinic: json['clinic'] as String?,
      fullName: json['full_name'] as String?,
      policyOrCertNumber: json['policy_or_cert_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachment_end': attachmentEnd,
      'attachment_start': attachmentStart,
      'clinic': clinic,
      'full_name': fullName,
      'policy_or_cert_number': policyOrCertNumber,
    };
  }
}

class Certificate {
  final String? date;
  final String? number;

  Certificate({
    this.date,
    this.number,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      date: json['date'] as String?,
      number: json['number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'number': number,
    };
  }
}

class LegalRepresentative {
  final String? id;
  final String? name;

  LegalRepresentative({
    this.id,
    this.name,
  });

  factory LegalRepresentative.fromJson(Map<String, dynamic> json) {
    return LegalRepresentative(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Policy {
  final String? number;
  final String? type;

  Policy({
    this.number,
    this.type,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      number: json['number'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'type': type,
    };
  }
}

class Relative {
  final String? name;
  final String? status;

  Relative({
    this.name,
    this.status,
  });

  factory Relative.fromJson(Map<String, dynamic> json) {
    return Relative(
      name: json['name'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
    };
  }
}
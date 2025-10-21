import 'package:kvant_medpuls/presentation/pages/pdf_sign_screen.dart';
import 'package:kvant_medpuls/presentation/pages/pdf_view_screen.dart';
import 'package:kvant_medpuls/presentation/pages/services_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import 'package:provider/provider.dart';
import '../../services/pdf_service.dart';
import '../pages/consultation_screen.dart';
import 'custom_card.dart';
import '../../core/theme/theme_config.dart';
import 'patient_options_dialog.dart';

class PatientCardWidget extends StatefulWidget {
  final Map<String, dynamic> patient;
  final int emergencyCallId;
  final VoidCallback onPatientUpdated;
  final VoidCallback onCallCompleted;

  const PatientCardWidget({
    super.key,
    required this.patient,
    required this.emergencyCallId,
    required this.onPatientUpdated,
    required this.onCallCompleted,
  });

  @override
  State<PatientCardWidget> createState() => _PatientCardWidgetState();
}

class _PatientCardWidgetState extends State<PatientCardWidget> {
  final PdfService _pdfService = PdfService();

  void _startConsultation() {
    final fullName = _getFullName();
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patientName: fullName,
          appointmentType: 'emergency',
          recordId: widget.patient['receptionId'], 
          doctorId: apiClient.currentDoctorId ?? 1,
          emergencyCallId: widget.emergencyCallId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          widget.patient['hasConclusion'] = true;
        });
        widget.onPatientUpdated();
        _updateCallStatusIfCompleted();
      }
    });
  }

  void _openServicesList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesScreen(
          patientId: widget.patient['patientId'] ?? 0,
          receptionId: widget.patient['receptionId'] ?? 0,
          onServicesSelected: (selectedServices) {
            if (selectedServices.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Выбрано услуг: ${selectedServices.length}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _updateCallStatusIfCompleted() async {
    widget.onCallCompleted();
  }

  void _showPatientOptions() {
    showDialog(
      context: context,
      builder: (dialogContext) => PatientOptionsDialog(
        patient: _transformPatientData(),
        onPatientCard: () {
          // TODO: Реализовать переход к карточке пациента
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Переход к карточке пациента')),
          );
        },
        onEmk: () {
          // TODO: Реализовать переход к ЭМК
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Переход к ЭМК')),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _transformPatientData() {
    return {
      'first_name': widget.patient['firstName'] ?? '',
      'last_name': widget.patient['lastName'] ?? '',
      'middle_name': widget.patient['middleName'] ?? '',
      'birth_date': widget.patient['birth_date'],
      'is_male': widget.patient['is_male'],
    };
  }

  String _getFullName() {
    return '${widget.patient['lastName'] ?? ''} ${widget.patient['firstName'] ?? ''} ${widget.patient['middleName'] ?? ''}'.trim();
  }

  String _getBirthDate() {
    return widget.patient['birth_date'] != null
        ? DateFormat('dd.MM.yyyy').format(DateTime.parse(widget.patient['birth_date']))
        : '';
  }

  String _getAge() {
    return widget.patient['birth_date'] != null
        ? (DateTime.now().year - DateTime.parse(widget.patient['birth_date']).year).toString()
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _getFullName();
    final birthDate = _getBirthDate();
    final age = _getAge();
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: _showPatientOptions,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: CustomCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с ФИО и статусом
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${birthDate.isNotEmpty ? birthDate : ''}${age != '' ? ' ($age лет)' : ''}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Основные кнопки действий
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _startConsultation,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton.icon(
                              onPressed: _startConsultation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.medical_services, size: 16),
                              label: const Text(
                                'Заключение',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openServicesList,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton.icon(
                              onPressed: _openServicesList,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.list_alt, size: 16),
                              label: const Text(
                                'Услуги',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // TabBar для документов
                  GestureDetector(
                    onTap: () {}, // Пустой обработчик для предотвращения всплытия
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            tabs: const [
                              Tab(text: 'Прививки'),
                              Tab(text: 'Согласие'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: TabBarView(
                            children: [
                              // Вкладка "Прививки"
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.vaccines_outlined,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Информация о прививках отсутствует",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              // Вкладка "Согласие"
                              Column(
                                children: [
                                  const Text(
                                    "Работа с документами согласия",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                                        label: const Text('Открыть PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.secondaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        onPressed: () async {
                                          try {
                                            final pdfFile = await _pdfService.generateFullPatientAgreementWithBackendSignature(
                                              fullName: fullName,
                                              address: widget.patient['address'] ?? 'не указано',
                                              receptionId: widget.patient['receptionId'].toString(),
                                              apiClient: apiClient,
                                            );
                                            Uint8List pdfBytes;
                                            if (kIsWeb) {
                                              await _pdfService.openPdf(pdfFile);
                                              pdfBytes = await pdfFile!.readAsBytes();
                                            } else {
                                              pdfBytes = await pdfFile!.readAsBytes();
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PdfViewerScreen(pdfBytes: pdfBytes),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Ошибка генерации PDF: $e')),
                                            );
                                          }
                                        },
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Подписать'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final receptionId = widget.patient['receptionId']?.toString();
                                          if (receptionId != null) {
                                            try {
                                              final signatureBytes = await Navigator.push<Uint8List>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PdfSignatureScreen(
                                                    receptionId: receptionId,
                                                  ),
                                                ),
                                              );
                                              if (signatureBytes != null) {
                                                await apiClient.uploadReceptionSignature(
                                                  receptionId: receptionId,
                                                  signatureBytes: signatureBytes
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Подпись добавлена')),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Ошибка подписи: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ID приема: ${widget.patient['receptionId'] ?? 'Не указан'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

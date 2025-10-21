import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:kvant_medpuls/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;


class PdfService {

  Future<pw.Font> _loadRobotoFont() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    return pw.Font.ttf(fontData);
  }

  // Генерация PDF полного согласия
  Future<File?> generateFullPatientAgreement({
    required String fullName,
    required String address,
    String? patientSignatureBase64,
    String? doctorSignatureBase64,
  }) async {
    final pdf = pw.Document();
    final currentDate = DateTime.now();
    final robotoFont = await _loadRobotoFont(); // используем шрифт
    final dateString = '${currentDate.day}.${currentDate.month}.${currentDate.year}';

    // String patientSignatureBase64 = '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';
    // final bytes = base64Decode(patientSignatureBase64!);
    // final image = img.decodeImage(bytes)!;

    // // Конвертируем в JPEG
    // final jpegBytes = img.encodeJpg(image);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'ООО "МедСервис"',
              style: pw.TextStyle(font: robotoFont, fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'ЛО-78-01-009541 от 16 января 2019, срок действия: бессрочно\n'
            '194100, г. Санкт-Петербург, пр-кт Лесной, дом 63, лит. А, пом. 1Н\n'
            'Тел: +7 (812) 740-12-52 Email:',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(font: robotoFont, fontSize: 8),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'ПИСЬМЕННОЕ СОГЛАСИЕ НА осмотр',
              style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Я:',
              style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              ),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  child: pw.Text(fullName.isNotEmpty ? fullName : 'не указано',
                    style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
                    ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                  'Дата:',
                  style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              ),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  child: pw.Text(dateString),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Адрес (по месту регистрации): $address',
            style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'ИНФОРМИРОВАННОЕ ДОБРОВОЛЬНОЕ СОГЛАСИЕ ПАЦИЕНТА НА МЕДИЦИНСКОЕ ОБСЛЕДОВАНИЕ, '
            'ВМЕШАТЕЛЬСТВО, ОПЕРАЦИЮ, ЛЕЧЕНИЕ',
            style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Настоящее согласие составлено в соответствии со ст. 20 ФЗ №323 от 21.11.2011 «Об основах охраны здоровья граждан в РФ» '
            'и в соответствии с Приказом МЗСР РФ от 23.04.2012 г. N 390Н',
            style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Мне даны полные и всесторонние разъяснения о характере, степени тяжести и возможных осложнениях моего заболевания (здоровья представляемого);',
            style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.justify,
          ),
          pw.Text(
            'Я ознакомлен(а) с распорядком и правилами лечебно-охранительного режима ООО "ЭкспрессМедСервис" и обязуюсь их соблюдать;',
            style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.justify,
          ),
          pw.Text(
            'Добровольно даю свое согласие на проведение медицинского обследования, в том числе: выявление жалоб, сбор анамнеза, осмотр, пальпацию, перкуссию, аускультацию...',
            style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Я согласен (а) на проведение в ООО "ЭкспрессМедСервис" указанных в договоре платных услуг медицинских действий.',
            textAlign: pw.TextAlign.justify,
            style: pw.TextStyle(font: robotoFont ,fontWeight: pw.FontWeight.bold),
          ),
          // … можно добавить остальные абзацы по аналогии
          pw.SizedBox(height: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Подпись пациента',
                style: pw.TextStyle(
                  font: robotoFont,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (patientSignatureBase64 != null && patientSignatureBase64.isNotEmpty)
                pw.Container(
                  width: 150, // максимальная ширина блока для подписи
                  height: 50, // максимальная высота блока
                  child: pw.Image(
                    pw.MemoryImage(base64Decode(patientSignatureBase64.trim())),
                    fit: pw.BoxFit.contain, // сохраняем соотношение сторон
                  ),
                )
              else
                pw.Container(height: 50), // пустое место, если подписи нет
              pw.SizedBox(height: 5),
              pw.Text(
                '(подпись)',
                style: pw.TextStyle(
                  font: robotoFont,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Подпись медработника', style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold)),
              doctorSignatureBase64 != null && doctorSignatureBase64.isNotEmpty
                  ? pw.Image(pw.MemoryImage(base64Decode(doctorSignatureBase64)), height: 50)
                  : pw.Container(height: 50), // пустое место
              pw.Text(
                'Дата: $dateString',
                style: pw.TextStyle(font: robotoFont, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // Веб: открываем PDF в новом окне
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
      // На вебе возвращаем null, т.к. File не существует
      return null;
    } else {
      // Мобильные и десктоп
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/full_agreement.pdf');
      await file.writeAsBytes(pdfBytes);
      return file;
    }
  }

  Future<void> openPdf(File? file) async {
    if (file == null) return; // веб уже открыл PDF
    await OpenFile.open(file.path);
  }

  Future<Uint8List> addSignatureToPdf({
    required Uint8List pdfBytes,
    required Uint8List signatureBytes,
  }) async {
    // Загружаем существующий PDF
    sf.PdfDocument document = sf.PdfDocument(inputBytes: pdfBytes);

    // Берем последнюю страницу для подписи
    sf.PdfPage lastPage = document.pages[document.pages.count - 1];

    // Создаем изображение подписи
    sf.PdfBitmap signatureImage = sf.PdfBitmap(signatureBytes);

    // Вставляем изображение на страницу
    lastPage.graphics.drawImage(
      signatureImage,
      Rect.fromLTWH(50, lastPage.size.height - 150, 200, 50), // x - ширина, y - высота
    );

    // Сохраняем PDF в байты
    Uint8List updatedPdfBytes = Uint8List.fromList(document.saveSync());
    document.dispose();
    return updatedPdfBytes;
  }


  /// Генерация PDF с подписью, подгружаемой с бэка
  Future<File?> generateFullPatientAgreementWithBackendSignature({
    required String fullName,
    required String address,
    required String receptionId,
    required ApiClient apiClient,
    String? doctorSignatureBase64,
  }) async {
    // Получаем подпись с бэка через ApiClient
    final patientSignatureBase64 = await apiClient.getPatientSignature(receptionId);
    // Генерируем PDF, передаем подпись
    return generateFullPatientAgreement(
      fullName: fullName,
      address: address,
      patientSignatureBase64: patientSignatureBase64,
      doctorSignatureBase64: doctorSignatureBase64,
    );
  }

}

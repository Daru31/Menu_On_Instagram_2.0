import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final filePath = '${Directory.current.path}/dinnerxlsx/202605.xlsx';
  final file = File(filePath);

  if (!file.existsSync()) {
    print('File not found: \$filePath');
    return;
  }

  print('=== Excel Analysis ===');

  try {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      print('Sheet: \$table');
      var sheet = excel.tables[table];
      if (sheet == null) continue;
      
      print('Max Rows: \${sheet.maxRows}');
      print('Max Cols: \${sheet.maxColumns}');
      
      var rows = sheet.rows;
      int maxPrint = rows.length > 20 ? 20 : rows.length;
      for (int i = 0; i < maxPrint; i++) {
        var row = rows[i];
        var rowData = row.map((cell) {
          if (cell == null || cell.value == null) return '-';
          String val = cell.value.toString().replaceAll('\\n', ' ');
          if (val.length > 15) val = val.substring(0, 15) + '...';
          return '[\$val]';
        }).toList();
        print('R\$i: \${rowData.join(' ')}');
      }
      break;
    }
  } catch (e, stack) {
    print('Error: \$e');
    print(stack);
  }
}

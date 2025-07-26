import 'package:flutter/material.dart';
import 'icon_styled.dart';

class DataTableCustom extends StatelessWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> data;
  final String? emptyMessage;
  final String? totalLabel;
  final Widget? leadingIcon;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final Color? borderColor;
  final double? columnSpacing;
  final double? horizontalMargin;
  final double? headingRowHeight;
  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;
  final TextStyle? headerTextStyle;
  final TextStyle? dataTextStyle;
  final Color? hoverColor;
  final List<BoxShadow>? boxShadow;

  const DataTableCustom({
    super.key,
    required this.headers,
    required this.data,
    this.emptyMessage,
    this.totalLabel,
    this.leadingIcon,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.borderColor,
    this.columnSpacing,
    this.horizontalMargin,
    this.headingRowHeight,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
    this.headerTextStyle,
    this.dataTextStyle,
    this.hoverColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? const Color(0xFF424242)),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildTableHeader(), _buildDataTable(context)],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: headerBackgroundColor ?? const Color(0xFF2A2A2A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              leadingIcon ?? IconStyled(icone: Icons.table_chart),
              const SizedBox(width: 12),
              Text(
                totalLabel ?? 'Total: ${data.length} itens',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (data.isEmpty)
            Text(
              emptyMessage ?? 'Nenhum item encontrado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: Theme.of(context).copyWith(
          dataTableTheme: DataTableThemeData(
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return hoverColor ?? const Color(0xFF2A2A2A);
              }
              return backgroundColor ?? const Color(0xFF1A1A1A);
            }),
            dividerThickness: 1,
            headingTextStyle:
                headerTextStyle ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
            dataTextStyle:
                dataTextStyle ??
                const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        child: DataTable(
          columnSpacing: columnSpacing ?? 32,
          horizontalMargin: horizontalMargin ?? 20,
          headingRowHeight: headingRowHeight ?? 56,
          dataRowMinHeight: dataRowMinHeight ?? 60,
          dataRowMaxHeight: dataRowMaxHeight ?? 60,
          columns: headers
              .map((header) => DataColumn(label: Text(header)))
              .toList(),
          rows: data.map((item) {
            return DataRow(
              cells: headers.map((header) {
                final value =
                    item[header.toLowerCase().replaceAll(' ', '_')] ??
                    item[header] ??
                    'N/A';

                // Se o valor é um Widget, retorna diretamente
                if (value is Widget) {
                  return DataCell(value);
                }

                // Se é uma string, cria um Text
                return DataCell(
                  Text(
                    value.toString(),
                    style: TextStyle(
                      color: value.toString() == 'N/A'
                          ? Colors.grey[500]
                          : Colors.grey[300],
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

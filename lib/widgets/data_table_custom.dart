import 'package:flutter/material.dart';
import 'icon_styled.dart';

class DataTableCustom extends StatefulWidget {
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

  // Parâmetros de paginação
  final bool enablePagination;
  final int itemsPerPage;
  final List<int>? itemsPerPageOptions;
  final String? paginationLabel;

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
    this.enablePagination = false,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions,
    this.paginationLabel,
  });

  @override
  State<DataTableCustom> createState() => _DataTableCustomState();
}

class _DataTableCustomState extends State<DataTableCustom> {
  int _currentPage = 0;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _itemsPerPage = widget.itemsPerPage;
  }

  List<Map<String, dynamic>> get _paginatedData {
    if (!widget.enablePagination) return widget.data;

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, widget.data.length);

    return widget.data.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    if (!widget.enablePagination || widget.data.isEmpty) return 1;
    return (widget.data.length / _itemsPerPage).ceil();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(0, _totalPages - 1);
    });
  }

  void _changeItemsPerPage(int newItemsPerPage) {
    setState(() {
      _itemsPerPage = newItemsPerPage;
      _currentPage = 0; // Reset para primeira página
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se não há dados, mostra o estado vazio
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFF424242),
        ),
        boxShadow:
            widget.boxShadow ??
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
        children: [
          _buildTableHeader(),
          _buildDataTable(context),
          if (widget.enablePagination) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFF424242),
        ),
        boxShadow:
            widget.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustração criativa usando ícones e formas
            Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de fundo com gradiente
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF424242).withValues(alpha: 0.3),
                        const Color(0xFF424242).withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Ícone principal
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2A2A2A),
                    border: Border.all(
                      color: const Color(0xFF424242),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.table_chart_outlined,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                ),
                // Elementos flutuantes decorativos
                Positioned(
                  top: 10,
                  right: 15,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 10,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 5,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Título principal
            Text(
              'Nenhum dado encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtítulo/descrição
            Text(
              widget.emptyMessage ??
                  'Não há informações para exibir no momento.\nTente ajustar os filtros ou adicionar novos dados.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Linha decorativa com pontos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == 2 ? 8 : 4,
                  height: index == 2 ? 8 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[600]?.withValues(
                      alpha: index == 2 ? 0.8 : 0.4,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    final itemsPerPageOptions = widget.itemsPerPageOptions ?? [5, 10, 20, 50];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.headerBackgroundColor ?? const Color(0xFF2A2A2A),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: widget.borderColor ?? const Color(0xFF424242),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Seletor de itens por página
          Row(
            children: [
              Text(
                'Itens por página:',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF424242)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _itemsPerPage,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    dropdownColor: const Color(0xFF2A2A2A),
                    icon: Icon(
                      Icons.expand_more,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                    items: itemsPerPageOptions.map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _changeItemsPerPage(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // Controles de navegação
          Row(
            children: [
              // Botão primeira página
              _buildPaginationButton(
                icon: Icons.first_page,
                tooltip: 'Primeira página',
                onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
              ),

              const SizedBox(width: 4),

              // Botão página anterior
              _buildPaginationButton(
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
                onPressed: _currentPage > 0
                    ? () => _goToPage(_currentPage - 1)
                    : null,
              ),

              const SizedBox(width: 16),

              // Indicador de página atual
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: const TextStyle(
                    color: Color(0xFF00BCD4),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Botão próxima página
              _buildPaginationButton(
                icon: Icons.chevron_right,
                tooltip: 'Próxima página',
                onPressed: _currentPage < _totalPages - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),

              const SizedBox(width: 4),

              // Botão última página
              _buildPaginationButton(
                icon: Icons.last_page,
                tooltip: 'Última página',
                onPressed: _currentPage < _totalPages - 1
                    ? () => _goToPage(_totalPages - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF1A1A1A).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFF424242)
                : const Color(0xFF424242).withValues(alpha: 0.5),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 18,
            color: isEnabled ? Colors.grey[300] : Colors.grey[600],
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.headerBackgroundColor ?? const Color(0xFF2A2A2A),
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
              widget.leadingIcon ?? IconStyled(icone: Icons.table_chart),
              const SizedBox(width: 12),
              Text(
                widget.totalLabel ?? 'Total: ${widget.data.length} itens',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (widget.data.isEmpty)
            Text(
              widget.emptyMessage ?? 'Nenhum item encontrado',
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
    final displayData = _paginatedData;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: Theme.of(context).copyWith(
          dataTableTheme: DataTableThemeData(
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return widget.hoverColor ?? const Color(0xFF2A2A2A);
              }
              return widget.backgroundColor ?? const Color(0xFF1A1A1A);
            }),
            dividerThickness: 1,
            headingTextStyle:
                widget.headerTextStyle ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
            dataTextStyle:
                widget.dataTextStyle ??
                const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        child: DataTable(
          columnSpacing: widget.columnSpacing ?? 32,
          horizontalMargin: widget.horizontalMargin ?? 20,
          headingRowHeight: widget.headingRowHeight ?? 56,
          dataRowMinHeight: widget.dataRowMinHeight ?? 60,
          dataRowMaxHeight: widget.dataRowMaxHeight ?? 60,
          columns: widget.headers
              .map((header) => DataColumn(label: Text(header)))
              .toList(),
          rows: displayData.map((item) {
            return DataRow(
              cells: widget.headers.map((header) {
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

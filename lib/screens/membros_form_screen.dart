import 'package:flutter/material.dart';
import 'package:flutter_dashboard_2/widgets/custom_dropdown_form_field.dart';
import 'package:flutter_dashboard_2/widgets/custom_text_form_field.dart';
import 'package:flutter_dashboard_2/models/membro.dart';
import 'package:flutter_dashboard_2/service/db.dart';

class MembrosFormScreen extends StatefulWidget {
  const MembrosFormScreen({super.key});

  @override
  State<MembrosFormScreen> createState() => _MembrosFormScreenState();
}

class _MembrosFormScreenState extends State<MembrosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _observacoesController;

  // Variáveis para dropdowns e data
  String _statusSelecionado = 'ativo';

  final List<String> _statusList = ['ativo', 'inativo', 'pausado'];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _observacoesController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _salvarMembro() async {
    if (_formKey.currentState!.validate()) {
      try {
        final membro = Membro(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          telefone: _telefoneController.text.trim().isEmpty
              ? null
              : _telefoneController.text.trim(),
          status: _statusSelecionado,
          observacoes: _observacoesController.text.trim().isEmpty
              ? null
              : _observacoesController.text.trim(),
        );

        final db = DB();
        await db.insertMembro(membro);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membro cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Limpar formulário
          _nomeController.clear();
          _emailController.clear();
          _telefoneController.clear();
          _observacoesController.clear();
          setState(() {
            _statusSelecionado = 'ativo';
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar membro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'ativo':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'inativo':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pausado':
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          width: 600,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.white, size: 32),
                    SizedBox(width: 16, height: 32),
                    Text(
                      'Cadastro de Irmãos',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                CustomTextFormField(
                  controller: _nomeController,
                  label: "Nome",
                  prefixIcon: Icons.person,
                  isRequired: true,
                  isUpperCase: true,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _emailController,
                        label: "E-mail",
                        prefixIcon: Icons.email_sharp,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Email inválido';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CustomTextFormField(
                        controller: _telefoneController,
                        label: "Telefone",
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                CustomDropdownFormField(
                  value: _statusSelecionado,
                  label: 'Status',
                  items: _statusList,
                  prefixIcon: Icons.info,
                  isRequired: true,
                  onChanged: (value) =>
                      setState(() => _statusSelecionado = value!),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Status atual: '),
                    SizedBox(width: 16),
                    _buildStatusChip(
                      _statusSelecionado,
                    ), // Exemplo de status, você pode alterar conforme necessário
                  ],
                ),
                CustomTextFormField(
                  controller: _observacoesController,
                  label: 'Observações',
                  prefixIcon: Icons.note,
                  maxLines: 3,
                  hintText: 'Adicione observações adicionais sobre o membro...',
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _salvarMembro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text('Salvar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/core/utils/constant/app_constants.dart';
import 'package:rick_morty/core/model/character_model.dart';
import 'package:rick_morty/core/provider/character_provider.dart';

class EditCharacterScreen extends StatefulWidget {
  final Character character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  State<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  late TextEditingController _speciesController;
  late TextEditingController _typeController;
  late TextEditingController _genderController;
  late TextEditingController _originController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character.name);
    _statusController = TextEditingController(text: widget.character.status);
    _speciesController = TextEditingController(text: widget.character.species);
    _typeController = TextEditingController(text: widget.character.type);
    _genderController = TextEditingController(text: widget.character.gender);
    _originController =
        TextEditingController(text: widget.character.originName);
    _locationController =
        TextEditingController(text: widget.character.locationName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _speciesController.dispose();
    _typeController.dispose();
    _genderController.dispose();
    _originController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Character',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernTextField(_nameController, AppConstants.labelName,
                  Icons.person_outline),
              _buildModernTextField(_statusController, AppConstants.labelStatus,
                  Icons.health_and_safety_outlined),
              _buildModernTextField(_speciesController,
                  AppConstants.labelSpecies, Icons.pets_outlined),
              _buildModernTextField(_typeController, AppConstants.labelType,
                  Icons.category_outlined),
              _buildModernTextField(_genderController, AppConstants.labelGender,
                  Icons.wc_outlined),
              _buildModernTextField(_originController, AppConstants.labelOrigin,
                  Icons.public_outlined),
              _buildModernTextField(_locationController,
                  AppConstants.labelLocation, Icons.place_outlined),
              const SizedBox(height: 16),
              Consumer<CharacterProvider>(
                builder: (context, prov, _) {
                  final current = prov.characters.firstWhere(
                    (c) => c.id == widget.character.id,
                    orElse: () => widget.character,
                  );
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save_outlined),
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: const Color(0xFF1F2937),
                            foregroundColor: Colors.white,
                          ),
                          label: const Text('Save Changes'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (current.isEdited)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restore_outlined),
                            onPressed: _resetChanges,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(color: Color(0xFFE9EDF5)),
                              foregroundColor: const Color(0xFF64748B),
                            ),
                            label: const Text('Reset to API Data'),
                          ),
                        ),
                      if (current.isEdited) const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: Color(0xFFDCE3EE)),
                            foregroundColor: const Color(0xFF475569),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9EDF5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            labelStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final editedChar = widget.character.copyWith(
        name: _nameController.text,
        status: _statusController.text,
        species: _speciesController.text,
        type: _typeController.text,
        gender: _genderController.text,
        originName: _originController.text,
        locationName: _locationController.text,
        isEdited: true,
      );

      Provider.of<CharacterProvider>(context, listen: false)
          .saveEdit(editedChar);
      Navigator.pop(context); // Return to details screen with updated data
    }
  }

  void _resetChanges() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Reset to API Data?'),
        content: const Text(
          'This will discard all local edits and restore the original character data from the API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CharacterProvider>(context, listen: false)
                  .resetEdit(widget.character.id);
              Navigator.pop(ctx);
              Navigator.pop(context); // Back to details screen
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

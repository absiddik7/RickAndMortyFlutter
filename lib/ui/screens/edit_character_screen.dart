import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/model/character_model.dart';
import '../../core/provider/character_provider.dart';
import '../../core/constant/app_constants.dart';

class EditCharacterScreen extends StatefulWidget {
  final Character character;

  const EditCharacterScreen({required this.character});

  @override
  _EditCharacterScreenState createState() => _EditCharacterScreenState();
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
    _originController = TextEditingController(text: widget.character.originName);
    _locationController = TextEditingController(text: widget.character.locationName);
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
      appBar: AppBar(
        title: Text(AppConstants.editCharacter),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, AppConstants.labelName),
              _buildTextField(_statusController, AppConstants.labelStatus),
              _buildTextField(_speciesController, AppConstants.labelSpecies),
              _buildTextField(_typeController, AppConstants.labelType),
              _buildTextField(_genderController, AppConstants.labelGender),
              _buildTextField(_originController, AppConstants.labelOrigin),
              _buildTextField(_locationController, AppConstants.labelLocation),
              SizedBox(height: AppConstants.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppConstants.cancel),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text(AppConstants.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
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
      
      Provider.of<CharacterProvider>(context, listen: false).saveEdit(editedChar);
      Navigator.pop(context);
      Navigator.pop(context); // Go back to list screen to refresh
    }
  }
}

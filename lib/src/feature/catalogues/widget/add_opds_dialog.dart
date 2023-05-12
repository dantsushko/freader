import 'package:flutter/material.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key});

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _field1Value;
  late String _field2Value;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Добавить каталог'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an url';
                  }
                  final urlRegex = RegExp(
                    r'^(?:http|https):\/\/'
                    r'(?:(?:[A-Z0-9][A-Z0-9_-]*)(?:\.[A-Z0-9][A-Z0-9_-]*)+)'
                    r'(?::\d{1,5})?'
                    r'(?:\/[^\s]*)?$',
                    caseSensitive: false,
                  );
                  if (!urlRegex.hasMatch(value)) {
                    return 'Please enter a valid url';
                  }
                  return null;
                },
                onSaved: (value) {
                  _field1Value = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _field2Value = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                DependenciesScope.dependenciesOf(context)
                    .database
                    .opdsDao
                    .addNewOpds(_field1Value, _field2Value);
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
}

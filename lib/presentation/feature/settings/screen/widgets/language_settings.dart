import 'package:domain/model/app_language.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_ui_state.dart';
import 'package:hello_flutter/presentation/common/extension/context_ext.dart';
import 'package:hello_flutter/presentation/feature/settings/settings_view_model.dart';

class LanguageSettings extends StatefulWidget {
  final SettingsViewModel viewModel;

  const LanguageSettings({required this.viewModel, super.key});

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends BaseUiState<LanguageSettings> {
  @override
  Widget build(BuildContext context) {
    return valueListenableBuilder(
      listenable: widget.viewModel.appViewModel.selectedLanguage,
      builder: (context, selectedLanguage) {
        return Card(
          child: ExpansionTile(
            title: Text(
              context.localizations.language,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            children: [
              _buildLanguageOption(
                AppLanguage.en,
                context.localizations.en,
                selectedLanguage,
              ),
              _buildLanguageOption(
                AppLanguage.ja,
                context.localizations.ja,
                selectedLanguage,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    AppLanguage language,
    String label,
    AppLanguage selectedLanguage,
  ) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      trailing: Radio<AppLanguage>(
        value: language,
        groupValue: selectedLanguage,
        onChanged: (AppLanguage? value) {
          widget.viewModel.onLanguageChanged(
            value,
          );
        },
      ),
    );
  }
}

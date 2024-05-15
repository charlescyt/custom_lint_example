import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/avoid_print.dart';

PluginBase createPlugin() => _MyCustomLint();

class _MyCustomLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return <LintRule>[
      const AvoidPrint(),
    ];
  }
}

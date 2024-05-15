
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidPrint extends DartLintRule {
  const AvoidPrint()
      : super(
          code: const LintCode(
            name: 'avoid_print',
            problemMessage: 'Avoid using print statements in production code.',
            correctionMessage: 'Consider using a logger instead.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final element = node.methodName.staticElement;
      if (element is! FunctionElement) return;
      if (element.name != 'print') return;
      if (!element.library.isDartCore) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [UseDeveloperLogFix()];
}

class UseDeveloperLogFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Use log from dart:developer instead.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final sourceRange = node.methodName.sourceRange;
        final result = builder.importLibraryElement(Uri.parse('dart:developer'));
        final prefix = result.prefix;
        final replacement = prefix != null ? '$prefix.log' : 'log';

        builder.addSimpleReplacement(sourceRange, replacement);
      });
    });
  }
}

import 'package:flutter/material.dart';
import '../errors/failures.dart';
import '../errors/error_handler.dart';

/// Widget personalizado para mostrar errores de forma consistente en toda la aplicación.
class ErrorDisplay extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final EdgeInsetsGeometry? padding;

  const ErrorDisplay({
    super.key,
    required this.failure,
    this.onRetry,
    this.showRetryButton = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRecoverable = ErrorHandler.isRecoverable(failure);

    return Padding(
      padding: padding ?? const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de error
            Icon(
              _getErrorIcon(),
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              ErrorHandler.getErrorTitle(failure),
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Mensaje de error
            Text(
              ErrorHandler.getUserFriendlyMessage(failure),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            // Botón de reintentar (solo si el error es recuperable)
            if (showRetryButton && isRecoverable && onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],

            // Información de debug en modo desarrollo
            if (_shouldShowDebugInfo()) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ExpansionTile(
                title: Text(
                  'Información de depuración',
                  style: theme.textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      'Código: ${failure.code}\n'
                      'Tipo: ${failure.runtimeType}\n'
                      'Detalles: ${failure.details}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (failure is ValidationFailure) {
      return Icons.warning_amber_rounded;
    } else if (failure is CacheFailure) {
      return Icons.storage_rounded;
    } else if (failure is ServerFailure) {
      return Icons.cloud_off_rounded;
    } else {
      return Icons.error_outline_rounded;
    }
  }

  bool _shouldShowDebugInfo() {
    // Solo mostrar en modo debug
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    return inDebugMode;
  }
}

/// Widget compacto para mostrar errores en espacios reducidos (ej: dentro de cards).
class CompactErrorDisplay extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const CompactErrorDisplay({
    super.key,
    required this.failure,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRecoverable = ErrorHandler.isRecoverable(failure);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ErrorHandler.getErrorTitle(failure),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ErrorHandler.getUserFriendlyMessage(failure),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (isRecoverable && onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: colorScheme.onErrorContainer,
              tooltip: 'Reintentar',
            ),
          ],
        ],
      ),
    );
  }
}

/// SnackBar helper para mostrar errores rápidamente.
class ErrorSnackBar {
  static void show(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecoverable = ErrorHandler.isRecoverable(failure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ErrorHandler.getErrorTitle(failure),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onError,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ErrorHandler.getUserFriendlyMessage(failure),
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: isRecoverable && onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                textColor: colorScheme.onError,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}

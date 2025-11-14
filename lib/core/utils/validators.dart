/// Validadores comunes para formularios
class Validators {
  Validators._(); // Constructor privado

  /// Valida un email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  /// Validator para TextFormField - Email
  static String? Function(String?) emailValidator({
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'El correo es requerido';
      }
      if (!isValidEmail(value)) {
        return errorMessage ?? 'Ingresa un correo válido';
      }
      return null;
    };
  }

  /// Valida una contraseña (mínimo 4 caracteres por defecto)
  static bool isValidPassword(String password, {int minLength = 4}) {
    return password.length >= minLength;
  }

  /// Validator para TextFormField - Password
  static String? Function(String?) passwordValidator({
    int minLength = 4,
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'La contraseña es requerida';
      }
      if (!isValidPassword(value, minLength: minLength)) {
        return errorMessage ?? 'La contraseña debe tener al menos $minLength caracteres';
      }
      return null;
    };
  }

  /// Validator para TextFormField - Requerido
  static String? Function(String?) requiredValidator({
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return errorMessage ?? 'Este campo es requerido';
      }
      return null;
    };
  }

  /// Validator para TextFormField - Teléfono
  static String? Function(String?) phoneValidator({
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'El teléfono es requerido';
      }
      if (value.length < 10) {
        return errorMessage ?? 'Ingresa un teléfono válido (mínimo 10 dígitos)';
      }
      return null;
    };
  }

  /// Validator para TextFormField - Mínima longitud
  static String? Function(String?) minLengthValidator(
    int minLength, {
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo es requerido';
      }
      if (value.length < minLength) {
        return errorMessage ?? 'Debe tener al menos $minLength caracteres';
      }
      return null;
    };
  }

  /// Validator para TextFormField - Máxima longitud
  static String? Function(String?) maxLengthValidator(
    int maxLength, {
    String? errorMessage,
  }) {
    return (value) {
      if (value != null && value.length > maxLength) {
        return errorMessage ?? 'No debe exceder $maxLength caracteres';
      }
      return null;
    };
  }

  /// Validator para TextFormField - Solo números
  static String? Function(String?) numericValidator({
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo es requerido';
      }
      if (int.tryParse(value) == null) {
        return errorMessage ?? 'Solo se permiten números';
      }
      return null;
    };
  }

  /// Validator para TextFormField - Rango numérico
  static String? Function(String?) rangeValidator({
    required double min,
    required double max,
    String? errorMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo es requerido';
      }
      final number = double.tryParse(value);
      if (number == null) {
        return 'Ingresa un número válido';
      }
      if (number < min || number > max) {
        return errorMessage ?? 'Debe estar entre $min y $max';
      }
      return null;
    };
  }

  /// Combinar múltiples validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

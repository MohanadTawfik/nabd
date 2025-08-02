/// Utility class for form validation
class Validators {
  /// Validate required field
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  /// Validate amount
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'المبلغ مطلوب';
    }
    
    final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleanedValue);
    
    if (amount == null) {
      return 'يرجى إدخال مبلغ صحيح';
    }
    
    if (amount <= 0) {
      return 'يجب أن يكون المبلغ أكبر من صفر';
    }
    
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    final phoneRegex = RegExp(r'^[0-9]{9,10}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    
    return null;
  }

  /// Validate name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    
    return null;
  }
}
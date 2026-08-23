enum SmsTransactionClassification {
  debit,
  credit,
  unknown,
  promotional,
}

class TransactionSmsClassifier {
  const TransactionSmsClassifier();

  SmsTransactionClassification classify(
    String sms,
  ) {
    final text = _normalize(sms);

    if (text.isEmpty) {
      return SmsTransactionClassification.unknown;
    }

    // ------------------------------------------------------------
    // Promotional / marketing SMS
    // ------------------------------------------------------------

    if (_isPromotional(text)) {
      return SmsTransactionClassification.promotional;
    }

    // ------------------------------------------------------------
    // Strong debit patterns
    // ------------------------------------------------------------

    if (_isDebit(text)) {
      return SmsTransactionClassification.debit;
    }

    // ------------------------------------------------------------
    // Strong credit patterns
    // ------------------------------------------------------------

    if (_isCredit(text)) {
      return SmsTransactionClassification.credit;
    }

    return SmsTransactionClassification.unknown;
  }

  bool _isDebit(String text) {
    final patterns = <RegExp>[
      // "Sent Rs.60.00 from A/c..."
      RegExp(
        r'\bsent\s+rs\.?\s*[\d,]+(?:\.\d+)?\s+from\b',
        caseSensitive: false,
      ),

      // "debited with Rs..."
      RegExp(
        r'\bdebited\b.*\brs\.?\s*[\d,]+',
        caseSensitive: false,
      ),

      // "debited Rs..."
      RegExp(
        r'\bdebit(?:ed)?\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "deducted Rs..."
      RegExp(
        r'\bdeduct(?:ed)?\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "withdrawn Rs..."
      RegExp(
        r'\bwithdraw(?:n|al)?\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "spent Rs..."
      RegExp(
        r'\bspent\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "paid Rs..."
      RegExp(
        r'\bpaid\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // UPI/payment made
      RegExp(
        r'\b(?:upi|payment)\b.*?(?:paid|sent|debited)',
        caseSensitive: false,
      ),
    ];

    return patterns.any(
      (pattern) => pattern.hasMatch(text),
    );
  }

  bool _isCredit(String text) {
    final patterns = <RegExp>[
      // "A/c ... is credited with Rs..."
      RegExp(
        r'\b(?:a/c|account|ac)\b.*'
        r'\bcredited\b.*'
        r'(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "credited with Rs..."
      RegExp(
        r'\bcredited\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "credited Rs..."
      RegExp(
        r'\bcredited\b\s*(?:with\s*)?'
        r'(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "received Rs..."
      RegExp(
        r'\breceived\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "deposit Rs..."
      RegExp(
        r'\bdeposit(?:ed)?\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "refund Rs..."
      RegExp(
        r'\brefund(?:ed)?\b.*?(?:rs\.?|inr|₹)\s*[\d,]+',
        caseSensitive: false,
      ),

      // "cashback credited"
      RegExp(
        r'\bcashback\b.*\bcredit(?:ed)?\b',
        caseSensitive: false,
      ),
    ];

    return patterns.any(
      (pattern) => pattern.hasMatch(text),
    );
  }

  bool _isPromotional(String text) {
    final hasUrl = RegExp(
      r'(https?://|www\.|bit\.ly/)',
      caseSensitive: false,
    ).hasMatch(text);

    final promotionalWords = [
      'offer',
      'offers',
      'discount',
      'savings',
      'save',
      'coupon',
      'sale',
      'shop now',
      'buy now',
      'limited time',
      'flat off',
      'get off',
      'promotion',
      'promotional',
      'terms and conditions',
      't&c',
      'click here',
      'visit us',
    ];

    final matches = promotionalWords
        .where(text.contains)
        .length;

    // URL + even one promotional indicator
    if (hasUrl && matches >= 1) {
      return true;
    }

    // Multiple promotional indicators
    if (matches >= 2) {
      return true;
    }

    return false;
  }

  String _normalize(String value) {
    return value
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim()
        .toLowerCase();
  }
}
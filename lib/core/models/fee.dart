class FeeInvoice {
  final int id;
  final String name;
  final int studentId;
  final String studentName;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double amountTotal;
  final double amountPaid;
  final double amountDue;
  final String state; // 'draft', 'open', 'paid', 'partial', 'cancelled'
  final bool isOverdue;
  final String? currency;

  FeeInvoice({
    required this.id,
    required this.name,
    required this.studentId,
    required this.studentName,
    required this.invoiceDate,
    this.dueDate,
    required this.amountTotal,
    required this.amountPaid,
    required this.amountDue,
    required this.state,
    this.isOverdue = false,
    this.currency,
  });

  factory FeeInvoice.fromJson(Map<String, dynamic> json) {
    return FeeInvoice(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      studentId: json['student_id'] != null ? (json['student_id'] as List)[0] as int : 0,
      studentName: json['student_id'] != null ? (json['student_id'] as List)[1] as String : '',
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      amountTotal: (json['amount_total'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0.0,
      state: json['state'] as String? ?? 'draft',
      isOverdue: json['is_overdue'] as bool? ?? false,
      currency: json['currency_id'] != null ? (json['currency_id'] as List)[1] as String? : null,
    );
  }
}

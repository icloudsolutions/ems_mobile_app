import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/message.dart';
import '../../../core/providers/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Message> _allMessages = [];
  List<Message> _receivedMessages = [];
  List<Message> _sentMessages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final userId = user?.id ?? 1;

    _allMessages = [
      Message(
        id: 1,
        subject: 'Progress Update',
        body: 'Your child is showing excellent progress in Mathematics this term. Keep encouraging the practice!',
        senderId: 101,
        senderName: 'Mr. Ahmed Ali (Math Teacher)',
        senderType: 'teacher',
        recipientId: userId,
        recipientName: user?.name ?? 'Parent',
        recipientType: 'parent',
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
        isRead: false,
        studentId: 201,
      ),
      Message(
        id: 2,
        subject: 'Attendance Concern',
        body: 'I noticed your child has been absent for the last 3 days. Please let us know if everything is okay.',
        senderId: 102,
        senderName: 'Ms. Fatima (Class Teacher)',
        senderType: 'teacher',
        recipientId: userId,
        recipientName: user?.name ?? 'Parent',
        recipientType: 'parent',
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
        studentId: 201,
      ),
      Message(
        id: 3,
        subject: 'Science Fair Participation',
        body: 'We are organizing a science fair next month. Would you like your child to participate?',
        senderId: 103,
        senderName: 'Dr. Sarah (Science Teacher)',
        senderType: 'teacher',
        recipientId: userId,
        recipientName: user?.name ?? 'Parent',
        recipientType: 'parent',
        createdDate: DateTime.now().subtract(const Duration(days: 7)),
        isRead: true,
        studentId: 201,
      ),
      Message(
        id: 4,
        subject: 'Regarding Assignment',
        body: 'Thank you for the update. My child will submit the assignment by tomorrow.',
        senderId: userId,
        senderName: user?.name ?? 'Parent',
        senderType: 'parent',
        recipientId: 101,
        recipientName: 'Mr. Ahmed Ali',
        recipientType: 'teacher',
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        studentId: 201,
      ),
    ];

    _receivedMessages = _allMessages
        .where((m) => m.recipientId == userId)
        .toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));

    _sentMessages = _allMessages
        .where((m) => m.senderId == userId)
        .toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _receivedMessages.where((m) => !m.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Received'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Sent'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMessages,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMessageList(_receivedMessages, isReceived: true),
                  _buildMessageList(_sentMessages, isReceived: false),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _composeMessage,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages, {required bool isReceived}) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageCard(
          message: message,
          isReceived: isReceived,
          onTap: () => _viewMessage(message),
        );
      },
    );
  }

  void _viewMessage(Message message) {
    if (!message.isRead && message.recipientId == context.read<AuthProvider>().user?.id) {
      setState(() {
        final index = _allMessages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _allMessages[index] = Message(
            id: message.id,
            subject: message.subject,
            body: message.body,
            senderId: message.senderId,
            senderName: message.senderName,
            senderType: message.senderType,
            recipientId: message.recipientId,
            recipientName: message.recipientName,
            recipientType: message.recipientType,
            createdDate: message.createdDate,
            isRead: true,
            studentId: message.studentId,
          );
        }
        _loadMessages();
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.subject,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.reply),
                    onPressed: () {
                      Navigator.pop(context);
                      _replyToMessage(message);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MessageDetailRow(
                label: 'From',
                value: message.senderName,
              ),
              _MessageDetailRow(
                label: 'To',
                value: message.recipientName,
              ),
              _MessageDetailRow(
                label: 'Date',
                value: DateFormat('MMM dd, yyyy HH:mm').format(message.createdDate),
              ),
              const Divider(height: 32),
              Text(
                message.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _replyToMessage(message);
                  },
                  icon: const Icon(Icons.reply),
                  label: const Text('Reply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _composeMessage() {
    showDialog(
      context: context,
      builder: (context) => const _ComposeMessageDialog(),
    ).then((result) {
      if (result == true) {
        _loadMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      }
    });
  }

  void _replyToMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => _ComposeMessageDialog(
        replyTo: message,
      ),
    ).then((result) {
      if (result == true) {
        _loadMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply sent successfully')),
        );
      }
    });
  }
}

class _MessageCard extends StatelessWidget {
  final Message message;
  final bool isReceived;
  final VoidCallback onTap;

  const _MessageCard({
    required this.message,
    required this.isReceived,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: !message.isRead && isReceived ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  isReceived ? Icons.person : Icons.send,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.subject,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: !message.isRead && isReceived
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!message.isRead && isReceived)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isReceived ? message.senderName : message.recipientName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(message.createdDate),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _MessageDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposeMessageDialog extends StatefulWidget {
  final Message? replyTo;

  const _ComposeMessageDialog({this.replyTo});

  @override
  State<_ComposeMessageDialog> createState() => _ComposeMessageDialogState();
}

class _ComposeMessageDialogState extends State<_ComposeMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _bodyController;
  String? _selectedRecipient;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: widget.replyTo != null ? 'Re: ${widget.replyTo!.subject}' : '',
    );
    _bodyController = TextEditingController();
    if (widget.replyTo != null) {
      _selectedRecipient = widget.replyTo!.senderName;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.replyTo == null ? 'Compose Message' : 'Reply'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.replyTo == null)
                DropdownButtonFormField<String>(
                  value: _selectedRecipient,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Mr. Ahmed Ali (Math Teacher)',
                    'Ms. Fatima (Class Teacher)',
                    'Dr. Sarah (Science Teacher)',
                    'Mr. Hassan (Arabic Teacher)',
                  ].map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRecipient = value);
                  },
                  validator: (value) =>
                      value == null ? 'Please select a recipient' : null,
                ),
              if (widget.replyTo == null) const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Subject is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Message is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

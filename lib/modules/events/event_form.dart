import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';

class EventForm extends StatefulWidget {
  final Event? event;
  final Function(Event) onSubmit;

  const EventForm({
    super.key,
    this.event,
    required this.onSubmit,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  EventStatus _status = EventStatus.upcoming;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _date = widget.event!.date;
      _time = TimeOfDay.fromDateTime(widget.event!.date);
      _status = widget.event!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create an event')),
        );
        return;
      }

      final event = Event(
        id: widget.event?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        date: DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
        organizerId: currentUser.id,
        organizer: currentUser.name,
        organizerAvatar: currentUser.avatar,
        confirmedAttendeeIds: widget.event?.confirmedAttendeeIds ?? [],
        interestedAttendeeIds: widget.event?.interestedAttendeeIds ?? [],
        status: _status,
        latitude: widget.event?.latitude ?? 0.0,
        longitude: widget.event?.longitude ?? 0.0,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSubmit(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(Icons.access_time),
                  label: Text(_time.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EventStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: EventStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _status = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.event == null ? 'Create Event' : 'Update Event'),
          ),
        ],
      ),
    );
  }
}

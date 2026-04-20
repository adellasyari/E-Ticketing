import 'package:flutter/material.dart';
import 'detail_ticket_page.dart';
import '../../data/models/ticket_model.dart';

class ListTicketPage extends StatelessWidget {
  const ListTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(6, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tiket')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final id = items[index];
          final ticket = TicketModel(
            id: id,
            userId: 'user_dummy',
            title: 'Tiket #00$id - Judul Dummy',
            description: 'Deskripsi untuk tiket $id',
            status: 'Diproses',
          );

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailTicketPage(ticket: ticket),
                    ),
                  );
                },
                title: Text(
                  ticket.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('12 April 2026'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Diproses',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

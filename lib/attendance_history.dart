import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

class AttendanceHistoryPage extends StatelessWidget {
  final List<String> history;

  AttendanceHistoryPage({required this.history});

  void _shareLink(BuildContext context, String? link) {
    if (link != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      Share.share(link,
          subject: 'Attendance Link',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _openLink(String? link) async {
    if (link != null && await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch the link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: history.isNotEmpty
            ? ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];

                  final linkPattern = RegExp(r'Link: (.+)$');
                  final linkMatch = linkPattern.firstMatch(entry);
                  final link = linkMatch != null ? linkMatch.group(1) : null;

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(entry),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'copy') {
                            Clipboard.setData(ClipboardData(text: link ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Link copied to clipboard!'),
                            ));
                          } else if (value == 'open') {
                            _openLink(link);
                          } else if (value == 'share') {
                            _shareLink(context, link);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'copy',
                              child: Text('Copy Link'),
                            ),
                            PopupMenuItem(
                              value: 'open',
                              child: Text('Open in Browser'),
                            ),
                            PopupMenuItem(
                              value: 'share',
                              child: Text('Share Link'),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'No attendance history available.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'AIzaSyBDBnJoWdbB5TSKcTarVoWKKu0dHKeUe2E';
  String? pageToken;
  
  do {
    final urlStr = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey' + (pageToken != null ? '&pageToken=$pageToken' : '');
    final request = await HttpClient().getUrl(Uri.parse(urlStr));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body);
    
    for (var m in data['models'] ?? []) {
      final methods = m['supportedGenerationMethods'] as List?;
      if (methods != null && methods.contains('generateContent')) {
        print(m['name']);
      }
    }
    pageToken = data['nextPageToken'];
  } while (pageToken != null && pageToken.isNotEmpty);
  exit(0);
}

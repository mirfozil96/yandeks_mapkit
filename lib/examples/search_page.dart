import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'widgets/map_page.dart';

class SearchPage extends MapPage {
  const SearchPage({Key? key}) : super('search example', key: key);

  @override
  Widget build(BuildContext context) {
    return _MyHomePage();
  }
}

class _MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<_MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  SuggestionResponse? _suggestions;
  bool _isLoading = false;
  String? _error;

  String _lang = 'en';
  int _results = 5;
  final List<String> _languageOptions = ['en', 'ru', 'uz'];

  void _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = null;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final suggestions = await _apiService.fetchSuggestions(
        query,
        lang: _lang,
        results: _results,
      );
      setState(() {
        _suggestions = suggestions.results.isEmpty ? null : suggestions;
        _isLoading = false;
        _error = suggestions.results.isEmpty ? "No such place" : null;
      });
    } catch (e) {
      setState(() {
        _suggestions = null;
        _isLoading = false;
        _error = "Failed to load suggestions";
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yandex Map Suggestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter location',
                border: OutlineInputBorder(),
              ),
              onChanged: _getSuggestions,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                    value: _lang,
                    onChanged: (newValue) {
                      setState(() {
                        _lang = newValue!;
                      });
                      // Reload suggestions
                      _getSuggestions(_controller.text);
                    },
                    items: _languageOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Results limit',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _results = int.tryParse(value) ?? 5;
                      });
                      // Reload suggestions
                      _getSuggestions(_controller.text);
                    },
                  ),
                ),
              ],
            ),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading && _error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            Expanded(
              child: _suggestions == null
                  ? Center(
                      child: Text(
                        _error ?? 'Enter a location to search',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _suggestions!.results.length,
                      itemBuilder: (context, index) {
                        final result = _suggestions!.results[index];
                        return ListTile(
                          title: Text(result.title.text),
                          subtitle: Text(result.subtitle.text),
                          trailing: Text(result.distance.text),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiService {
  static const String apiKey = '4e06663f-bff9-4ffb-a9e6-c175b3717574';
  static const String baseUrl = 'https://suggest-maps.yandex.ru/v1/suggest';

  Future<SuggestionResponse> fetchSuggestions(
    String query, {
    String lang = 'en',
    int results = 5,
  }) async {
    final Map<String, String> params = {
      'apikey': apiKey,
      'text': query,
      'lang': lang,
      'results': results.toString(),
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SuggestionResponse.fromJson(data);
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}

class Suggestion {
  final String text;
  final List<Highlight>? hl;

  Suggestion({required this.text, this.hl});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    var hlList = json['hl'] != null
        ? List<Highlight>.from(json['hl'].map((x) => Highlight.fromJson(x)))
        : null;
    return Suggestion(
      text: json['text'],
      hl: hlList,
    );
  }
}

class Highlight {
  final int begin;
  final int end;

  Highlight({required this.begin, required this.end});

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      begin: json['begin'],
      end: json['end'],
    );
  }
}

class Distance {
  final double value;
  final String text;

  Distance({required this.value, required this.text});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      value: json['value'],
      text: json['text'],
    );
  }
}

class Result {
  final Suggestion title;
  final Suggestion subtitle;
  final List<String> tags;
  final Distance distance;

  Result({
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.distance,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      title: Suggestion.fromJson(json['title']),
      subtitle: Suggestion.fromJson(json['subtitle']),
      tags: List<String>.from(json['tags']),
      distance: Distance.fromJson(json['distance']),
    );
  }
}

class SuggestionResponse {
  final String suggestReqId;
  final List<Result> results;

  SuggestionResponse({
    required this.suggestReqId,
    required this.results,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionResponse(
      suggestReqId: json['suggest_reqid'],
      results:
          List<Result>.from(json['results'].map((x) => Result.fromJson(x))),
    );
  }
}

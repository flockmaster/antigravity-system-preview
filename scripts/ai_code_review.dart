import 'dart:io';
import 'dart:convert';

/// AI Code Review Script
/// 
/// Usage: 
///   export AI_API_KEY="your_key_here"
///   dart scripts/ai_code_review.dart
///
/// Workflow:
/// 1. Detects changes (git diff).
/// 2. Reads project formatting rules (optional).
/// 3. Sends diff to AI provider (e.g., OpenAI/Gemini/DeepSeek).
/// 4. Outputs suggestions.

const String _kApiModel = 'gpt-4o'; // Or 'gemini-pro', 'deepseek-chat'
const String _kApiUrl = 'https://api.openai.com/v1/chat/completions'; // Adjust based on provider

void main() async {
  // 1. Get Security Key & Config
  final String? apiKey = Platform.environment['AI_API_KEY'];
  final String apiUrl = Platform.environment['AI_API_URL'] ?? 'https://api.openai.com/v1/chat/completions';
  final String apiModel = Platform.environment['AI_MODEL'] ?? 'gpt-4o';

  if (apiKey == null || apiKey.isEmpty) {
    print('⚠️  Error: AI_API_KEY environment variable not set.');
    print('Please set it via: export AI_API_KEY="sk-..."');
    exit(1);
  }

  print('🔍 Starting AI Code Review (Model: $apiModel)...');

  // 2. Get Git Diff
  // Checks staged changes by default, or HEAD~1 if nothing staged
  ProcessResult diffProcess = await Process.run('git', ['diff', '--cached', '--unified=0']);
  String diffContent = diffProcess.stdout.toString();

  if (diffContent.trim().isEmpty) {
    print('ℹ️  No staged changes found. Checking last commit...');
    diffProcess = await Process.run('git', ['diff', 'HEAD~1', 'HEAD', '--unified=0']);
    diffContent = diffProcess.stdout.toString();
  }

  if (diffContent.trim().isEmpty) {
    print('✅ No code changes detected to review.');
    exit(0);
  }

  // Limit diff size to avoid token limits (rudimentary check)
  if (diffContent.length > 100000) {
    print('⚠️  Diff is too large (${diffContent.length} chars). Truncating...');
    diffContent = diffContent.substring(0, 100000) + '\n...[Truncated]';
  }

  print('📦 Analyzing ${diffContent.length} characters of code changes...');

  // 3. Prepare AI Prompt
  final prompt = _buildPrompt(diffContent);

    // 4. Call AI API
    final suggestions = await _callAiApi(apiKey, apiUrl, apiModel, prompt);
    
    print('\n================ LOGIC & STYLE REVIEW ================');
    print(suggestions);
    print('======================================================\n');
    
    if (suggestions.contains("CRITICAL_ISSUE")) {
      print('❌ AI detected critical issues.');
      exit(1);
    } else {
      print('✅ AI Review passed.');
    }

  } catch (e) {
    print('❌ API Call Failed: $e');
    exit(1);
  }
}

String _buildPrompt(String diff) {
  return '''
You are a Senior Flutter/Dart Engineer and Code Reviewer.
Your goal is to ensure code quality, safety, and adherence to Flutter best practices.

Review the following git diff:
```diff
$diff
```

**Instructions:**
1. Focus on bugs, potential crashes, performance issues, and major architectural violations.
2. Ignore minor formatting nitpicks unless they violate standard Dart style severely.
3. If you see chinese comments, maintain them.
4. If you find a security risk, flag it as [CRITICAL_ISSUE].
5. Provide actionable improvements with code snippets.
6. Be concise and professional.
''';
}

Future<String> _callAiApi(String token, String url, String model, String content) async {
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(url));
  
  request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
  request.headers.set(HttpHeaders.authorizationHeader, "Bearer $token");
  
  // Note: Adjust body structure for non-OpenAI APIs (e.g. Gemini, Anthropic)
  final body = jsonEncode({
    "model": model,
    "messages": [
      {"role": "system", "content": "You are a helpful code reviewer."},
      {"role": "user", "content": content}
    ],
    "temperature": 0.2
  });

  request.write(body);
  final response = await request.close();
  
  final responseBody = await response.transform(utf8.decoder).join();
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}: $responseBody');
  }

  final json = jsonDecode(responseBody);
  return json['choices'][0]['message']['content'];
}

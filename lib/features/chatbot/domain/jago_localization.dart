// ============================================================
// USMA — JAGO Scholarship Assistance System
// jago_localization.dart
//
// Structured Multilingual Localization (English, Hindi, Odia)
// Voice-Ready Response Formatter
// ============================================================

class JagoLocalization {
  static const String langEnglish = 'en';
  static const String langHindi = 'hi';
  static const String langOdia = 'or';

  static const Map<String, Map<String, String>> _strings = {
    langEnglish: {
      'app_title': 'JAGO MoTA Assistant',
      'subtitle': 'Context-Aware Scholarship Advisor',
      'disclaimer': 'DEMO MODE: Answers utilize configured USMA student data and statutory MoTA guidelines.',
      'quick_actions': 'Quick Inquiries',
      'check_eligibility': 'Check Eligibility',
      'track_application': 'Track Application',
      'check_documents': 'Check Documents',
      'track_payment': 'Track Payment',
      'view_schemes': 'View Schemes',
      'raise_grievance': 'Raise Grievance',
      'view_app': 'View Application',
      'contact_inst': 'Contact Institute',
      'doc_vault': 'Check Documents',
      'view_source': 'Official Source',
      'voice_hint': 'Tap mic to dictate question',
      'input_hint': 'Ask JAGO about schemes, tracking, documents, or DBT...',
      'no_info_fallback': 'I do not have verified official information for this question. Please refer to the official Ministry of Tribal Affairs portal (tribal.nic.in) or call the toll-free helpline at 0120-6619540.',
      'draft_grievance_created': 'A draft grievance has been formulated. Real government grievance submission is not simulated to prevent duplicate filing.',
      'draft_summary': 'Draft Grievance Summary',
      'category': 'Category',
      'scheme': 'Scheme',
      'description': 'Description',
      'submit_disabled': 'Government Grievance API connection pending approval.',
    },
    langHindi: {
      'app_title': 'जागो (JAGO) जनजातीय कार्य मंत्रालय',
      'subtitle': 'छात्रवृत्ति संदर्भ-सचेत सहायक',
      'disclaimer': 'डेमो मोड: उत्तर आपके पंजीकृत डेटा और आधिकारिक MoTA दिशानिर्देशों पर आधारित हैं।',
      'quick_actions': 'त्वरित पूछताछ',
      'check_eligibility': 'पात्रता जांचें',
      'track_application': 'आवेदन ट्रैक करें',
      'check_documents': 'दस्तावेज़ जांचें',
      'track_payment': 'भुगतान ट्रैक करें',
      'view_schemes': 'योजनाएं देखें',
      'raise_grievance': 'शिकायत दर्ज करें',
      'view_app': 'आवेदन देखें',
      'contact_inst': 'संस्थान से संपर्क करें',
      'doc_vault': 'दस्तावेज़ वॉल्ट',
      'view_source': 'आधिकारिक स्रोत',
      'voice_hint': 'बोलने के लिए माइक दबाएं',
      'input_hint': 'योजनाओं, आवेदन स्थिति, दस्तावेजों या डीबीटी के बारे में पूछें...',
      'no_info_fallback': 'मेरे पास इस प्रश्न के लिए कोई सत्यापित सरकारी जानकारी नहीं है। कृपया जनजातीय कार्य मंत्रालय के आधिकारिक पोर्टल (tribal.nic.in) पर जाएं या हेल्पलाइन 0120-6619540 पर संपर्क करें।',
      'draft_grievance_created': 'शिकायत का प्रारूप तैयार किया गया है। फर्जी या डुप्लिकेट फाइलिंग से बचने के लिए वास्तविक शिकायत सबमिशन API कनेक्शन के बाद ही संभव है।',
      'draft_summary': 'शिकायत प्रारूप विवरण',
      'category': 'श्रेणी',
      'scheme': 'योजना',
      'description': 'विवरण',
      'submit_disabled': 'सरकारी शिकायत API एकीकरण प्रतीक्षारत है।',
    },
    langOdia: {
      'app_title': 'ଜାଗୋ (JAGO) ଆଦିବାସୀ ବ୍ୟାପାର ମନ୍ତ୍ରଣାଳୟ',
      'subtitle': 'ଛାତ୍ରବୃତ୍ତି ସହାୟତା ବ୍ୟବସ୍ଥା',
      'disclaimer': 'ଡେମୋ ମୋଡ୍: ଉତ୍ତରଗୁଡ଼ିକ ଆପଣଙ୍କ ପଞ୍ଜୀକୃତ ତଥ୍ୟ ଏବଂ ସରକାରୀ ନିର୍ଦ୍ଦେଶାବଳୀ ଉପରେ ଆଧାରିତ।',
      'quick_actions': 'ଦ୍ରୁତ ଅନୁସନ୍ଧାନ',
      'check_eligibility': 'ଯୋଗ୍ୟତା ଯାଞ୍ଚ କରନ୍ତୁ',
      'track_application': 'ଆବେଦନ ଟ୍ରାକ୍ କରନ୍ତୁ',
      'check_documents': 'ଦଲିଲ ଯାଞ୍ଚ କରନ୍ତୁ',
      'track_payment': 'ଦେୟ ଟ୍ରାକ୍ କରନ୍ତୁ',
      'view_schemes': 'ଯୋଜନା ଦେଖନ୍ତୁ',
      'raise_grievance': 'ଅଭିଯୋଗ ଦାଖଲ କରନ୍ତୁ',
      'view_app': 'ଆବେଦନ ଦେଖନ୍ତୁ',
      'contact_inst': 'ଅନୁଷ୍ଠାନ ସହିତ ଯୋଗାଯୋଗ କରନ୍ତୁ',
      'doc_vault': 'ଦଲିଲ ଯାଞ୍ଚ',
      'view_source': 'ସରକାରୀ ଉତ୍ସ',
      'voice_hint': 'କହିବା ପାଇଁ ମାଇକ୍ ଦବାନ୍ତୁ',
      'input_hint': 'ଛାତ୍ରବୃତ୍ତି, ସ୍ଥିତି, ଦଲିଲ କିମ୍ବା DBT ବିଷୟରେ ପଚାରନ୍ତୁ...',
      'no_info_fallback': 'ଏହି ପ୍ରଶ୍ନ ପାଇଁ ମୋ ପାଖରେ ପ୍ରମାଣିତ ସରକାରୀ ସୂଚନା ନାହିଁ। ଦୟାକରି ଆଦିବାସୀ ବ୍ୟାପାର ମନ୍ତ୍ରଣାଳୟ ପୋର୍ଟାଲ୍ (tribal.nic.in) ଯାଞ୍ଚ କରନ୍ତୁ।',
      'draft_grievance_created': 'ଏକ ଡ୍ରାଫ୍ଟ ଅଭିଯୋଗ ପ୍ରସ୍ତୁତ କରାଯାଇଛି। ସରକାରୀ API ସଂଯୋଗ ବିନା ଏହା ଦାଖଲ ହୋଇପାରିବ ନାହିଁ।',
      'draft_summary': 'ଡ୍ରାଫ୍ଟ ଅଭିଯୋଗ ସାରାଂଶ',
      'category': 'ବର୍ଗ',
      'scheme': 'ଯୋଜନା',
      'description': 'ବିବରଣୀ',
      'submit_disabled': 'ସରକାରୀ ଅଭିଯୋଗ API ଅନୁମୋଦନ ଅପେକ୍ଷାରେ ଅଛି।',
    },
  };

  static String get(String key, {String lang = langEnglish}) {
    final langMap = _strings[lang] ?? _strings[langEnglish]!;
    return langMap[key] ?? _strings[langEnglish]?[key] ?? key;
  }

  /// Voice-ready synthesis text (clean plaintext without markdown symbols)
  static String toVoiceSpeechText(String formattedText) {
    return formattedText
        .replaceAll(RegExp(r'[•\*\#\_\~]'), '')
        .replaceAll('📋 Reason:', 'Reason.')
        .replaceAll('⚡ Current Status:', 'Current Status.')
        .replaceAll('👉 Required Action:', 'Action required.')
        .replaceAll('🏛️ Source:', 'Source.')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

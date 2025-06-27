import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:html/parser.dart' as parser;

class ExchangeRateService extends GetxController {
  static ExchangeRateService get to => Get.find();

  late final dio.Dio _dio;
  final _rates = <String, Map<String, double>>{}.obs;
  final _isLoading = false.obs;
  final _lastUpdate = DateTime.now().obs;
  final _error = ''.obs;
  final _isOnline = true.obs;

  Timer? _updateTimer;

  // Getters
  Map<String, Map<String, double>> get rates => _rates;
  bool get isLoading => _isLoading.value;
  DateTime get lastUpdate => _lastUpdate.value;
  String get error => _error.value;
  bool get isOnline => _isOnline.value;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _loadInitialRates();
    _startPeriodicUpdate();
  }

  void _initializeDio() {
    _dio = dio.Dio();

    // إعداد Dio مع إعدادات محسنة
    _dio.options = dio.BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'ar,en-US;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Cache-Control': 'no-cache',
      },
    );

    // إضافة Interceptors للتسجيل والتعامل مع الأخطاء
    _dio.interceptors.add(
      dio.LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (log) => print('🌐 Exchange Rate API: $log'),
      ),
    );

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          print('📤 Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Dio Error: ${error.message}');
          _handleDioError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleDioError(dio.DioException error) {
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
        _error.value = 'انتهت مهلة الاتصال';
        break;
      case dio.DioExceptionType.receiveTimeout:
        _error.value = 'انتهت مهلة استقبال البيانات';
        break;
      case dio.DioExceptionType.connectionError:
        _error.value = 'خطأ في الاتصال بالإنترنت';
        _isOnline.value = false;
        break;
      case dio.DioExceptionType.badResponse:
        _error.value = 'خطأ في استجابة الخادم (${error.response?.statusCode})';
        break;
      default:
        _error.value = 'خطأ غير متوقع في الاتصال';
    }
  }

  void _loadInitialRates() {
    // تحميل أسعار افتراضية في البداية
    _rates.value = _getFallbackRates();
    // محاولة جلب الأسعار الحقيقية
    fetchRates();
  }

  void _startPeriodicUpdate() {
    // تحديث كل 30 دقيقة
    _updateTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => fetchRates(),
    );
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    _dio.close();
    super.onClose();
  }

  Future<void> fetchRates() async {
    if (_isLoading.value) return; // تجنب الطلبات المتعددة

    try {
      _isLoading.value = true;
      _error.value = '';
      _isOnline.value = true;
      update(); // تحديث الواجهة

      print('🔄 بدء جلب أسعار الصرف...');

      // محاولة جلب البيانات من بنك فلسطين
      final bankRates = await _fetchFromBankOfPalestine();

      if (bankRates.isNotEmpty && _validateRates(bankRates)) {
        _rates.value = bankRates;
        _lastUpdate.value = DateTime.now();
        print('✅ تم جلب أسعار الصرف بنجاح من بنك فلسطين');
        update(); // تحديث الواجهة
        return;
      }

      // محاولة جلب من مصدر بديل
      final alternativeRates = await _fetchFromAlternativeSource();
      if (alternativeRates.isNotEmpty && _validateRates(alternativeRates)) {
        _rates.value = alternativeRates;
        _lastUpdate.value = DateTime.now();
        _error.value = 'تم الجلب من مصدر بديل';
        print('⚠️ تم جلب أسعار الصرف من مصدر بديل');
        update(); // تحديث الواجهة
        return;
      }

      // استخدام أسعار افتراضية
      _rates.value = _getFallbackRates();
      _error.value = 'تم استخدام أسعار تقريبية';
      print('🔄 تم استخدام أسعار افتراضية');
      update(); // تحديث الواجهة
    } catch (e) {
      _error.value = 'خطأ في جلب الأسعار';
      _rates.value = _getFallbackRates();
      print('💥 Error fetching exchange rates: $e');
      update(); // تحديث الواجهة
    } finally {
      _isLoading.value = false;
      update(); // تحديث الواجهة
    }
  }

  Future<Map<String, Map<String, double>>> _fetchFromBankOfPalestine() async {
    try {
      print('🏦 محاولة جلب الأسعار من بنك فلسطين...');

      // روابط محتملة لصفحات أسعار الصرف
      final possibleUrls = [
        'https://www.bankofpalestine.com/ar/exchange-rates',
        'https://www.bankofpalestine.com/exchange-rates',
        'https://www.bankofpalestine.com/ar/currency-rates',
        'https://www.bankofpalestine.com/currency-rates',
      ];

      for (final url in possibleUrls) {
        try {
          print('🔗 محاولة الرابط: $url');

          final response = await _dio.get(
            url,
            options: dio.Options(
              followRedirects: true,
              maxRedirects: 5,
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            final rates = _parseHtmlRates(response.data.toString(), url);
            if (rates.isNotEmpty) {
              print('✅ تم العثور على البيانات في: $url');
              return rates;
            }
          }
        } catch (e) {
          print('❌ فشل في الرابط: $url - $e');
          continue;
        }
      }

      print('❌ لم يتم العثور على بيانات في أي رابط');
      return {};
    } catch (e) {
      print('💥 خطأ عام في جلب بيانات بنك فلسطين: $e');
      return {};
    }
  }

  Future<Map<String, Map<String, double>>> _fetchFromAlternativeSource() async {
    try {
      print('🔄 محاولة جلب الأسعار من مصدر بديل...');

      // استخدام API مجاني كبديل
      const url = 'https://api.exchangerate-api.com/v4/latest/ILS';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['rates'] != null) {
          final rates = data['rates'] as Map<String, dynamic>;

          // تحويل الأسعار لتناسب السوق المحلي في غزة
          final usdRate = rates['USD'] ?? 0.0;
          final jodRate = rates['JOD'] ?? 0.0;

          if (usdRate > 0 && jodRate > 0) {
            return {
              'USD': {
                'buy': (1 / usdRate * 0.98), // سعر الشراء أقل قليلاً
                'sell': (1 / usdRate * 1.02), // سعر البيع أعلى قليلاً
              },
              'JOD': {
                'buy': (1 / jodRate * 0.98),
                'sell': (1 / jodRate * 1.02),
              },
            };
          }
        }
      }

      return {};
    } catch (e) {
      print('💥 خطأ في المصدر البديل: $e');
      return {};
    }
  }

  Map<String, Map<String, double>> _parseHtmlRates(
      String html, String sourceUrl) {
    final document = parser.parse(html);
    final rates = <String, Map<String, double>>{};

    try {
      print('🔍 تحليل HTML من: $sourceUrl');

      // البحث عن جدول أسعار الصرف بطرق متعددة
      final possibleTableSelectors = [
        '.exchange-rates-table',
        '#exchange-rates',
        '.currency-table',
        '.rates-table',
        'table[class*="exchange"]',
        'table[class*="currency"]',
        'table[class*="rate"]',
        '.exchange-rates',
        '.currency-rates',
        'table',
      ];

      dynamic exchangeTable;
      for (final selector in possibleTableSelectors) {
        exchangeTable = document.querySelector(selector);
        if (exchangeTable != null) {
          print('📊 تم العثور على جدول باستخدام: $selector');
          break;
        }
      }

      if (exchangeTable != null) {
        final rows = exchangeTable.querySelectorAll('tr');
        print('📊 تم العثور على ${rows.length} صفوف في جدول الأسعار');

        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];
          final cells = row.querySelectorAll('td, th');

          if (cells.length >= 3) {
            final currency = cells[0].text.trim().toUpperCase();
            final buyText = cells[1].text.trim();
            final sellText = cells[2].text.trim();

            print('🔍 صف $i: $currency - شراء: $buyText, بيع: $sellText');

            if (_isUSDCurrency(currency)) {
              final buyPrice = _parsePrice(buyText);
              final sellPrice = _parsePrice(sellText);

              if (buyPrice > 0 && sellPrice > 0) {
                rates['USD'] = {'buy': buyPrice, 'sell': sellPrice};
                print('💵 USD - شراء: $buyPrice, بيع: $sellPrice');
              }
            } else if (_isJODCurrency(currency)) {
              final buyPrice = _parsePrice(buyText);
              final sellPrice = _parsePrice(sellText);

              if (buyPrice > 0 && sellPrice > 0) {
                rates['JOD'] = {'buy': buyPrice, 'sell': sellPrice};
                print('💰 JOD - شراء: $buyPrice, بيع: $sellPrice');
              }
            }
          }
        }
      }

      // إذا لم نجد البيانات في الجدول، نبحث بمحددات مختلفة
      if (rates.isEmpty) {
        print('🔍 البحث عن الأسعار بمحددات مختلفة...');

        final usdBuy = _findPriceByMultipleSelectors(document, [
          '#usd-buy',
          '.usd-buy',
          '[data-currency="USD"] .buy',
          '.currency-usd .buy',
          '.usd .buy-rate',
          '.usd-buy-rate',
          '[class*="usd"][class*="buy"]',
          '[id*="usd"][id*="buy"]'
        ]);

        final usdSell = _findPriceByMultipleSelectors(document, [
          '#usd-sell',
          '.usd-sell',
          '[data-currency="USD"] .sell',
          '.currency-usd .sell',
          '.usd .sell-rate',
          '.usd-sell-rate',
          '[class*="usd"][class*="sell"]',
          '[id*="usd"][id*="sell"]'
        ]);

        final jodBuy = _findPriceByMultipleSelectors(document, [
          '#jod-buy',
          '.jod-buy',
          '[data-currency="JOD"] .buy',
          '.currency-jod .buy',
          '.jod .buy-rate',
          '.jod-buy-rate',
          '[class*="jod"][class*="buy"]',
          '[id*="jod"][id*="buy"]'
        ]);

        final jodSell = _findPriceByMultipleSelectors(document, [
          '#jod-sell',
          '.jod-sell',
          '[data-currency="JOD"] .sell',
          '.currency-jod .sell',
          '.jod .sell-rate',
          '.jod-sell-rate',
          '[class*="jod"][class*="sell"]',
          '[id*="jod"][id*="sell"]'
        ]);

        if (usdBuy > 0 && usdSell > 0) {
          rates['USD'] = {'buy': usdBuy, 'sell': usdSell};
          print('💵 USD (محددات) - شراء: $usdBuy, بيع: $usdSell');
        }

        if (jodBuy > 0 && jodSell > 0) {
          rates['JOD'] = {'buy': jodBuy, 'sell': jodSell};
          print('💰 JOD (محددات) - شراء: $jodBuy, بيع: $jodSell');
        }
      }

      return rates;
    } catch (e) {
      print('💥 خطأ في تحليل HTML: $e');
      return {};
    }
  }

  bool _isUSDCurrency(String currency) {
    final usdKeywords = ['USD', 'دولار', 'DOLLAR', 'US DOLLAR', 'دولار أمريكي'];
    return usdKeywords.any((keyword) => currency.contains(keyword));
  }

  bool _isJODCurrency(String currency) {
    final jodKeywords = [
      'JOD',
      'دينار',
      'DINAR',
      'JORDANIAN DINAR',
      'دينار أردني'
    ];
    return jodKeywords.any((keyword) => currency.contains(keyword));
  }

  double _findPriceByMultipleSelectors(document, List<String> selectors) {
    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        final price = _parsePrice(element.text);
        if (price > 0) {
          print('✅ تم العثور على السعر باستخدام: $selector = $price');
          return price;
        }
      }
    }
    return 0.0;
  }

  double _parsePrice(String priceText) {
    if (priceText.isEmpty) return 0.0;

    // تنظيف النص وتحويل الأرقام العربية للإنجليزية
    String cleanText = priceText
        .replaceAll(RegExp(r'[^\d.,٠-٩]'), '')
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9')
        .replaceAll(',', '.');

    if (cleanText.isEmpty) return 0.0;

    final price = double.tryParse(cleanText) ?? 0.0;

    // التحقق من معقولية السعر (بين 0.1 و 100)
    if (price > 0.1 && price < 100) {
      return double.parse(price.toStringAsFixed(2));
    }

    return 0.0;
  }

  bool _validateRates(Map<String, Map<String, double>> rates) {
    if (rates.isEmpty) return false;

    // التحقق من وجود USD و JOD
    if (!rates.containsKey('USD') || !rates.containsKey('JOD')) {
      return false;
    }

    // التحقق من صحة الأسعار
    for (final currency in rates.keys) {
      final currencyRates = rates[currency]!;
      if (!currencyRates.containsKey('buy') ||
          !currencyRates.containsKey('sell')) {
        return false;
      }

      final buy = currencyRates['buy']!;
      final sell = currencyRates['sell']!;

      if (buy <= 0 || sell <= 0 || buy >= sell) {
        return false;
      }
    }

    return true;
  }

  Map<String, Map<String, double>> _getFallbackRates() {
    // أسعار افتراضية تقريبية لغزة
    return {
      'USD': {
        'buy': 3.65,
        'sell': 3.70,
      },
      'JOD': {
        'buy': 5.15,
        'sell': 5.25,
      },
    };
  }

  // دالة لإعادة المحاولة يدوياً
  Future<void> retry() async {
    print('🔄 إعادة محاولة جلب الأسعار...');
    await fetchRates();
  }

  // دالة للحصول على سعر محدد
  double getRate(String currency, String type) {
    return _rates[currency.toUpperCase()]?[type.toLowerCase()] ?? 0.0;
  }

  // دالة للتحقق من صحة البيانات
  bool get hasValidData {
    return _rates.isNotEmpty &&
        _rates['USD'] != null &&
        _rates['JOD'] != null &&
        getRate('USD', 'buy') > 0 &&
        getRate('USD', 'sell') > 0 &&
        getRate('JOD', 'buy') > 0 &&
        getRate('JOD', 'sell') > 0;
  }

  // دالة لتنسيق وقت آخر تحديث
  String get formattedLastUpdate {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate.value);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}

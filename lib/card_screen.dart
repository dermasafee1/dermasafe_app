import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_screen.dart';

class CardScreen extends StatefulWidget {
  final String token;
  CardScreen({required this.token});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.getCard(widget.token);
      if (res['status'] == 'success' && res['user'] != null) {
        setState(() {
          _data = res;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res['message'] ?? 'Помилка завантаження даних';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Помилка з\'єднання: $e';
        _isLoading = false;
      });
    }
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() { _isFront = !_isFront; });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не вдалося відкрити посилання')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF42947b)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Спробувати ще раз'),
              )
            ],
          ),
        ),
      );
    }

    if (_data == null || _data!['user'] == null) {
      return const Center(child: Text('Дані не знайдено'));
    }

    final user = _data!['user'];
    final cert = _data!['certificate'];

    String roleText = (user['role'] ?? 'user').toString().toLowerCase();
    if (roleText == 'guest_artist') roleText = 'GUEST ARTIST';
    else if (roleText == 'master_pm') roleText = 'PERMANENT ARTIST';
    else if (roleText == 'master') roleText = 'TATTOO ARTIST';
    else if (roleText == 'studio') roleText = 'TATTOO STUDIO';
    else if (roleText == 'cosmetology') roleText = 'COSMETOLOGIST';
    else if (roleText == 'admin') roleText = 'ADMINISTRATOR';
    else roleText = roleText.toUpperCase();

    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 0.85; 

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: availableHeight, 
              ),
              child: AspectRatio(
                aspectRatio: 3 / 5, 
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final angle = _controller.value * pi;
                      final isBack = angle > pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildBackCard(user, cert),
                              )
                            : _buildFrontCard(user, roleText),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF42947b), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('api_token');
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                },
                child: const Text('ВИЙТИ', style: TextStyle(color: Color(0xFF42947b), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= ЛИЦЕВА СТОРОНА =================
  Widget _buildFrontCard(Map<String, dynamic> user, String roleText) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ОСОБИСТИЙ КАБІНЕТ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2b2b2b))),
                Image.network(
                  'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icon-orange.png', 
                  width: 36, height: 36,
                  errorBuilder: (c, e, s) => const Icon(Icons.security, color: Colors.orange, size: 36),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user['role'] != 'studio' && user['role'] != 'cosmetology')
                    _buildDataRow('СТАТУС', 'АКТИВНИЙ'),
                  _buildDataRow('ТЕЛЕФОН', user['phone'] ?? ''),
                  _buildDataRow('ТИП', roleText),
                  _buildDataRow('МІСТО', (user['city'] ?? 'НЕ ВКАЗАНО').toString().toUpperCase()),
                  if (user['country'] != null && user['country'].toString().isNotEmpty) 
                    _buildDataRow('КРАЇНА', user['country'].toString().toUpperCase()),
                  if ((user['role'] == 'studio' || user['role'] == 'cosmetology') && user['studio_name'] != null && user['studio_name'].toString().isNotEmpty) 
                    _buildDataRow(user['role'] == 'cosmetology' ? 'НАЗВА ЗАКЛАДУ' : 'НАЗВА СТУДІЇ', '"${user['studio_name'].toString().toUpperCase()}"'),
                ],
              ),
            ),
          ),

          // Бігуча стрічка (ВИСОТА ЗБІЛЬШЕНА ДО 30)
          Container(
            width: double.infinity,
            height: 30,
            color: const Color(0xFF42947b),
            child: const CustomMarquee(
              text: '✥ GLOBAL TRUST INFRASTRUCTURE ✥ PROFESSIONAL HEALTH STANDARDS ✥ TATTOO ARTISTS ✥ PERMANENT MAKEUP ✥ TATTOO STUDIOS ✥ COSMETOLOGY ✥ GUEST ARTISTS ✥ ESTHETIC COMPETENCY ✥ UKRAINE ✥ EUROPE ✥ WORLDWIDE ✥ ',
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(roleText, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      Text((user['full_name'] ?? 'КОРИСТУВАЧ').toString().toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2b2b2b))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _flipCard,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.only(left: 15, bottom: 5, top: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) => Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF42947b), shape: BoxShape.circle),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= ЗВОРОТНЯ СТОРОНА =================
  Widget _buildBackCard(Map<String, dynamic> user, Map<String, dynamic>? cert) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          
          if (cert != null)
            RepaintBoundary(
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(cert['qr_url'] ?? 'https://dermasafe.com.ua')}',
                width: 230, height: 230,
                errorBuilder: (c, e, s) => const Icon(Icons.qr_code, size: 230, color: Colors.grey),
              ),
            )
          else
            const Icon(Icons.qr_code, size: 230, color: Colors.grey),

          const SizedBox(height: 15),

          if (cert != null && cert['pdf_url'] != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42947b),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _launchUrl(cert['pdf_url']),
              child: const Text('ЗАВАНТАЖИТИ VERIFICAT', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ),

          const SizedBox(height: 15),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Text('ПОШИРИТИ В МЕРЕЖІ', style: TextStyle(fontSize: 14, color: Color(0xFF666666), letterSpacing: 1)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _shareIcon('https://www.facebook.com/sharer/sharer.php?u=https://dermasafe.com.ua/registry.php', 'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icons-facebook.png'),
                    _shareIcon('https://www.linkedin.com/sharing/share-offsite/?url=https://dermasafe.com.ua/registry.php', 'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icons-in.png'),
                    _shareIcon('https://www.threads.net/intent/post?text=https://dermasafe.com.ua/registry.php', 'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icons-threads.png'),
                    _shareIcon('https://t.me/share/url?url=https://dermasafe.com.ua/registry.php', 'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icons-telegram-app.png'),
                    _shareIcon('https://twitter.com/intent/tweet?url=https://dermasafe.com.ua/registry.php', 'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icons-twitter-bird.png'),
                    _shareIcon('https://wa.me/?text=https://dermasafe.com.ua/registry.php', 'https://images.weserv.nl/?url=dermasafe.com.ua/assets/img/icons-whatsapp.png'),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          Text(
            cert != null ? 'ДІЙСНИЙ ДО ${cert['expiry_date']}' : 'НЕМАЄ АКТИВНОГО СЕРТИФІКАТА',
            style: TextStyle(color: cert != null ? const Color(0xFF42947b) : Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _flipCard,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.only(right: 20, bottom: 20, left: 15, top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) => Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF42947b), shape: BoxShape.circle),
                  )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, color: Color(0xFF333333), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF0F0F0), height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _shareIcon(String url, String iconUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Image.network(iconUrl, width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.share, color: Colors.grey, size: 30)),
      ),
    );
  }
}

// ================= КАСТОМНА БІГУЧА СТРІЧКА =================
class CustomMarquee extends StatefulWidget {
  final String text;
  const CustomMarquee({Key? key, required this.text}) : super(key: key);

  @override
  _CustomMarqueeState createState() => _CustomMarqueeState();
}

class _CustomMarqueeState extends State<CustomMarquee> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: MarqueePainter(
              text: widget.text,
              offset: _controller.value,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arial',
              ),
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class MarqueePainter extends CustomPainter {
  final String text;
  final double offset;
  final TextStyle textStyle;

  MarqueePainter({required this.text, required this.offset, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    // ВИПРАВЛЕНО: Примусово встановлюємо height: 1.0, щоб прибрати невидимі відступи шрифту
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle.copyWith(height: 1.0)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final textWidth = textPainter.width;
    final xOffset = -(offset * textWidth);
    
    // Тепер textPainter.height ідеально відповідає візуальній висоті тексту
    final yOffset = (size.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(xOffset, yOffset));
    textPainter.paint(canvas, Offset(xOffset + textWidth, yOffset));
    textPainter.paint(canvas, Offset(xOffset + textWidth * 2, yOffset));
  }

  @override
  bool shouldRepaint(covariant MarqueePainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
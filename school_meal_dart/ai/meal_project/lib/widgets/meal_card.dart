import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final bool isLunch;
  final String dateString;
  final String menu;

  const MealCard({
    Key? key,
    required this.isLunch,
    required this.dateString,
    required this.menu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 테마 설정
    final titleText = isLunch ? '오늘의 중식' : '오늘의 석식';
    final boxTitle = isLunch ? '☀️ 중식' : '🌙 석식';
    final accentColor = isLunch ? const Color(0xFFFFD166) : const Color(0xFF118AB2);
    
    // 배경 그라데이션 (중식: 밝은 하늘, 석식: 어두운 밤하늘)
    final backgroundGradient = isLunch
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)], // 밝고 화사한 톤
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // 깊고 어두운 밤하늘 톤
          );

    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
      ),
      child: Stack(
        children: [
          // 배경 장식 (원형 패턴)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isLunch ? 0.2 : 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isLunch ? 0.2 : 0.05),
              ),
            ),
          ),
          
          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더
                Center(
                  child: Text(
                    titleText,
                    style: const TextStyle(
                      fontFamily: 'Malgun Gothic',
                      fontSize: 85, // 글자 크기 증가
                      fontWeight: FontWeight.w900, // 더 두껍게
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(4, 4),
                          blurRadius: 15,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isLunch ? 0.3 : 0.15),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      dateString,
                      style: const TextStyle(
                        fontSize: 45, // 글자 크기 증가
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),

                // 메뉴 카드 (이제 하나만 차지하므로 Expanded 로 크게)
                Expanded(
                  child: _buildMenuBox(boxTitle, menu, accentColor, isLunch),
                ),
                
                const SizedBox(height: 60),
                
                // 푸터
                Center(
                  child: Text(
                    '울산고등학교 학생회 창의기술부',
                    style: TextStyle(
                      fontSize: 38, // 글자 크기 증가
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isLunch) {
    if (isLunch) {
      return Stack(
        children: [
          Positioned(top: 80, left: -60, child: Icon(Icons.cloud, size: 280, color: Colors.white.withOpacity(0.35))),
          Positioned(top: 250, right: -80, child: Icon(Icons.cloud, size: 350, color: Colors.white.withOpacity(0.25))),
          Positioned(bottom: 250, left: 40, child: Icon(Icons.cloud, size: 220, color: Colors.white.withOpacity(0.2))),
          Positioned(bottom: -50, right: -40, child: Icon(Icons.cloud, size: 320, color: Colors.white.withOpacity(0.3))),
          // 햇살 느낌의 원형
          Positioned(top: -50, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.yellow.withOpacity(0.15)))),
        ],
      );
    } else {
      return Stack(
        children: [
          // 달
          Positioned(top: 100, right: 80, child: Icon(Icons.nightlight_round, size: 180, color: Colors.yellow.withOpacity(0.8))),
          // 별들
          Positioned(top: 150, left: 120, child: Icon(Icons.star, size: 40, color: Colors.yellowAccent.withOpacity(0.8))),
          Positioned(top: 300, right: 250, child: Icon(Icons.star_border, size: 50, color: Colors.white.withOpacity(0.4))),
          Positioned(top: 80, left: 300, child: Icon(Icons.star, size: 25, color: Colors.white.withOpacity(0.6))),
          Positioned(bottom: 400, left: 100, child: Icon(Icons.star, size: 35, color: Colors.yellowAccent.withOpacity(0.6))),
          Positioned(bottom: 200, right: 120, child: Icon(Icons.star_border, size: 45, color: Colors.white.withOpacity(0.3))),
          Positioned(bottom: 120, left: 300, child: Icon(Icons.star, size: 20, color: Colors.white.withOpacity(0.7))),
        ],
      );
    }
  }

  Widget _buildMenuBox(String title, String menuText, Color accentColor, bool isLunch) {
    return Container(
      decoration: BoxDecoration(
        color: isLunch ? Colors.white : const Color(0xFF1E293B), // 석식일 때는 메뉴 카드 배경도 약간 어둡게 (가독성을 위해 네이비)
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLunch ? 0.15 : 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      padding: const EdgeInsets.all(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 25),
              Text(
                title,
                style: TextStyle(
                  fontSize: 55, // 글자 크기 증가
                  fontWeight: FontWeight.w900,
                  color: isLunch ? const Color(0xFF333333) : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center( // 텍스트를 카드 중앙에 배치
              child: SingleChildScrollView(
                child: Text(
                  menuText,
                  style: TextStyle(
                    fontSize: 50, // 글자 크기 대폭 증가
                    height: 1.8,
                    color: isLunch ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.bold, // 글자 두껍게
                  ),
                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

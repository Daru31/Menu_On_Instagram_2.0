import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String dateString;
  final String lunchMenu;
  final String dinnerMenu;

  const MealCard({
    Key? key,
    required this.dateString,
    required this.lunchMenu,
    required this.dinnerMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8EC5FC),
            Color(0xFFE0C3FC),
          ],
        ),
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
                color: Colors.white.withOpacity(0.2),
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
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          
          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 150.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더
                Center(
                  child: Text(
                    '오늘의 급식',
                    style: TextStyle(
                      fontFamily: 'Malgun Gothic', // 시스템 기본 폰트 사용
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(4, 4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      dateString,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),

                // 중식 카드
                _buildMenuBox('☀️ 중식', lunchMenu, Color(0xFFFFD166)),
                
                SizedBox(height: 60),

                // 석식 카드
                _buildMenuBox('🌙 석식', dinnerMenu, Color(0xFF118AB2)),
                
                Spacer(),
                
                // 푸터
                Center(
                  child: Text(
                    '울산고등학교 학생회 봉사부',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
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

  Widget _buildMenuBox(String title, String menu, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      padding: EdgeInsets.all(50),
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
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Text(
            menu,
            style: TextStyle(
              fontSize: 45,
              height: 1.6,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

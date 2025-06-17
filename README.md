# 월남뽕 (Vietnam Bbong) - Flutter Card Game

전통 한국 카드 게임 월남뽕을 Flutter로 구현한 앱입니다.

## 🎴 카드 디자인

### 현재 구현
- **숫자 기반 카드**: 1-10 숫자가 크고 선명하게 표시
- **화투 스타일 색상**: 각 숫자별로 다른 색상 적용
- **가독성 최적화**: 
  - 흰색 테두리와 그림자 효과
  - 높은 대비의 진한 색상
  - 큰 폰트 크기 (중앙 숫자 60% 카드 크기)

### 화투패 실제 이미지 사용 방법

실제 화투패 이미지를 사용하려면:

1. **이미지 준비**
   ```
   assets/images/cards/
   ├── 1_0.png, 1_1.png, 1_2.png, 1_3.png  (1월 - 송학)
   ├── 2_0.png, 2_1.png                     (2월 - 매조)
   ├── 3_0.png, 3_1.png                     (3월 - 벚꽃)
   ├── 4_0.png, 4_1.png                     (4월 - 흑싸리)
   ├── 5_0.png, 5_1.png                     (5월 - 창포)
   ├── 6_0.png, 6_1.png                     (6월 - 목단)
   ├── 7_0.png, 7_1.png                     (7월 - 홍단)
   ├── 8_0.png, 8_1.png                     (8월 - 공산)
   ├── 9_0.png, 9_1.png                     (9월 - 국화)
   └── 10_0.png, 10_1.png, 10_2.png, 10_3.png (10월 - 단풍)
   ```

2. **CardWidget 수정**
   ```dart
   // _buildCardFront() 메서드에서
   return Container(
     decoration: BoxDecoration(
       image: DecorationImage(
         image: AssetImage('assets/images/cards/${widget.card!.value}_${widget.card!.id.split('_')[1]}.png'),
         fit: BoxFit.cover,
       ),
     ),
   );
   ```

3. **pubspec.yaml 업데이트**
   ```yaml
   flutter:
     assets:
       - assets/images/cards/
   ```

### 화투패 vs 숫자 카드 장단점

| 구분 | 화투패 이미지 | 숫자 카드 |
|------|---------------|-----------|
| **장점** | 전통적이고 아름다운 디자인<br/>실제 화투 느낌 | 명확하고 직관적<br/>빠른 인식 가능<br/>파일 크기 작음 |
| **단점** | 이미지 파일 필요<br/>앱 크기 증가<br/>로딩 시간 | 시각적 매력 상대적으로 부족 |

## 🎮 게임 기능

- ✅ 24장 카드 덱 (1,10: 4장씩, 2-9: 2장씩)
- ✅ AI 대전 모드
- ✅ 승/패/묻기/죽기 판정
- ✅ 반응형 UI (웹/모바일)
- ✅ 카드 뒤집기 애니메이션

## 🚀 실행 방법

```bash
flutter pub get
flutter run
```

웹에서 실행:
```bash
flutter run -d chrome
```

## 📱 지원 플랫폼

- Android
- iOS
- Web
- Windows
- macOS
- Linux

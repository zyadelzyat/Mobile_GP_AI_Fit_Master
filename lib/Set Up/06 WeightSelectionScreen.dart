import 'package:flutter/material.dart';
import '07 GoalSelectionScreen.dart';
import '05 HeightSelectionScreen.dart';

class WeightSelectionScreen extends StatefulWidget {
  final String gender;

  const WeightSelectionScreen({super.key, required this.gender});

  @override
  _WeightSelectionScreenState createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool isKg = true;
  double selectedWeight = 58;
  double minWeight = 50;
  double maxWeight = 300;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // إضافة مراقب لحركة التمرير
    _scrollController.addListener(_scrollListener);
  }

  void _updateScrollPosition(double weight) {
    // حساب الموضع الدقيق للإزاحة مع 10 بكسل لكل رقم
    double offset = (weight - minWeight) * 30;

    // تأكد من عدم تجاوز الحدود الدنيا أو القصوى للإزاحة
    offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  void _scrollListener() {
    double currentOffset = _scrollController.offset;

    // حساب الوزن بناءً على الإزاحة الحالية
    double weight = (minWeight + currentOffset / 30).roundToDouble();

    // منع تجاوز الحدود
    weight = weight.clamp(minWeight, maxWeight);

    // تحديث الوزن إذا كان مختلفًا
    if (weight != selectedWeight) {
      setState(() {
        selectedWeight = weight;
      });
    }
  }
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener); // إزالة المراقب عند التخلص من الويجيت
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF232323),
        appBar: AppBar(
          backgroundColor: const Color(0xFF232323),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.yellow),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HeightSelectionScreen()), // الصفحة التي تريد الانتقال إليها
                    (Route<dynamic> route) => false, // إزالة جميع الصفحات السابقة
              );
            },
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "What Is Your Weight?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Select your weight from the options below.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                ToggleButtons(
                  isSelected: [isKg, !isKg],
                  onPressed: (index) {
                    setState(() {
                      isKg = index == 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  fillColor: const Color(0xFFE2F163),
                  selectedColor: Colors.black,
                  color: Colors.white,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "KG",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "LB",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // المسطرة مع الأرقام فوقها والخطوط القصيرة بينها
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3A0FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: (maxWeight - minWeight).toInt() + 1,
                        itemBuilder: (context, index) {
                          final weight = minWeight + index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedWeight = weight; // تحديد الوزن المختار
                                _updateScrollPosition(weight); // تحديث الموضع
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // الرقم
                                  Text(
                                    weight.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: selectedWeight == weight ? 24 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: selectedWeight == weight
                                          ? Colors.yellow // اللون عند التحديد
                                          : Colors.white54,
                                    ),
                                  ),
                                  // الخط القصير بين الأرقام
                                  if (index != (maxWeight - minWeight).toInt())
                                    Container(
                                      height: 20,
                                      width: 2,
                                      color: Colors.white54,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // السهم في المنتصف مع حجمه الأصغر
                    const Positioned(
                      top: -10, // وضع السهم في أعلى المسطرة
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.yellow,
                        size: 40, // تقليل حجم السهم ليكون أصغر
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // عرض الوزن المحدد
                Text(
                  "${selectedWeight.toStringAsFixed(0)} ${isKg ? "Kg" : "Lb"}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // يمكنك إضافة منطق هنا مثل الانتقال إلى شاشة أخرى
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
        ),
       );
   }
}
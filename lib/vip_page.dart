import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// 内购产品常量
const String kWeekVipProductId = 'HiiyoWeekVIP';
const String kMonthVipProductId = 'HiiyoMonthVIP';
const String kWeekVipPrice = '\$12.99';
const String kMonthVipPrice = '\$49.99';

class VipPage extends StatefulWidget {
  const VipPage({Key? key}) : super(key: key);

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  int _selectedIndex = 0;
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _loading = true;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _loadVipStatus();
    _iap.purchaseStream
        .listen(_listenToPurchaseUpdated, onDone: () {}, onError: (error) {});
  }

  Future<void> _initializeIAP() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }
    const Set<String> _kIds = {kWeekVipProductId};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_kIds);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  Future<void> _loadVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVip = prefs.getBool('is_vip') ?? false;
    });
  }

  void _buyProduct() async {
    final String productId =
        _selectedIndex == 0 ? kWeekVipProductId : kMonthVipProductId;
    try {
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      String message =
          'The in-app purchase product is currently unavailable. Please try again later.';
      if (e is PlatformException && e.code == 'storekit2_purchase_cancelled') {
        message = 'Purchase has been cancelled by the user.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_vip', true);
        // 写入VIP到期时间
        int days = 7; // 默认周卡
        if (purchaseDetails.productID == kMonthVipProductId) {
          days = 30;
        }
        final expire =
            DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch;
        await prefs.setInt('vip_expire_time', expire);
        setState(() {
          _isVip = true;
        });
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  void _restorePurchases() async {
    try {
      await _iap.restorePurchases();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notice'),
          content: const Text(
              'Restore request sent. If you have a valid subscription, your VIP status will be restored.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Failed'),
          content: Text('Failed to restore purchases: \\${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final imageHeight = width * 0.7;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // 顶部大图
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/vip_top_2025_5_28.png',
              width: width,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
          ),
          // 返回按钮
          Positioned(
            top: 32,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // VIP标识
          if (_isVip)
            Positioned(
              top: 40,
              right: 24,
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  const Text('VIP',
                      style: TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          // 底部深色圆角View
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenHeight + 20 - imageHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF242C34),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 内购选择框
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (context) {
                              final double cardWidth =
                                  (MediaQuery.of(context).size.width -
                                          40 -
                                          20) /
                                      2.0;
                              return Row(
                                children: [
                                  _VipProductCard(
                                    price: kWeekVipPrice,
                                    period: 'Per week',
                                    selected: _selectedIndex == 0,
                                    width: cardWidth,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 0),
                                  ),
                                  const SizedBox(width: 20),
                                  _VipProductCard(
                                    price: kMonthVipPrice,
                                    period: 'Per month',
                                    selected: _selectedIndex == 1,
                                    width: cardWidth,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 1),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Exclusive VIP Privileges',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232834),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VipPrivilegeItem(
                              icon:
                                  'assets/images/vip_function_1_2025_5_28.png',
                              title:
                                  'Unlimited avatar, nickname, and signature edits',
                              subtitle:
                                  'VIPs can edit their avatar, nickname, and signature without limits',
                            ),
                            const SizedBox(height: 24),
                            _VipPrivilegeItem(
                              icon:
                                  'assets/images/vip_function_2_2025_5_28.png',
                              title: 'No advertisements',
                              subtitle: 'VIPs will never see any ads',
                            ),
                            const SizedBox(height: 24),
                            _VipPrivilegeItem(
                              icon:
                                  'assets/images/vip_function_3_2025_5_28.png',
                              title: 'Unlimited Discover content',
                              subtitle:
                                  'VIPs can view all shared content without limits',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _restorePurchases,
                          child: const Text(
                            'Restore',
                            style: TextStyle(
                              color: Color(0xFF2CB9FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 悬浮Confirm按钮
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CB9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
                onPressed: _loading ? null : _buyProduct,
                child: const Text(
                  'confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 内购产品卡片组件
class _VipProductCard extends StatelessWidget {
  final String price;
  final String period;
  final bool selected;
  final double width;
  final VoidCallback onTap;
  const _VipProductCard(
      {required this.price,
      required this.period,
      required this.selected,
      required this.width,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF22304A) : const Color(0xFF232834),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF4C8FFF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              price,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              period,
              style: const TextStyle(
                color: Color(0xFFB0B8C7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 权益条目组件
class _VipPrivilegeItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const _VipPrivilegeItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, width: 36, height: 36),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFC8C8C8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

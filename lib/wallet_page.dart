import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// 充值项常量
class GoldProduct {
  final String productId;
  final int coins;
  final String priceText; // 预设价格文本
  GoldProduct(
      {required this.productId, required this.coins, required this.priceText});
}

final List<GoldProduct> kGoldProducts = [
  GoldProduct(productId: 'Hiiyo2', coins: 96, priceText: '\$2.99'),
  GoldProduct(productId: 'Hiiyo5', coins: 189, priceText: '\$5.99'),
  GoldProduct(productId: 'Hiiyo9', coins: 359, priceText: '\$9.99'),
  GoldProduct(productId: 'Hiiyo19', coins: 729, priceText: '\$19.99'),
  GoldProduct(productId: 'Hiiyo49', coins: 1869, priceText: '\$49.99'),
  GoldProduct(productId: 'Hiiyo99', coins: 3799, priceText: '\$99.99'),
  GoldProduct(productId: 'Hiiyo159', coins: 5999, priceText: '\$159.99'),
  GoldProduct(productId: 'Hiiyo239', coins: 9059, priceText: '\$239.99'),
];

const String kGoldBalanceKey = 'gold_coins_balance';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _balance = 0;
  bool _loading = true;
  List<ProductDetails> _products = [];
  final InAppPurchase _iap = InAppPurchase.instance;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _initializeIAP();
    _iap.purchaseStream
        .listen(_listenToPurchaseUpdated, onDone: () {}, onError: (e) {});
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getInt(kGoldBalanceKey) ?? 0;
    });
  }

  Future<void> _saveBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kGoldBalanceKey, value);
    setState(() {
      _balance = value;
    });
  }

  Future<void> _initializeIAP() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }
    final Set<String> ids = kGoldProducts.map((e) => e.productId).toSet();
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _buyProduct(GoldProduct goldProduct) async {
    try {
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == goldProduct.productId,
        orElse: () =>
            throw Exception('Product not found: \\${goldProduct.productId}'),
      );
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
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
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        final matched = kGoldProducts.firstWhere(
          (e) => e.productId == purchaseDetails.productID,
          orElse: () => throw Exception(
              'Product not found: \\${purchaseDetails.productID}'),
        );
        if (matched != null) {
          final newBalance = _balance + matched.coins;
          await _saveBalance(newBalance);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  void _showCoinInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Gold coins'),
        content: const Text(
          '• Each comment costs 8 coins.\n\n• Coins are non-refundable.\n\n• Coins cannot be exchanged for any goods or services.',
          style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final imageHeight = width * 0.7;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          // 顶部大图
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/wallet_2025_5_29.png',
              width: width,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
          ),
          // 顶部导航栏（返回+标题+info，标题绝对居中）
          Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 居中标题
                  const Center(
                    child: Text(
                      'Daily Gold coins',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // 左侧返回按钮
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Color(0xFF333333)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  // 右侧info按钮
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline,
                          color: Color(0xFF2CB9FF)),
                      onPressed: _showCoinInfo,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 余额区块（在大图内居中）
          Positioned(
            top: imageHeight * 0.32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '$_balance',
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'My Gold coins',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // 下方白色圆角卡片（仅充值选项）
          Positioned(
            left: 0,
            right: 0,
            top: imageHeight - 32,
            height: screenHeight - imageHeight + 32,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: kGoldProducts.length,
                        separatorBuilder: (context, idx) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, idx) {
                          final gold = kGoldProducts[idx];
                          final product = _products
                                  .where((p) => p.id == gold.productId)
                                  .isNotEmpty
                              ? _products
                                  .firstWhere((p) => p.id == gold.productId)
                              : null;
                          return _GoldCoinItem(
                            amount: gold.coins.toString(),
                            price: product?.price ??
                                (product == null
                                    ? 'Not available'
                                    : gold.priceText),
                            onBuy: _loading || product == null
                                ? null
                                : () => _buyProduct(gold),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldCoinItem extends StatelessWidget {
  final String amount;
  final String price;
  final VoidCallback? onBuy;
  const _GoldCoinItem(
      {required this.amount, required this.price, this.onBuy, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$amount Gold coins',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onBuy,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: onBuy == null
                  ? const Color(0xFFB0DFFF)
                  : const Color(0xFF2CB9FF),
              borderRadius: BorderRadius.circular(17),
            ),
            alignment: Alignment.center,
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

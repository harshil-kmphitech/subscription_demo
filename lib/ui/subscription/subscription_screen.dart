import 'package:subscription_demo/controllers/subscription_controller.dart';

import '../../helpers/all.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Subscription Demo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () {
                controller.tempCount.value;

                return Center(
                  child: Column(
                    children: [
                      Text('isSubscription: ${controller.user.data?.isSubscription}'),
                      Text('isFreeTrialUsed: ${controller.user.data?.isFreeTrialUsed}'),
                      Text('productId: ${controller.user.data?.productId}'),
                      Text('planExpiry: ${utils.getFormatedDate(dateFormate: 'yyyy-MM-dd hh:mm:ss', date: controller.user.data?.planExpiry)}'),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),

            //
            ElevatedButton(
              onPressed: () => controller.loginApi(),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => controller.checkUserPlanApi(),
              child: const Text('Check User Plan'),
            ),
            ElevatedButton(
              onPressed: () async {
                controller.selectedPlanIndex.value = 0;
                await controller.onPurchasePress();
              },
              child: const Text('Purchase Monthly Plan'),
            ),
            ElevatedButton(
              onPressed: () async {
                controller.selectedPlanIndex.value = 1;
                await controller.onPurchasePress();
              },
              child: const Text('Purchase Yearly Plan'),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     controller.isPurchased = false;
            //     controller.selectedPlanIndex.value = 2;
            //     await controller.fetchSubscriptions();
            //     controller.purchaseBottomSheet();
            //   },
            //   child: const Text('Purchase Lifetime Plan'),
            // ),

            //
            ElevatedButton(
              onPressed: () async => controller.onRestorePress(),
              child: const Text('Restore'),
            ),
          ],
        ),
      ),
    );
  }
}

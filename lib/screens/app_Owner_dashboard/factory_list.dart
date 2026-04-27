import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/factory_service.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/add_factories.dart';

class FactoryListScreen extends StatelessWidget {
  final controller = Get.find<FactoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Factories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddFactoryScreen()),
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.factoryList.length,
          itemBuilder: (context, index) {
            final factory = controller.factoryList[index];

            return ListTile(
              title: Text(factory.name),
              subtitle: Text(factory.city),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Get.to(() => AddFactoryScreen(), arguments: factory);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.deleteFactory(factory.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
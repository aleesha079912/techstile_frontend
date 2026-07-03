import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/screens/employee_dashboard/employee_dashboard.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
import 'package:techstile_frontend/screens/employee_dashboard/scan_qr_code.dart';
import 'package:techstile_frontend/screens/employee_dashboard/history_screen.dart';

import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/manager_service/man_emp_notification_service.dart';

import 'package:techstile_frontend/routes/routes.dart';


class EmployeeDrawer extends StatefulWidget {

  final dynamic userId;

  const EmployeeDrawer({
    super.key,
    this.userId,
  });


  @override
  State<EmployeeDrawer> createState() => _EmployeeDrawerState();

}



class _EmployeeDrawerState extends State<EmployeeDrawer> {


final NotificationService notificationService =
    NotificationService();


int unread = 0;



@override
void initState(){

 super.initState();

 getUnread();

}



void getUnread() async {


 final count =
 await notificationService.getUnreadCount(
    AuthService.userId
 );


 if(mounted){

 setState(() {
   unread = count;
 });

 }

}



@override
Widget build(BuildContext context) {


final colors = Theme.of(context).colorScheme;



return Drawer(

backgroundColor: Colors.white,


child: Column(

children: [


Container(

height:80,

width:double.infinity,

padding:const EdgeInsets.all(20),

decoration:BoxDecoration(
color:colors.primary
),


child:const Align(

alignment:Alignment.bottomLeft,

child:Text(
"Employee Panel",

style:TextStyle(
color:Colors.white,
fontSize:20,
fontWeight:FontWeight.bold
),

),

),

),



Expanded(

child:ListView(

padding:EdgeInsets.zero,

children:[



_item(
context,
Icons.dashboard,
"Dashboard",
(){

Get.off(
()=>const EmployeeDashboard()
);

}

),




_item(
context,
Icons.qr_code_scanner,
"Scan QR",
(){

Get.off(
()=>const ScanqrCodeScreen()
);

}

),




_item(
context,
Icons.person,
"Profile",
(){

Get.to(
()=>UserProfileScreen(
userId: AuthService.userId!,
)
);

}

),





// ⭐ Notifications + Count

ListTile(

leading: Badge(

isLabelVisible: unread > 0,

label: Text(
unread.toString(),
),

child:Icon(
Icons.notifications,
color:colors.primary,
),

),


title:const Text(
"Notifications"
),


onTap:() async {


Get.back();


await Get.toNamed(
AppRoutes.employeeNotifications
);


getUnread();


},


),





_item(
context,
Icons.payment,
"History Screen",
(){

Get.off(
()=>const HistoryScreen()
);

}

),




const Divider(),





_item(
context,
Icons.logout,
"Logout",
(){

Get.offAllNamed(
"/login"
);

}

),



],


),


),


],


),


);

}




Widget _item(
BuildContext context,
IconData icon,
String title,
VoidCallback onTap,

){

return ListTile(

leading:Icon(
icon,
color:Theme.of(context)
.colorScheme
.primary,
),


title:Text(
title,

style:const TextStyle(
fontWeight:FontWeight.w500,
fontSize:14
),

),


onTap:(){

Get.back();

onTap();

},

);

}


}
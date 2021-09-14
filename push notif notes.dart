// implementing push Notification
// https://www.youtube.com/watch?v=p7aIZ3aEi2w

// step 1: send and receive push notif

// note: step 1 is enough for you to send and receive push notif
//       with no additional configurations

//    • create a firebase project
//    • download the included google-services.json
//    • paste google-services.json in android/app/google-services.json
//    • configure for each platforms
//    • once the steps above is done, you can start pushing notifications



// =======================================================================
// =======================================================================
// =======================================================================


// step 1.5 - import the local_notification_service.dart included in this repo


// =======================================================================
// =======================================================================
// =======================================================================



// step 2: to enable fetching of title and body - WHILE APP IS OPEN AND ACTIVE

// enable firebase in void main()
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // location of .initialize() may vary if you need to initialize with context
  // please read the initialize method for more info
  LocalNotificationService.initialize(); // from local_notification_service.dart

  await Firebase.initializeApp();
  
  runApp(PushNotifTest());
}

// create an initial state that will configure the notification stream
@override
void initState() {
  super.initState();

  // onMessage method works properly when getInitialMessage() is configured
  FirebaseMessaging.instance.getInitialMessage();

  // this notification will only work if the app is open (foreground)
  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      print('Title: ${message.notification!.title}');
      print('Body: ${message.notification!.body}');
      print('Android: ${message.notification!.android!.imageUrl}');
      // print('Apple: ${message.notification!.apple!.imageUrl}'); // if using ios
      LocalNotificationService.displayNotification(message); // from local_notification_service.dart
    }
  });
}



// =======================================================================
// =======================================================================
// =======================================================================



// step 3: to enable fetching of title and body - WHILE APP IS MINIMIZED (background process)
// important : this code must be included together with step #2

// note 1: in the firebase console, you can include a key-value pair when sending a notif (additional options -> custom data)
// note 2: user defined key must be the same in the firebase and the app

// this notification will only work if the app is minimized (background process)
// this callback will get triggered when the notification is clicked
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  if (message.data.isNotEmpty) {
    print(message.data['userDefinedKey']);

    // you can use this callback to route to a certain page when the notif is clicked
    Navigator.pushNamed(context, '/${message.data['userDefinedKey']}');
  }
});



// =======================================================================
// =======================================================================
// =======================================================================


// step 4: trigger a callback even if the app is minimized (background process)
// important : this code must be included together with step #2

// onBackgroundMessage handler
// must be a top level function - created outside void main()
Future<void> userDefinedFunction(RemoteMessage message) async {
  print(message.data.toString()); // parse the custom data to string
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // from step 2
  LocalNotificationService.initialize(); // from local_notification_service.dart
  await Firebase.initializeApp();             // from step 2

  // onBackgroundMessage - trigger the callback even if the app is minimized (background process)
  FirebaseMessaging.onBackgroundMessage(userDefinedFunction);

  runApp(PushNotifTest()); // from step 2
}



// =======================================================================
// =======================================================================
// =======================================================================



// step 5: receive notification even if the app is closed (terminated)

// getInitialMessage - this notification will only work if the app is closed (terminated)
// upon clicking the notification in the notification tray - it will open the app
// upon clicking the notification in the notification tray - it will run the callback
FirebaseMessaging.instance.getInitialMessage().then((message) {
  if (message != null) {
    Navigator.pushNamed(context, '/${message.data['userDefinedKey']}');
  }
});



// =======================================================================
// =======================================================================
// =======================================================================



// step 6: enabling heads up notifications (pop up notifs)

// By default, the notification will be sent silently to system tray - no heads up notification
// to have a notification pop up when receiving notifs, proceed with this step

// • create a services directory (services = controller for 3rd party packages)
// • create a local_notification_service.dart inside services directory

// • add the following lines of code in androidManifest
//   https://github.com/FirebaseExtended/flutterfire/issues/343
//   channel id is user defined
<meta-data
android:name="com.google.firebase.messaging.default_notification_channel_id"
android:value="default_notification_channel_id"/>

// • create the notification channel in the app
//   this will be created only once upon running the app the first time
//   subsequent runs will already have the existing notification channel

// • inside local_notification_service.dart create a notification channel script
//   pls refer to the included local_notification_service.dart file in this repo


// • on firebase, additional options -> Android Notification Channel
//   write the app's channel id you just defined



// =======================================================================
// =======================================================================
// =======================================================================



// this notification will only work if the app is open (foreground)
FirebaseMessaging.onMessage.listen((message) {});

// this notification will only work if the app is minimized (background process)
// this callback will get triggered when the notification is clicked
FirebaseMessaging.onMessageOpenedApp.listen((message) {});

// onBackgroundMessage - trigger the callback even if the app is minimized (background process)
// no need to click the notification to run the callback, it will automatically run once received
FirebaseMessaging.onBackgroundMessage(userDefinedFunction);

// getInitialMessage - trigger the callback even if the app is closed
// this will open the app and will trigger the callback
FirebaseMessaging.instance.getInitialMessage().then((message) {});

// message.notification!.title - access the notification title
// message.notification!.body - access the notification body
// message.notification!.android!.imageUrl - access the notification image url on android
// message.notification!.apple!.imageUrl - access the notification image url on ios

// message.data['userDefinedKey'] - access the custom data sent through firebase



// other notes

// make sure to only call one per platform because you will receive
// an error if you call both at the same time
// the reason is one will always be null
print('Android: ${message.notification!.android!.imageUrl}');
print('Apple: ${message.notification!.apple!.imageUrl}');
/*Create Dynamic Link*/
/*
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

createLink(int? id) async {
  FirebaseDynamicLinksPlatform dynamicLinks = FirebaseDynamicLinksPlatform.instance;
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: "https://fame2.page.link",
    link: Uri.parse("https://fameapp2.page.link/post?id=$id"),
    androidParameters: const AndroidParameters(
      packageName: 'io.fansoul.fame2',
    ),
    iosParameters: const IOSParameters(
      bundleId: 'io.fansoul.fame2',
    ),
  );

  final ShortDynamicLink dynamicUrl =
  await dynamicLinks.buildShortLink(parameters);
  return dynamicUrl.shortUrl.toString();
}
*/

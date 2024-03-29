// enum QUEST_TYPE {
//   ACTIVE, // FARD, MUAK, NAFL, // Other Sunnah, miswak, washing hands, etc.
//   DAILY, // DAILY, Mumeen chests
//   TIME, // USER'S PERSONAL HEALTH, PERSONAL/FAMILY TIME, etc. fall in here
//   HAPI, // HAPI QUESTS, like collect 10 names of Allah SWT.
// }
//
// // Halal- 5 levels - Haram
// enum SUNNAH_CLASS {
//   FARD,
//   MUAK, // MUAKKADAH/
//   NAFL,
// }
//
// enum IBADAH_TYPE {
//   //https://seekersguidance.org/articles/knowledge/ten-types-of-ibadah-worship-imam-al-ghazzali/
//   SALAH,
//   SAWM,
//   CHARITY, // ZAKAT,SADAQAH,
//   TRAVEL, // HAJJ, UMRAH, VISIT MASJID HARAM, NABAWAI, AQSA,
//   THIKR, //READ, DUA,
//   SOCIAL, //DAWAH, WORK, FAMILY Fullfil obligations to others, family/neighbors/friends
//   JIHAD,
// }

// FARD_SAWM, // RAMADAN
// FARD_ZAKAT,
// FARD_HAJJ,

// MUAK_SALAH_JUMA,
// MUAK_JUMA_GHUSUL,
//
// MUAK_QURAN,
// MUAK_SADAQAH,
// MUAK_UMRAH,
// MUAK_SAWM_ARAFAT,
//
// NAFL_SALAH_TARAWEH, // **TAHAJUD in RAMADAN?
//
// NAFL_SALAH_ISTIKHARA,
// NAFL_SALAH_TAHIYATUL_WUDU,
// NAFL_SALAH_TAHIYATUL_MASJID,
//
// USER_WORK_TIME,
// USER_FAMILY_TIME,
// USER_PERSONAL_TIME,
// USER_CALENDAR_EVENT, //TODO import from user calendar
//
// USER_CUSTOM,
//
// // Halal- 5 levels - Haram
// enum Ahkam {
//   //https://en.wikipedia.org/wiki/Ahkam
//   //https://www.thedeenshow.com/halal-mustahabb-mubah-makrooh-haram/
//   FARD, // WAJIB
//   MUSTAHABB, // or MANDOOK, SHOULD DO FOR AJR
//   MUBAH, // PERMITTED, DON'T DO NO SIN
//   MAKRUH, // DON'T DO IS BETTER, DO TOO MUCH IS SIN
//   HARAM, // SIN
// }

## CODE GLOSSARY  

a/at - Arabic Translation/Transliteration/Template keys, e.g. "a.Fajr", "at.{} on", see MainC's a()  
AC   - AnimationController  
Aft  - After  
Bef  - Before  
bg   - background (like bg color)  
btn  - Button  
C    - Controller  
cb   - theme color background  
cs   - theme color scaffold  
ct   - theme color text  
Cord - Coordinates  
curr - Current  
db   - Database  
del  - Delete  
dis  - Disabled  
dn   - down (use with up: up/dn)  
e    - exception/error  
et   - Event Type, e.g. Relics: Nabi, Surah, or Tarikh ET type.  
h    - height (use with width/w)  
i    - internationalization (for lazy/convenient way making of translation keys)  
idx  - Index  
L    - Left (use with Left/Right->L/R)  
lat  - latitude  
lng  - longitude  
Loc  - Location  
lr   - left right  
msg  - message  
muak - Muakkadah  
nav  - Navigate/Navigator  
np   - NavPage  
nv   - new value  
P    - placement (start, center, end)  
qust - Quest  
qyam - Qiyam  
qv   - Quran Verse  
qvs  - Quran Verses  
R    - Right (use with Left/Right->L/R)  
Rkt  - Rakat  
rv   - return value  
s    - storage/Get Storage  
sliv - sliver  
t    - timeline  
tk   - Translation Key (Previously trKey) - key to lookup translations  
tv   - Translation Value (Previously trVal) - a tk that's been translated  
ts   - text style  
thjd - Tahajjud  
tpr  - Tiles Per Row  
tz   - time zone  
trkh - Tarikh  
val  - Value  
w    - width (use with height/h)  
z    - Zaman (an Islamic point of a day, e.g. fajr, sunrise, karahat times, etc.)  

## Islamic GLOSSARY  

tarikh - history  

## GetX Flutter Firebase Auth Example

![](https://cdn-images-1.medium.com/max/4776/1*OKSIgkZpss30GYT9TwQcJg.png)

UPDATE: Version 2.0.0 Changed to new language options and added null safety.

GetX is a relatively new package for Flutter that provides the missing link in making Flutter development simpler. I recently converted a [firebase auth project](https://medium.com/@jeffmcmorris/flutter-firebase-auth-starter-project-b0f91a6503b7) I had created which used provider for state management. Switching to GetX simplified many of the pain points I have had with Flutter development. I no longer was having to pass context into functions. I could also better separate my logic from the UI. GetX also greatly simplifies routing, displaying snackbars and dialogs.

There are some really good projects and tutorials that I made use of in making [this project](https://github.com/delay/flutter_starter). See these links for more help with GetX. [GetX Documentation](https://github.com/jonataslaw/getx), [Todo GetX example](https://medium.com/@loicgeek/flutter-how-to-create-a-todo-app-using-firebase-firestore-and-firebase-authentication-with-getx-89bdaacc6de6), [Amateur Coder GetX Videos](https://www.youtube.com/watch?v=CNpXbeI_slw) and [Loading Overlay](https://medium.com/@fayaz07/dont-kill-app-s-ui-thread-for-showing-loading-indicators-809e5a992230).

So why would you want to use GetX? Let me give you an example of how it simplified my own code. When I used Provider there was a lot more boilerplate code. It felt much more esoteric to use. GetX made my code easier to understand. Here is my code for main.dart original vs. GetX.

![](https://cdn-images-1.medium.com/max/3932/1*Sg7dajwS-q-I_G4KLDx_ow.png)

Once you understand the GetX way it becomes much easier to organize your code and separate your concerns between your UI and functions. For instance when calling a function in the UI I was having to handle the results from the function and display snackbars with the results. With GetX I was able to move the snackbars into the actual function which makes more sense since I no longer have to send success and fail messages in and out of functions. Below I show a button which signs in the user with the old way vs GetX way. I prefer the GetX way even though it isn’t a lot shorter, but I like having my logic all separated from the UI.

![](https://cdn-images-1.medium.com/max/3580/1*YWsqOuTY1xvqkVvGrt2BLQ.png)

GetX also has a storage package called [get_storage](https://github.com/jonataslaw/get_storage). It can take the place of shared preferences. It simplifies the way to store data on the device. Here is another example of before and after code.

![](https://cdn-images-1.medium.com/max/2600/1*kyYboVrB1BYcMkeHsSNeSw.png)

There are many other features of GetX to make things simpler, such as working with themes, getting various device settings, etc. This package simplifies a lot of the problems developers face daily when building an app.

When building an auth project there are a lot of the features you need for a production flutter project. I wanted light and dark mode theming but also the ability to detect and switch themes automatically. I needed the ability to switch between languages easily and automatically detect the user’s language. I wanted a simple way to handle translating from english (the only language I know unfortunately). This is accomplished by running a commandline app to generate the GetX Localization class which pulls from a [google sheet](https://docs.google.com/spreadsheets/d/1oS7iJ6ocrZBA53SxRfKF0CG9HAaXeKtzvsTBhgG4Zzk/edit#gid=0) and easily translate into other languages. Also I needed a way to [do simple user roles](https://medium.com/firebase-developers/patterns-for-security-with-firebase-group-based-permissions-for-cloud-firestore-72859cdec8f6) and it needed to be secure. I see a lot of auth packages including roles in the user’s collection in firestore which is usually editable by that same user. This would make it trivial for the user to assign himself admin privileges. I also wanted to show how to put some basic rules in firestore to secure it. Finally I wanted to have a way the user could alter their profile and change their email or password.

To handle the language translation you need to create a translation for your app in google sheets.  Then ```cd lib/menu/slide/menu_buttom/settings/lang/``` and replace the docID and sheetId with your own documentId and sheetId.  After doing that your will need to drop to the command line and go into the settings/language directory.  Then type: ```dart update_localizations.dart```.  This will create or overwrite the localization.g.dart file with your custom translation.  There should not be a need to edit this file directly.  Everytime you make changes to your translation you will need to re-run this generator.

![](https://cdn-images-1.medium.com/max/2000/0*9-A7El_nRDBz-ecK)

You can copy my [sheet](https://docs.google.com/spreadsheets/d/1oS7iJ6ocrZBA53SxRfKF0CG9HAaXeKtzvsTBhgG4Zzk/edit#gid=0) as a starting point for your own app. The cool thing about using a google sheet is you can have google translate a field with a simple google formula: =GOOGLETRANSLATE(B4,en,fr) This says translate the phrase in field B4 from english to french. 

To handle user roles I created a separate admin collection and added a document with the same document id as the uid of my user. The reason to do this is to make it secure as explained in this [medium article](https://medium.com/firebase-developers/patterns-for-security-with-firebase-group-based-permissions-for-cloud-firestore-72859cdec8f6). I went with the second method explained in that article. If we had just put the roles as a field in the users collection any user could have upgraded themselves to an admin user. So by moving the admin role to a separate collection we can create some rules in firestore that allow the user to update fields about themselves without giving them access to change the role they were assigned. You can also generate other roles for the user by simply adding additional collections for the other roles..

The rules I have setup in firestore for this project are fairly simple. Here are the rules I have created.

![](https://cdn-images-1.medium.com/max/2000/0*_lmwiYDofWZd0Kn0)

The first rule matches any user in the admin collection and allows you to read that document only. No one is allowed to write to this collection. I manually add my admin users through the firebase console. The second rule allows the user to read and write only if the user matches the currently logged in user. So a user can only change information about themselves. Here is how my collections are setup in firestore.

![](https://cdn-images-1.medium.com/max/2060/0*uFxZGvnPvviMebQ5)

Finally I wanted to explain a little bit about my ui. I try to control as much as possible with the theme. You can change a lot about the look with the user interface by changing the theme. I am still learning about what all can be changed with just the theme. I also break out small ui components into a separate components folder. Then I make a custom widget instead of using the standard widget directly. This allows me to make changes in one spot if I decide to make ui changes to say a form field in my form_input_field.dart instead of changing a bunch of TextFormField widgets spread through a dozen files.

TODO where did this go?:
**home_ui.dart** — contains the ui for the home which shows info about the user.

Make sure you [setup firebase](https://firebase.google.com/docs/flutter/setup?platform=android) with your project.

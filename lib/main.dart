import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_reading/Backend/Message.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
//import package files

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyFileList(), //call MyFile List
    );
  }
}

//apply this class on home: attribute at MaterialApp()
class MyFileList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyFileList();
  }
}

class _MyFileList extends State<MyFileList> {
  List<File> files;
  final GlobalKey<RefreshIndicatorState> _refreshkey =
      new GlobalKey<RefreshIndicatorState>();

  List<File> savefile = [];
  var details = new Map();
  int count = 1;

  Future<void> getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir;
    print("Hey");
    print(root); //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root + '/project')); //
    files = await fm.filesTree(
      //set fm.dirsTree() for directory/folder tree list
      //excludedPaths: ["/storage/emulated/0/project/"],
      sortedBy: FileManagerSorting.Date,
      //extensions: ["jpg"] //optional, to filter files, remove to list all,
      //remove this if your are grabbing folder list
    );

    print('HEYYYYYYYYY');
    print(files);
    final Telephony telephony = Telephony.instance;
    telephony.requestPhoneAndSmsPermissions;
    var status = await Permission.storage.request();
    print(status);
    if (await Permission.storage.request().isGranted) {
      for (int i = 0; i < files.length; i++) {
        String fileName = files[i].path.split('/').last;
        //print(fileName);
        for (int j = 0; j < 1; j++) {
          File file = new File("/storage/emulated/0/project/" + fileName);
          savefile.add(file);
          if (savefile.length == 2) {
            //print(savefile);
            details['packet' + count.toString()] = savefile;
            print(details);
            count += 1;
            //print(savefile);
            List<String> number = ["734873573", "734873567"];
            for (int i = 0; i < number.length; i++) {
              await sendingSMS(
                  'From (Client Name),' +
                      '\n'
                          'Please check your email',
                  number[i]);
            }
            await gmailMessage(savefile);
            savefile = [];
            print(details);
          }
        }
      }
      print(details);
      setState(() {});
    } //update the UI
  }

  //final GlobalKey<RefreshIndicatorState> _refreshkey =new GlobalKey<RefreshIndicatorState>();
  Future<void> refreshProp() async {
    _refreshkey.currentState?.show(atTop: false);
    await getFiles();
    //accessingPermissions();
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
    final Telephony telephony = Telephony.instance;
    telephony.requestPhoneAndSmsPermissions;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Permission.storage.request();
    while (true) {
      await getFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Colors.black,
      color: Colors.white,
      key: _refreshkey,
      onRefresh: refreshProp,
      child: Scaffold(
        appBar: AppBar(
            title: Text("Files list from Internal Storage"),
            backgroundColor: Colors.redAccent),
        body: files == null
            ? Text("Searching Files")
            : ListView.builder(
                //if file/folder list is grabbed, then show here
                itemCount: files?.length ?? 0,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    title: Text(files[index].path.split('/').last),
                    leading: Icon(Icons.image),
                    trailing: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                  ));
                },
              ),
      ),
    );
  }
}

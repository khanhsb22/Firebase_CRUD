import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/student.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp(const MaterialApp(
  title: "MyApp",
  home: MyApp(),
));
}

class MyApp extends StatefulWidget {
const MyApp({Key? key}) : super(key: key);

@override
_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
var dbRef = FirebaseDatabase.instance.ref();

Future<void> createStudent(String name, String age) async {
  dbRef.child("Student").push().set({"name": name, "age": age});
}

// Chỗ này cần phải async vì khi lấy duy nhất 1 field thì được phép
// gán giá trị bên ngoài đoạn code firebase, việc await đòi hỏi
// đoạn lệnh lấy dữ liệu phải được thực thi xong thì các field name, age
// mới lấy được dữ liệu, nếu ko có await thì name và age đều bằng ""
Future<void> readOneStudent(String id) async {
  Student st;
  String name = "";
  String age = "";
  // Wait until fetching the values is done
  await dbRef.child("Student/" + id).once().then((value) => {
        Map<String, dynamic>.from(value.snapshot.value as dynamic)
            .forEach((key, value) {
          switch (key) {
            case 'name':
              {
                name = value;
                //print("Name: " + name);
              }
              break;
            case 'age':
              {
                age = value;
                //print("Age: " + age);
              }
              break;
          }
        })
      });
  st = Student(name: name, age: age);
  print("Name: " + st.name + "\n" + "Age: " + st.age);
}

// Nếu đã khai báo await trên hàm main thì dưới này ko cần phải tạo hàm async nữa
void readAllStudent() {
  String name = "";
  String age = "";
  List<Student> students = [];
  int count = 0;
  /*
  * Student -> x3 key -> x3 {}{}{}
  * */
  dbRef.child("Student/").onChildAdded.listen((event) {
      dbRef.child("Student/" + event.snapshot.key.toString()).onValue.listen((event0) {
      Map<String, dynamic>.from(event0.snapshot.value as dynamic).forEach((key, value) {
        switch (key) {
          case 'name':
            {
              name = value;
            }
            break;
          case 'age':
            {
              age = value;
              students.add(Student(name: name, age: age));
              count++;
              /*
              * Vì không lấy được giá trị của các trường ra để sau khi kết thúc
              * việc duyệt các phần tử trên firebase, nên khi làm thực tế
              * phải có một field là count, mỗi khi thêm 1 node thì tăng count lên 1,
              * nếu count trong đoạn code == count trên firebase thì cho xuất list.
              * */
              if (count == 3) {
                for (var item in students) {
                  print("[Name: " + item.name + ", Age: " + item.age + "]");
                }
                //print("[Name: " + name + ", Age: " + age + "]");
              }
              //students.add(Student(name: name, age: age));
            }
            break;
        }


      });
    });
  });
  // Đoạn này sẽ ko lấy được data trong đoạn code firebase
  /*for (var item in students) {
    print("[Name: " + item.name + ", Age: " + item.age + "]");
  }*/
  
}

Future<void> update(String id) async {
  await dbRef.child("Student/" + id).update({"name": "Adam 2", "age": "22"}).then((value) => null);
}

Future<void> delete(String id) async {
  await dbRef.child("Student/" + id).remove().then((value) => null);
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Firebase"),
    ),
    body: Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: () {
              createStudent("Susan", "28");
            },
            child: Text(
              "Create",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: () {
              readOneStudent("-MuhjFGlytpWjeG-Ol05");
            },
            child: Text(
              "Read one",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: (){
              readAllStudent();
            },
            child: Text(
              "Read all",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: () {
              update("-Muhj9lzY44GSOUX1jBO");
            },
            child: Text(
              "Update",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: () {
              delete("-MujYrWFTcrPrBittgCU");
            },
            child: Text(
              "Delete",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

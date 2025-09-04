import 'package:cloud_firestore/cloud_firestore.dart'; // 1. أضفنا هذه الحزمة
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // 2. أنشأنا مرجعًا لقاعدة بيانات Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // --- 3. الكود الجديد لإنشاء ملف المستخدم في Firestore ---
      if (user != null) {
        // ابحث عن مستند يحمل نفس uid الخاص بالمستخدم
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // إذا كان المستند غير موجود، فهذه هي المرة الأولى للمستخدم
        if (!userDoc.exists) {
          // قم بإنشاء مستند جديد له
          await _firestore.collection('users').doc(user.uid).set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': Timestamp.now(), // تاريخ إنشاء الحساب
            'isVip': false, // القيمة الافتراضية لعضوية VIP
          });
        }
      }
      // -----------------------------------------------------------

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
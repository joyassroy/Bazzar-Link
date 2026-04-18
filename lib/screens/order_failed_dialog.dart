import 'package:flutter/material.dart';

class OrderFailedDialog extends StatelessWidget {
  const OrderFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20), // Screen-er pashe ektu faka rakhbe
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Joto tuku space dorkar tototukui nibe
          children: [
            // --- 1. Close Button (Top Left) ---
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 28),
                onPressed: () {
                  Navigator.pop(context); // Dialog close korbe
                },
              ),
            ),

            const SizedBox(height: 10),

            // --- 2. Illustration Image ---
            // Nicher image URL ta ami demo grocery bag diyechi,
            // tomar kache local asset thakle Image.asset('assets/images/failed_icon.png') use korbe
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/3081/3081840.png',
              height: 150,
            ),

            const SizedBox(height: 30),

            // --- 3. Error Title ---
            const Text(
              "Oops! Order Failed",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 15),

            // --- 4. Subtitle ---
            const Text(
              "Something went terribly wrong.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // --- 5. Try Again Button ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53B175),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // Dialog close korbe, user abar try korte parbe
              },
              child: const Text(
                "Please Try Again",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- 6. Back to Home Button ---
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                // Dialog close kore eke bare home page e niye jabe
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text(
                "Back to home",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
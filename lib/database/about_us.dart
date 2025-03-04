import 'package:flutter/material.dart';
import 'package:matrimonial/database/home.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ABOUT US',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.pink,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.keyboard, size: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Typing Tutor",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              title: "Meet Our Team",
              content: [
                _infoRow("Developed by", "Bhoomi Tulsiyani (23010101275)"),
                _infoRow("Mentored by", "Prof. Mehul Bhundiya\n(Computer Engineering Department)"),
                _infoRow("Explored by", "ASWDC, School Of Computer Science"),
                _infoRow("Eulogized by", "Darshan University, Rajkot, Gujarat - INDIA"),
              ],
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              title: "About ASWDC",
              content: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/dulogo.png', width: 180, height: 100),
                      SizedBox(width: 20),
                      Image.asset('assets/images/aswdc.png', width: 88, height: 100),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "ASWDC is an Application, Software, and Website Development Center at Darshan University run by students and staff of the School of Computer Science.",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 10),
                Text(
                  "The sole purpose of ASWDC is to bridge the gap between university curriculum & industry demands.",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              title: "Contact Us",
              content: [
                _contactRow(Icons.email, "aswdc@darshan.ac.in", "mailto:aswdc@darshan.ac.in"),
                _contactRow(Icons.phone, "+91-9727747317", "tel:+919727747317"),
                _contactRow(Icons.language, "www.darshan.ac.in", "https://www.darshan.ac.in"),
              ],
            ),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> content}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            Divider(color: Colors.purple),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink),
            SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 15, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _actionRow(Icons.share, "Share App"),
            _actionRow(Icons.apps, "More Apps"),
            _actionRow(Icons.star, "Rate Us"),
            _actionRow(Icons.thumb_up, "Like us on Facebook"),
            _actionRow(Icons.update, "Check for Update"),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(IconData icon, String text) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink),
            SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "© 2025 Darshan University",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("All Rights Reserved - ", style: TextStyle(fontSize: 12),),
            InkWell(
              onTap: () => launchUrl(Uri.parse("https://www.darshan.ac.in/privacy")),
              child: Text("Privacy Policy", style: TextStyle(color: Colors.blue, fontSize: 12)),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text("Made in India", style: TextStyle(fontSize: 12),),
      ],
    );
  }
}
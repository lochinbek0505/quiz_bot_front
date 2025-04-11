import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.blueAccent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGlassCard(BuildContext context, String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              buildButton(
                text: "➕ Test qo‘shish",
                icon: Icons.add_circle_outline,
                onTap: () {},
                color: Colors.greenAccent,
              ),
              buildButton(
                text: "🛠 Testni tahrirlash",
                icon: Icons.edit_note,
                onTap: () {},
                color: Colors.blueAccent,
              ),
              buildButton(
                text: "🗑 Testni o‘chirish",
                icon: Icons.delete_outline,
                onTap: () {},
                color: Colors.orangeAccent,
              ),
              buildButton(
                text: "🧨 Imtihonni o‘chirish",
                icon: Icons.delete_forever,
                onTap: () {},
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "⚙️ Admin Panel",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: "Yangi imtihon",
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            buildGlassCard(context, "📘 Matematika Imtihoni"),
            buildGlassCard(context, "🧪 Kimyo Imtihoni"),
            buildGlassCard(context, "🌿 Biologiya Imtihoni"),
          ],
        ),
      ),
    );
  }
}

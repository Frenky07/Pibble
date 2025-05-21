import 'package:flutter/material.dart';

class VaccineOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _CustomSliverHeaderDelegate(
              minHeight: 120.0, 
              maxHeight: 120.0,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: Text(
                    'Pilih Paket Layanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                VaccineButton(
                  label: "Vaksin Rabies",
                  description:
                      "Vaksin ini membantu melindungi kucing dan anjing dari virus rabies jika mereka pernah digigit oleh hewan yang terinfeksi rabies. Ini adalah vaksin \"inti\" dan bahkan hewan peliharaan yang tinggal di dalam rumah harus divaksinasi, karena selalu ada risiko mereka bisa melarikan diri dan terpapar virus dari hewan di luar rumah.",
                  price: "375.000",
                ),
                SizedBox(height: 16),
                VaccineButton(
                  label: "Vaksin DHPP",
                  description:
                      "Vaksin ini untuk mencegah anjing melawan distemper, hepatitis, parvovirus, dan parainfluenza. Vaksin Leptospirosis, Virus Corona, dan Rabies dapat disertakan dalam layanan ini.",
                  price: "465.000 - 630.000",
                ),
                SizedBox(height: 16),
                VaccineButton(
                  label: "Vaksin RCP",
                  description:
                      "Vaksin ini digunakan untuk melindungi kucing dari usia 8 minggu terhadap rinotrakeitis virus kucing (penyakit mirip flu yang disebabkan oleh virus herpes); calicivirosis kucing (penyakit mirip flu dengan radang mulut yang disebabkan oleh calicivirus); dan feline panleucopenia (penyakit serius yang menyebabkan diare berdarah yang disebabkan oleh parvovirus).",
                  price: "495.000 - 600.000",
                ),
                SizedBox(height: 16),
                VaccineButton(
                  label: "Vaksin Kennel Cough",
                  description: "Vaksin untuk melindungi dari batuk kennel.",
                  price: "450.000 - 665.000",
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class VaccineButton extends StatefulWidget {
  final String label;
  final String description;
  final String price;

  const VaccineButton({
    Key? key,
    required this.label,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  _VaccineButtonState createState() => _VaccineButtonState();
}

class _VaccineButtonState extends State<VaccineButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded; // Toggle the expanded state
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Keterangan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Harga",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp ${widget.price}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Add your action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Pilih",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _CustomSliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Vaksin",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(221, 89, 89, 89),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:online_course/screens/package_details.dart';
import 'package:online_course/theme/color.dart';

import '../models/packagelist.dart';
import 'custom_image.dart';

class PackageItem extends StatelessWidget {
  final Package data;
  final double width;
  final double height;
  final GestureTapCallback? onTap;

  PackageItem({
    Key? key,
    required this.data,
    this.width = 280,
    this.height = 290,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Text(data.packageName!);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PackageDetailsScreen(
                    packageId: data.id!,
                    packageImage: data.imgUrl![0],
                    packageName: data.packageName!)));
      },
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          children: [
            Hero(
              tag: data.id!,
              child: CustomImage(
                data.imgUrl![0],
                width: double.infinity,
                height: 190,
                radius: 15,
              ),
            ),
            Positioned(
              top: 170,
              right: 15,
              child: _buildPrice(),
            ),
            Positioned(
              top: 210,
              child: _buildInfo(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      width: width - 20,
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.packageName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: AppColor.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _buildAttributes(),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        data.price!,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAttributes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getAttribute(
          Icons.play_circle_outlined,
          AppColor.labelColor,
          data.tag!,
        ),
        const SizedBox(
          width: 12,
        ),
        // _getAttribute(
        //   Icons.schedule_rounded,
        //   AppColor.labelColor,
        //   data!.courses!.length!.toString(),
        // ),
        const SizedBox(
          width: 12,
        ),
        _getAttribute(
          Icons.star,
          AppColor.yellow,
          data!.courses!.length!.toString(),
        ),
      ],
    );
  }

  _getAttribute(IconData icon, Color color, String info) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          info,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColor.labelColor, fontSize: 13),
        ),
      ],
    );
  }
}

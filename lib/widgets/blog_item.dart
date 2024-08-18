import 'package:flutter/material.dart';
import 'package:online_course/screens/blog_details.dart';
import 'package:online_course/theme/color.dart';
import 'package:online_course/widgets/custom_image.dart';
import '../models/bloglist.dart';

class BlogItem extends StatelessWidget {
  final Blog data;

  const BlogItem({
    Key? key,
    required this.data,
    this.onTap,
  }) : super(key: key);

  //final data;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BlogDetailsScreen(
                    blogId: data.id!,
                    blogImage: data.imgUrl![0],
                    blogTitle: data.title!)));
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(10),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            CustomImage(
              data.imgUrl![0],
              radius: 15,
              height: 80,
            ),
            const SizedBox(
              width: 10,
            ),
            _buildInfo()
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title.length > 15
              ? data.title.substring(0, 15) + '...'
              : data.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          data.writtenBy,
          style: TextStyle(fontSize: 14, color: AppColor.textColor),
        ),
        const SizedBox(
          height: 15,
        ),
//_buildDurationAndRate()
      ],
    );
  }

  Widget _buildDurationAndRate() {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          color: AppColor.labelColor,
          size: 14,
        ),
        const SizedBox(
          width: 2,
        ),
        // Text(
        //   data["duration"],
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: AppColor.labelColor,
        //   ),
        // ),
        const SizedBox(
          width: 20,
        ),
        Icon(
          Icons.star,
          color: AppColor.orange,
          size: 14,
        ),
        const SizedBox(
          width: 2,
        ),
        // Text(
        //   data["review"],
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: AppColor.labelColor,
        //   ),
        // )
      ],
    );
  }
}

import 'package:api_testing/Get_Api/get_single_post.dart';
import 'package:flutter/material.dart';

import 'multi_post/get_multi_posts.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Get Api'),centerTitle: true,),

      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GetSinglePost()));
            },
                child: Text('SinglePost')
            ),  ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GetMultiPosts()));
            },
                child: Text('MultiPost')
            ),
          ],
        ),
      ),
    );
  }
}

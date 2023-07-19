import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateApplicationScreen extends StatefulWidget {
  @override
  _RateApplicationScreenState createState() => _RateApplicationScreenState();
}

class _RateApplicationScreenState extends State<RateApplicationScreen> {
  final _reviewController = TextEditingController();
  double _rating = 0.0;
  String? _userId;
  bool _isExistingReview = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _checkExistingReview();
    }
  }

  void _checkExistingReview() async {
    final reviewDoc = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(_userId)
        .get();

    setState(() {
      _isExistingReview = reviewDoc.exists;
      if (_isExistingReview) {
        final data = reviewDoc.data();
        _rating = data?['rating'] ?? 0.0;
        _reviewController.text = data?['review'] ?? '';
      }
    });
  }

  void _submitReview() async {
    final review = _reviewController.text;
    final reviewData = {
      'rating': _rating,
      'review': review,
    };

    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(_userId)
        .set(reviewData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Rating'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Opinion helps us to improve the service',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16.0),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40.0,
              unratedColor: Colors.grey[300],
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your review',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Submit'),
            ),
            if (_isExistingReview) ...[
              SizedBox(height: 16.0),
              Text(
                'Your Review:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text('Rating: $_rating'),
              SizedBox(height: 8.0),
              Text('Review: ${_reviewController.text}'),
            ],
          ],
        ),
      ),
    );
  }
}

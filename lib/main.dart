import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For Timer

void main() {
  runApp(MaterialApp(
    home: AddressListScreen(),
  ));
}

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<dynamic> addresses = []; // To store the fetched data
  bool isLoading = false; // To show a loading indicator while fetching data
  Timer? _timer; // For periodic data fetching

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data initially
    // Start polling for new data every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchData(); // Fetch data periodically every 30 seconds
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Fetch data from the API
  void fetchData() async {
    setState(() {
      isLoading = true; // Set loading to true while fetching data
    });

    var url = Uri.parse('http://localhost:8080/api/addresses/get-all-addresses'); // Replace with your API endpoint
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response if the request was successful
      List<dynamic> data = json.decode(response.body);
      setState(() {
        addresses = data; // Update the addresses list
        isLoading = false; // Set loading to false after fetching
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false in case of failure
      });
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : Column(
              children: [
                ElevatedButton(
                  onPressed: fetchData, // Manual refresh button
                  child: Text('Fetch Data'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      var address = addresses[index];
                      return ListTile(
                        title: Text('${address['number']} ${address['street']}'),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${address['postcode']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    // Get message when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<MessageProvider>().getMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
      ),
      // body: Consumer<MessageProvider>(
      //   builder: (context, provider, child) {
      //     final state = provider.state;
      //
      //     if (state.isLoading) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //
      //     if (state.error != null) {
      //       return Center(
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Text('Error: ${state.error}'),
      //             const SizedBox(height: 20),
      //             ElevatedButton(
      //               onPressed: () => provider.getMessage(),
      //               child: const Text('Retry'),
      //             ),
      //           ],
      //         ),
      //       );
      //     }
      //
      //     return Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(state.message ?? 'No message'),
      //           const SizedBox(height: 20),
      //           ElevatedButton(
      //             onPressed: state.message != null
      //                 ? () {
      //                     Navigator.pushNamed(
      //                       context,
      //                       '/second',
      //                       arguments: state.message,
      //                     );
      //                   }
      //                 : null,
      //             child: const Text('Go to Second Screen'),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
    );
  }
}

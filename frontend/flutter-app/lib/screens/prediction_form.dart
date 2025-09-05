import 'package:flutter/material.dart';
import '../models/house_features.dart';
import '../services/api.dart';
import '../utils/currency.dart';
import '../data/options.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({super.key});

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();

  int bedrooms = 3;
  int bathrooms = 3;
  int toilets = 4;
  int parking = 2;
  String town = towns.first;
  String title = titles.first;

  bool loading = false;
  double? predictedPrice;
  String? errorText;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      errorText = null;
      predictedPrice = null;
    });
    try {
      final features = HouseFeatures(
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        toilets: toilets,
        parkingSpace: parking,
        town: town,
        title: title,
      );
      final price = await _api.predictPrice(features);
      setState(() => predictedPrice = price);
    } catch (e) {
      setState(() => errorText = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lagos Housing Price Predictor')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  Text('Enter property details',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Bedrooms'),
                          initialValue: bedrooms.toString(),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          onChanged: (v) => bedrooms = int.tryParse(v) ?? bedrooms,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Bathrooms'),
                          initialValue: bathrooms.toString(),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          onChanged: (v) => bathrooms = int.tryParse(v) ?? bathrooms,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Toilets'),
                          initialValue: toilets.toString(),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          onChanged: (v) => toilets = int.tryParse(v) ?? toilets,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Parking Space'),
                          initialValue: parking.toString(),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          onChanged: (v) => parking = int.tryParse(v) ?? parking,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: town,
                    decoration: const InputDecoration(labelText: 'Town'),
                    items: towns
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => town = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    items: titles
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => title = v!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: loading ? null : _submit,
                    icon: const Icon(Icons.auto_graph),
                    label: loading
                        ? const Text('Predicting...')
                        : const Text('Predict Price'),
                  ),
                  const SizedBox(height: 20),
                  if (predictedPrice != null) _ResultCard(value: predictedPrice!),
                  if (errorText != null)
                    Text(errorText!, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double value;
  const _ResultCard({required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Predicted Price', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(formatNaira(value),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This is an estimate based on your inputs.'),
          ],
        ),
      ),
    );
  }
}

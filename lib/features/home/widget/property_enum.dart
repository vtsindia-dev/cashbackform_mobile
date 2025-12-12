// lib/models/property_type_enum.dart
enum PropertyType {
  market('Market', 'market', 'Featured Market Properties', 'market/featured'),
  syndicate('Syndicate', 'synticate', 'Featured Syndicate Properties', 'synticate/featured'),
  gioo('GIOO', 'geo', 'Featured GIOO Properties', 'geo/featured'),
  service('Service', 'services', 'Professional Services', 'services_list'),
  material('Material', 'materials', 'Material Store', 'material_list');

  final String displayName;
  final String apiKey;
  final String pageTitle;
  final String apiEndpoint;

  const PropertyType(this.displayName, this.apiKey, this.pageTitle, this.apiEndpoint);
}
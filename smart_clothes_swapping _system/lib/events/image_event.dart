import 'dart:io';

abstract class ImageEvent {}

class ImageFileSubmittedWithDetails extends ImageEvent {
  final File file;
  final String brand;
  final String size;
  final String category;
  final int userId;

  ImageFileSubmittedWithDetails({
    required this.file,
    required this.brand,
    required this.size,
    required this.category,
    required this.userId
  });
}

class ImageUrlSubmittedWithDetails extends ImageEvent {
  final String url;
  final String brand;
  final String size;
  final String category;
  final int userId;

  ImageUrlSubmittedWithDetails({
    required this.url,
    required this.brand,
    required this.size,
    required this.category, 
    required this.userId,
    
  });
}

class ImageUpdated extends ImageEvent {
  final int id;
  final String? brand;
  final String? size;
  final String? category;

  ImageUpdated({
    required this.id,
    this.brand,
    this.size,
    this.category,
  });
}

class ImageDeleted extends ImageEvent {
  final int id;

  ImageDeleted({required this.id});
}

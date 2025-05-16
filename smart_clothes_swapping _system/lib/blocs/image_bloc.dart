import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/image_event.dart';
import '../models/image_model.dart';
import '../services/image_service.dart';

enum ImageStatus { initial, loading, success, failure }

class ImageState {
  final ImageStatus status;
  final List<ImageModel> images;
  final String errorMessage;

  ImageState({
    this.status = ImageStatus.initial,
    this.images = const [],
    this.errorMessage = '',
  });

  ImageState copyWith({
    ImageStatus? status,
    List<ImageModel>? images,
    String? errorMessage,
  }) {
    return ImageState(
      status: status ?? this.status,
      images: images ?? this.images,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final ImageService imageService;

  ImageBloc(this.imageService) : super(ImageState()) {
    // URL ve detaylarla resim yükleme olayı
    on<ImageUrlSubmittedWithDetails>((event, emit) async {
      emit(state.copyWith(status: ImageStatus.loading));
      try {
        final image = await imageService.uploadImageWithDetails(
          url: event.url,
          brand: event.brand,
          size: event.size,
          category: event.category,
          userId: event.userId
        );
        final updatedImages = List<ImageModel>.from(state.images)..add(image);
        emit(state.copyWith(status: ImageStatus.success, images: updatedImages));
      } catch (e) {
        emit(state.copyWith(status: ImageStatus.failure, errorMessage: e.toString()));
      }
    });

    // Resim güncelleme olayı
    on<ImageUpdated>((event, emit) async {
      emit(state.copyWith(status: ImageStatus.loading));
      try {
        await imageService.updateClothing(
          id: event.id,
          brand: event.brand!,
          size: event.size!,
          category: event.category!,
        );

        final updatedImages = state.images.map((image) {
          if (image.id == event.id) {
            return image.copyWith(
              brand: event.brand,
              size: event.size,
              category: event.category,
            );
          }
          return image;
        }).toList();

        emit(state.copyWith(status: ImageStatus.success, images: updatedImages));
      } catch (e) {
        emit(state.copyWith(status: ImageStatus.failure, errorMessage: e.toString()));
      }
    });

    // Resim silme olayı
    on<ImageDeleted>((event, emit) async {
      emit(state.copyWith(status: ImageStatus.loading));
      try {
        await imageService.deleteClothing(event.id);

        final updatedImages = state.images.where((image) => image.id != event.id).toList();
        emit(state.copyWith(status: ImageStatus.success, images: updatedImages));
      } catch (e) {
        emit(state.copyWith(status: ImageStatus.failure, errorMessage: e.toString()));
      }
    });
  }

  // Yeni eklediğimiz metodlar
  void updateClothing({
    required int id,
    required String brand,
    required String size,
    required String category,
  }) {
    add(ImageUpdated(id: id, brand: brand, size: size, category: category));
  }

  void deleteClothing(int id) {
    add(ImageDeleted(id: id));
  }
}

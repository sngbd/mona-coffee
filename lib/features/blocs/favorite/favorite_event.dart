abstract class FavoriteEvent {
  const FavoriteEvent();
}

class LoadFavorites extends FavoriteEvent {}

class AddToFavorites extends FavoriteEvent {
  final String name;
  final String type;
  final String image;

  const AddToFavorites({
    required this.name,
    required this.type,
    required this.image,
  });
}

class RemoveFromFavorites extends FavoriteEvent {
  final String documentId;

  const RemoveFromFavorites(this.documentId);
}

class CheckFavoriteStatus extends FavoriteEvent {
  final String name;
  final String type;

  const CheckFavoriteStatus({
    required this.name,
    required this.type,
  });
}

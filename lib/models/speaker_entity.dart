import 'package:objectbox/objectbox.dart';

@Entity()
class SpeakerEntity {
  int id;
  String? name;
  String? model;

  @HnswIndex(dimensions: 192, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  int? createdAt;

  SpeakerEntity({
    this.id = 0,
    this.name,
    this.model,
    this.embedding,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;
}

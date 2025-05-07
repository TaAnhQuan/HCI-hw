import 'package:objectbox/objectbox.dart';

@Entity()
class TodoEntity {
  int id;
  String? task;
  String? detail;

  @HnswIndex(dimensions: 1536, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double>? vector;

  @Property()
  int statusIndex;

  @Index()
  int? deadline;

  bool clock;

  @Index()
  int? createdAt;

  TodoEntity({
    this.id = 0,
    this.task,
    this.detail,
    this.vector,
    this.deadline,
    this.clock = false,
    int? createdAt,
    Status status = Status.pending,
  }) : statusIndex = status.index,
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Status get status => Status.values[statusIndex];
  set status(Status status) => statusIndex = status.index;
}

enum Status { pending, completed, expired, all }

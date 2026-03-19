import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiTagMapper on api.Tag {
  domain.Tag toDomain() => domain.Tag(
    id: id,
    name: name,
  );
}

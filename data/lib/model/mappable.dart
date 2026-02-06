abstract class Mappable {
  Map<String, dynamic> toJson();
  Mappable fromJson(Map<String, dynamic> json);
}

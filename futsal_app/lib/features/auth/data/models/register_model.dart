class RegisterResponseModel {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;

  RegisterResponseModel({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      type: json['type'],
      title: json['title'],
      status: json['status'],
      detail: json['detail'],
      instance: json['instance'],
    );
  }
}

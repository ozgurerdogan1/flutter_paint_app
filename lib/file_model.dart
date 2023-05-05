// ignore_for_file: public_member_api_docs, sort_constructors_first
class FileModel {
  String filePath;
  String? fileName;
  String? fileExtension;
  int? fileLenght;
  String? createdDate;
  DateTime? lastModifiedDate;
  FileModel({
    required this.filePath,
     this.fileName,
     this.fileExtension,
     this.fileLenght,
     this.createdDate,
     this.lastModifiedDate,
  });
}

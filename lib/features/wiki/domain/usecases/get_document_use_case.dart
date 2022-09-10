import 'dart:convert' show base64, utf8;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grimoire/core/usecases/usecase.dart';
import 'package:grimoire/features/wiki/domain/entities/document_entity.dart';
import 'package:grimoire/features/wiki/domain/entities/file_tree_entity.dart';
import 'package:grimoire/features/wiki/domain/entities/section_entity.dart';
import 'package:grimoire/features/wiki/domain/repositories/search_repository.dart';
import 'package:grimoire/features/wiki/domain/repositories/wiki_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDocumentUseCase extends UseCase<DocumentEntity, FileTreeEntity> {
  GetDocumentUseCase(this._wikiRepository, this._searchRepository);

  final WikiRepository _wikiRepository;
  final SearchRepository _searchRepository;

  @override
  Future<DocumentEntity> useCase(FileTreeEntity params) async {
    if (params.type == 'tree') params.path += '/README.md';
    params.path = params.path.replaceAll('/', '%2F');
    params.path = params.path.replaceAll('.', '%2E');

    DocumentEntity document;
    try {
      document = await _wikiRepository.getDocument(params.id, params.path);
      var contentCodeUnits = base64.decode(document.content);
      String decodedContent = utf8.decode(contentCodeUnits);
      document.content = decodedContent;
      document.sections = _parseDocumentSections(decodedContent);
      try {
        await _searchRepository.addDocument(document);
      } catch (e) {
        print(e);
      }
      if (kDebugMode) {
        print('indexing done');
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 404 &&
          (e.response?.data.toString().contains('File Not Found') ?? false)) {
        print('error message : ${e.message}');

        document = _defaultDocument(params);
      } else {
        rethrow;
      }
    }

    return document;
  }

  List<SectionEntity> _parseDocumentSections(String? content) {
    var sections = List<SectionEntity>.empty(growable: true);
    if (content != null) {
      var contents = content.split('\n');
      for (var section in contents) {
        if (section.startsWith('#')) {
          var attr = section.lastIndexOf('#') + 1;
          var trimSection = section.replaceAll('#', '').trim();
          sections.add(SectionEntity(attr: '$attr', label: trimSection));
        }
      }
    }

    return sections;
  }

  DocumentEntity _defaultDocument(FileTreeEntity params) {
    params.path = params.path.replaceAll('%2F', '/');
    params.path = params.path.replaceAll('%2E', '.');
    return DocumentEntity(
        fileName: 'README.md',
        filePath: params.path,
        size: -1,
        content: _generateDefaultContent(params),
        contentSha256: "content",
        blobId: "",
        commitId: "",
        executeFilemode: false);
  }

  String _generateDefaultContent(FileTreeEntity params) {
    return '# ${params.name}\n'
        '${params.children.toString()}';
  }
}

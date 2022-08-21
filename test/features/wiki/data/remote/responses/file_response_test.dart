import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimoire/features/wiki/data/sources/remote/responses/file_response.dart';

import '../../../../../data/get_string.dart';

void main() {
  test('fromJson toJson test', () {
    String apiResponseString = getString('file_response.json');
    var json = jsonDecode(apiResponseString);
    var result = FileResponse.fromJson(json);
    var expected =
        '{file_name: key.rb, file_path: app/models/key.rb, size: 1476, encoding: base64, content: IyA9PSBTY2hlbWEgSW5mb3..., content_sha256: 4c294617b60715c1d218e61164a3abd4808a4284cbc30e6728a01ad9aada4481, ref: master, blob_id: 79f7bbd25901e8334750839545a9bd021f0e4c83, commit_id: d5a3ff139356ce33e37e73add446f16869741b50, last_commit_id: 570e7b2abdd848b95f2f578043fc23bd6f6fd24d, execute_filemode: false}';
    expect(result.toJson().toString(), expected);
  });
}

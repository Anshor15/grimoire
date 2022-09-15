import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grimoire/features/wiki/presentation/models/section.dart';

import 'package:grimoire/features/wiki/presentation/widgets/breadcrumb_widget.dart';
import 'package:grimoire/features/wiki/presentation/widgets/search_item_widget.dart';

import 'package:grimoire/core/models/resource.dart';

import 'package:grimoire/features/wiki/presentation/widgets/loading_widget.dart';
import 'package:grimoire/features/wiki/presentation/widgets/resource_error_widget.dart';
import 'package:grimoire/features/wiki/presentation/widgets/search_bar_widget.dart';
import 'package:grimoire/features/wiki/presentation/widgets/file_tree_widget.dart';
import 'package:grimoire/features/wiki/presentation/controllers/document_controller.dart';
import 'package:grimoire/features/wiki/presentation/widgets/section_widget_v2.dart';

import '../controllers/file_tree_controller.dart';
import '../controllers/keyboard_controller.dart';
import '../models/file_tree_model.dart';

import '../widgets/app_search_widget.dart';
import '../widgets/document_widget.dart';
import '../widgets/section_widget.dart';
import '../widgets/version_widget.dart';

class ExplorerPage extends StatelessWidget {
  final _keyboardController = Get.put(KeyboardController());
  final DocumentController _documentController = Get.find();
  final FileTreeController _treeController = Get.find();

  ExplorerPage({Key? key}) : super(key: key) {
    _treeController.state.value = Resource<List<FileTreeModel>>.initial(
        'page init',
        data: _treeController.state.value.data);
    _treeController.getHomeDocument();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: RawKeyboardListener(
          autofocus: true,
          focusNode: _keyboardController.focusNode,
          onKey: _keyboardController.onKeyEvent,
          child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Grimoire',
                  style: TextStyle(color: Color(0xFF1c1e21)),
                ),
                toolbarHeight: 48,
                backgroundColor: const Color(0xFFfafafa),
                iconTheme: const IconThemeData(color: Color(0xFF1c1e21)),
                actions: [
                  AppBarSearchWidget(
                    onTap: () => _keyboardController.showSearchBar(),
                  ),
                  const Icon(Icons.help),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://secure.gravatar.com/avatar/018afd3eb4d4dcb676df54b56db7c80e?s=64&d=identicon',
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  buildContent(context),
                  Obx(() {
                    return SearchBarWidget(
                      controller: _keyboardController.searchBarController,
                      onFocusChanged: (isFocus) {
                        if (!isFocus) {
                          _keyboardController.hideSearchBar();
                        }
                      },
                      onQueryChanged: _documentController.onQueryChanged,
                      itemList: <Widget>[
                        if (_documentController.searchData.value.status ==
                            Status.completed)
                          for (int index = 0;
                              index <
                                  _documentController
                                      .searchData.value.data!.length;
                              index++)
                            SearchItemWidget(
                                searchModel: _documentController
                                    .searchData.value.data![index],
                                onTap: () {
                                  _keyboardController.hideSearchBar();
                                  _documentController.onSearchResultTap(index);
                                }),
                      ],
                    );
                  })
                ],
              ))),
    );
  }

  Widget buildContent(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isPortrait)
          panelContainer(context,
              childWidget: Column(
                children: [
                  Expanded(
                      child: FileTreeWidget(
                    fileTreeModels: _treeController.state.value.data ?? [],
                    onTap: _documentController.getDocument,
                  ))
                ],
              )),
        Obx(() {
          switch (_documentController.data.value.status) {
            case Status.loading:
              return Expanded(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: const LoadingWidget(),
              ));
            case Status.initial:
            case Status.completed:
              return Expanded(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                        child: BreadcrumbWidget(
                          path: _documentController.data.value.data?.filePath ??
                              "",
                          onPressed: (String label) {
                            var model = FileTreeModel(
                                id: '', name: '', type: 'tree', path: label);
                            _documentController.getDocument(
                                _treeController.findReference(model) ?? model);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: VersionWidget(
                          author: _documentController
                                  .data.value.data?.versionModel?.authorName ??
                              '',
                          lastModifiedDate: _documentController.data.value.data
                                  ?.versionModel?.committedDate ??
                              '',
                        ),
                      ),
                      if (isPortrait)
                        SectionWidgetV2(
                          sections:
                              _documentController.data.value.data?.sections ??
                                  [],
                          onTap: _documentController.onSectionClick,
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: documentWidget(
                            context: context,
                            htmlContent:
                                _documentController.data.value.data?.content,
                            onSectionRender: (label, key, attr) =>
                                _documentController.documentWidgetSections.add(
                                    Section(
                                        id: '${label.hashCode}',
                                        attr: attr,
                                        label: label,
                                        sectionKey: key)),
                            onReferenceTap: (content) {
                              _documentController.getDocument(content.id.isEmpty
                                  ? _treeController.findReference(content) ??
                                      content
                                  : content);
                            },
                            onAnchorTap: (text, renderContext, map, element) {
                              print('anchor tap : $text');
                              _documentController.redirect(
                                  text ?? '',
                                  map['href'],
                                  _treeController.state.value.data!);
                            },
                            imageProvider: (imageSource) {
                              print('imageSource : $imageSource');
                              return _documentController.getImage(
                                  _documentController
                                          .data.value.data?.filePath ??
                                      '',
                                  imageSource ?? '');
                            }),
                      ),
                    ],
                  ),
                ),
              ));
            case Status.error:
              print('response : error :');
              return Expanded(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ResourceErrorWidget(
                    errorCode: _documentController.data.value.errorCode,
                    errorMessage: _documentController.data.value.message),
              ));
          }
        }),
        if (!isPortrait)
          Obx(() {
            return SectionWidget(
              onTap: _documentController.onSectionClick,
              sections: _documentController.data.value.data?.sections ?? [],
            );
          })
      ],
    );
  }

  Widget panelContainer(BuildContext context, {required Widget childWidget}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(width: 1.0, color: Colors.grey),
        ),
      ),
      constraints: const BoxConstraints(minWidth: 100, minHeight: 100),
      child: childWidget,
    );
  }
}

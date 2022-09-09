import 'package:flutter/material.dart';
import 'package:grimoire/features/wiki/presentation/models/file_tree_model.dart';

class FileTreeWidget extends StatelessWidget {
  const FileTreeWidget({Key? key, required this.fileTreeModels, this.onTap})
      : super(key: key);

  final List<FileTreeModel> fileTreeModels;
  final void Function(FileTreeModel fileTreeModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          for (var fileTree in fileTreeModels) fileTree.toExpansionTile(onTap)
        ],
      ),
    );
  }
}

extension FileTreeToExpansion on FileTreeModel {
  Widget toExpansionTile(void Function(FileTreeModel fileTreeModel)? onTap) {
    return children.isNotEmpty
        ? ExpansionTile(
            initiallyExpanded: true,
            trailing: const SizedBox.shrink(),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            onExpansionChanged: (isExpanded) {},
            title: Text(
              name,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            children: children.map((e) => e.toExpansionTile(onTap)).toList(),
          )
        : ListTile(
            title: Text(name),
            onTap: onTap == null ? null : () => onTap(this),
          );
  }
}

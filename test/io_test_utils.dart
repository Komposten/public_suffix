import 'dart:io';

Uri getSuffixListFileUri() {
  var path = Directory('test/res').absolute;
  return Uri.file('${path.path}/public_suffix_list.dat');
}

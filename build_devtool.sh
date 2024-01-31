pushd packages/state_watcher
rm -rf extension/devtools/build
mkdir extension/devtools/build
popd

pushd packages/state_watcher_devtools_extension
flutter pub get &&
dart run devtools_extensions build_and_copy --source=. --dest=../state_watcher/extension/devtools
popd

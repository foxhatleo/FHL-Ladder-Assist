class AppEntry {
  final String packageName;
  final String friendlyName;
  final int latestVersionCode;
  final String updatePath;

  AppEntry(
    this.friendlyName,
    this.packageName,
    this.latestVersionCode,
    this.updatePath,
  );
}

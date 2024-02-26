class AppEntry {
  final String packageName;
  final String friendlyName;
  final int latestVersion;
  final String updatePath;

  AppEntry(
    this.friendlyName,
    this.packageName,
    this.latestVersion,
    this.updatePath,
  );
}

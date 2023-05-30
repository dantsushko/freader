final List<FReaderStorage> storages = [
  GoogleDriveStorage(),
  ICloudStorage(),
  LocalStorage(),
];

interface class FReaderStorage {
  String get  name => throw UnimplementedError();
   String get route => throw UnimplementedError();
  void connect() {
    print('Connect to storage');
  }
}

class GoogleDriveStorage implements FReaderStorage {

  @override
  void connect() {
    print('Connect to Google Drive');
  }
  
  @override
  String get name => 'Google Drive';
  @override
  String get route => 'gdrive-settings';
}

class ICloudStorage implements FReaderStorage {
    @override
  String get name => 'iCloud Drive';
  @override
  String get route => 'icloud-settings';
  @override
  void connect() {
    print('Connect to Icloud');
  }
}

class LocalStorage implements FReaderStorage {
  @override
  String get name => 'Устройство';
  @override
  String get route => 'local-storage-settings';
  @override
  void connect() {
    print('Connect to Local Storage');
  }
}

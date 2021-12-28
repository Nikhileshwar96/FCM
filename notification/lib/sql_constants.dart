int sqlVersion = 1;
var notificationTableName = 'notifications';
var notificationTableCreationQuery =
    "CREATE TABLE $notificationTableName(id INTEGER PRIMARY KEY, Title TEXT, Date TEXT, Time TEXT)";

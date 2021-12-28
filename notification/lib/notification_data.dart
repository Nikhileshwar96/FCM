class NotificationData{
   String title = "";
   String date = "";
   String time = "";

   NotificationData(this.title, this.date, this.time);

  NotificationData.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    date = json['Date'];
    time = json['Time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Title'] = title;
    data['Date'] = date;
    data['Time'] = time;
    data['id'] = null;
    return data;
  }
}
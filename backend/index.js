const express = require('express');

const admin = require("firebase-admin");

const app = express();

app.listen('4000', async ()=>{
    console.log("Server listening at http://localhost:4000");
    var serviceAccount = require("./firebaseNotificationKey.json");
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://fir-test-f3ae9.firebaseio.com"
      });
});

app.get('/', function (req, res){
    res.send("Visit http://localhost:4000/PushNotification for sending push notification to FCM");
console.log('Hi there');
});

app.get('/PushNotification', async function  (req, res)
{
    const count= req.query['notification_count'];
    const title= req.query['title'];
    const now = new Date();
    const dateStrings = now.toLocaleString().split(', ');
    var resp = await admin.messaging().sendToTopic(
        "Test",
        {
            data: {
              title: `${title} ${count}`,
              date:  dateStrings[0],
              time:  dateStrings[1],
            },
            notification: {
                title: `${title} ${count}`,
                body: "Data triggered from web API localy",
            },
        },
        {
            contentAvailable: true,
            priority: "high",
        });

    res.send(`message sent successfully ${resp.messageId}`);
});

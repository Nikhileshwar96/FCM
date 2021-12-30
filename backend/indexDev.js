const express = require('express');

const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');

const admin = require("firebase-admin");
const serviceAccount = require("./firebaseDevKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://fir-test-f3ae9.firebaseio.com"
  });
const db = getFirestore();
const docRef = db.collection('devices');
const app = express();

app.listen('5000', async ()=>{
    console.log("Server listening at http://localhost:4000");
});

app.get('/', async function (req, res) {
    res.send("Visit http://localhost:4000/PushNotification for sending push notification to FCM");
});

app.get('/PushNotification', async function  (req, res)
{
    var deviceList = await docRef.get();
    var tokens = [];
    deviceList.forEach(element => {
        data = element.data();
        tokens.push(data.deviceID);
    });
    
    const count= req.query['notification_count'];
    const title= req.query['title'];
    const now = new Date();
    const dateStrings = now.toLocaleString().split(', ');
    var resp = await admin.messaging().sendToDevice(
        tokens,
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

    res.send(`message sent successfully for ${resp.successCount} and failed for ${resp.failureCount}`);
});

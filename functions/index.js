const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.sendMatchNotification = functions.database.ref('/users/{uid}/matches/{matchUid}')
    .onWrite((change, context) => {
      const uid = context.params.uid;
      const matchUid = context.params.matchUid;
      var match = '';
      console.log('We have a new match UID:', matchUid, 'for user:', uid);

	  const getMatchPromise = admin.database().ref('/users/{uid}/matches/{matchUid}').once('value');
        

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/users/${uid}/fcmToken`).once('value');

      // Get the match profile.
      //const getMatchProfilePromise = admin.auth().getUser(matchUid);

      // The snapshot to the user's tokens.
      let tokensSnapshot;

      // The array containing all the user's tokens.
      let tokens;

      return Promise.all([getDeviceTokensPromise, getMatchPromise]).then(results => {
        tokensSnapshot = results[0];
		match = results[1];
        // Check if there are any device tokens.
        if (!tokensSnapshot.hasChildren()) {
          return console.log('There are no notification tokens to send to.');
        }
        console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
        console.log('Fetched match profile', match);

        // Notification details.
        const payload = {
          notification: {
            title: 'You have a new match!',
            body: `Go chat with ${match.firstName} now!`,
            badge: '1',
            sound: 'default',
          }
        };

        // Listing all tokens as an array.
        tokens = Object.keys(tokensSnapshot.val());
        // Send notifications to all tokens.
        return admin.messaging().sendToDevice(tokens, payload);
      }).then((response) => {
        // For each message check if there was an error.
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.error('Failure sending notification to', tokens[index], error);
            // Cleanup the tokens who are not registered anymore.
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
              tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
            }
          }
        });
        return Promise.all(tokensToRemove);
      });
    });

exports.sendChatNotification = functions.database.ref('/users/{uid}/chats/{matchUid}/{messageId}').onWrite((change, context) => {
  const uid = context.params.uid;
  const matchUid = context.params.matchUid;
  const messageId = context.params.matchUid;
  var match = '';
  var message = '';
  console.log('We have a new message from:', matchUid, 'for user:', uid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database()
      .ref(`/users/${uid}/fcmToken`).once('value');

  // Get the match profile.
  const getMatchProfilePromise = admin.database().ref('/users/{matchUid}').once('value');
  const getMessage = admin.database().ref('/users/{uid}/chats/{matchUid}/{messageId}').once('value');
  // The snapshot to the user's tokens.
  let tokensSnapshot;

  // The array containing all the user's tokens.
  let tokens;

  return Promise.all([getDeviceTokensPromise, getMatchProfilePromise, getMessage]).then(results => {
    tokensSnapshot = results[0];
    match = results[1];
    message = results[2];
    // Check if there are any device tokens.
    if (!tokensSnapshot.hasChildren()) {
      return console.log('There are no notification tokens to send to.');
    }
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');

    // Notification details.
    const payload = {
      notification: {
        title: `${match.firstName} ${match.lastName}`,
        body: message.text,
        badge: '1',
        sound: 'default',
      }
    };

    // Listing all tokens as an array.
    tokens = Object.keys(tokensSnapshot.val());
    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload);
  }).then((response) => {
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error('Failure sending notification to', tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);
  });
});

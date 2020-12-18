// import ballerina/log;
// import ballerina/websub;
// import ballerina/io;
// import ballerinax/twilio;
// import ballerina/config;
// import azure_devops_websub.webhook;

// twilio:TwilioConfiguration twilioConfig = {
//     accountSId: config:getAsString("accountSId"),
//     authToken: config:getAsString("authToken"),
//     xAuthyKey: config:getAsString("xAuthyKey")
// };
// twilio:Client twilioClient = new(twilioConfig);

// listener webhook:WebhookListener webhookListener = new(9090);

// @websub:SubscriberServiceConfig {
//     path: "/webhook",
//     subscribeOnStartUp: false
// }
// service websub:SubscriberService /webhook on webhookListener {

//     resource function onBuildCompleted(websub:Notification notification, webhook:Response item) {
//         log:printInfo("Build Completed");
//         string fromMobile = "+19079173951";
//         string toMobile = "+94761111111";
//         string message = item.message.text;

//         var details = twilioClient->sendSms(fromMobile, toMobile, message);
//         if (details is twilio:SmsResponse) {
//             io:println(details);
//         } else {
//             io:println(details);
//         }
//         log:printInfo(item);
//     }
// }

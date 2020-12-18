# Construcuts json requires to subscribe to Work Items
# 
# + project - The project which contains the builds
# + event - The event that should trigger the webhook
# + webhookUrl - The url of the webhook endpoint
# + return - subscription json
isolated function getWorkItemSubscriptionJson(ProjectEntry project, WorkItemEvent event, string webhookUrl) returns json {
    json publisherInputs = {
        projectId: project.id
    };
    map<json> publisherInput = <map<json>>publisherInputs;

    if (event?.'type is WorkItemType) {
        publisherInput["workItemType"] = event?.'type;
    }

    if (event?.areaPath is string) {
        publisherInput["areaPath"] = event?.areaPath;
    }

    return constructSubscriptionJson(publisherInput, event.action, webhookUrl);
}

# Construcuts json requires to subscribe to Azure Builds
# 
# + project - The project which contains the builds
# + event - The event that should trigger the webhook
# + webhookUrl - The url of the webhook endpoint
# + return - subscription json
isolated function getBuildSubscriptionJson(ProjectEntry project, BuildEvent event, string webhookUrl) returns json {
    json publisherInputs = {
        projectId: project.id
    };
    map<json> publisherInput = <map<json>>publisherInputs;

    if (event?.status is BUILD_STATUS) {
        publisherInput["buildStatus"] = event?.status;
    }

    if (event?.definitionName is string) {
        publisherInput["definitionName"] = event?.definitionName;
    }

    return constructSubscriptionJson(publisherInput, "build.complete", webhookUrl);
}

# Construcuts json according to the publisher input 
# 
# + publisherInput - publisher input json according the event
# + event - The event that should trigger the webhook
# + webhookUrl - The url of the webhook endpoint
# + return - subscription json
isolated function constructSubscriptionJson(json publisherInput, string event, string webhookUrl) returns json {

    json subscription = {
        publisherId : "tfs",
        eventType : event,
        resourceVersion: "1.0",
        consumerId: "webHooks",
        consumerActionId: "httpRequest",
        publisherInputs: publisherInput,  
        consumerInputs: {
            url : webhookUrl
        }
    };
    return subscription;
}
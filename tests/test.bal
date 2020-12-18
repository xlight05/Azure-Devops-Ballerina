import ballerina/test;
import ballerina/websub;
import azure_devops_websub.webhook;
import ballerina/runtime;
import ballerina/system;
import ballerina/config;

AccessToken accessToken = {
    accessToken : getConfigValue("accessToken")
};

DevOpsConfiguration devopsConfig = {
    accessToken: accessToken,
    org: getConfigValue("org")
};
 
Client azureClient = new (devopsConfig);

ProjectEntry project = {
    id : "",
    name : "",
    url : "",
    state : "",
    revision: 0,
    visibility: "",
    lastUpdateTime : ""
};

boolean isWorkItemCreated = false;
string eventType = "";

@test:Config {}
function testGetProjects() {
    ProjectEntry[]|error projects = azureClient->getProjects();
    if (projects is error) {
        test:assertFail(msg = projects.message());
    } else {
        project = <@untainted> projects[0];
    }
}

@test:Config {
    dependsOn: ["testGetProjects"]
}
function testSubscribeToWorkItem() {
    WorkItemEvent subscribeConfig = {
        action : CREATED
    };

    string redirectUrl = getConfigValue("redirectUrl");
    error? err = azureClient->subscribeToWorkItem(project, subscribeConfig, redirectUrl);
    if (err is error) {
        test:assertFail(msg = err.message());
    }
}

@test:Config {
    dependsOn: ["testGetProjects"]
}
function testCreateWorkItem() {
    error? err = azureClient->createWorkItem(project, "Test Samplezz");
    if (err is error) {
        test:assertFail(msg = err.message());
    }
}

listener webhook:WebhookListener webhookListener = new(9090);

@websub:SubscriberServiceConfig {
    subscribeOnStartUp: false
}
service websub:SubscriberService /webhook on webhookListener {
    remote function onWorkItemCreated(websub:Notification notification, webhook:Response item) {
        isWorkItemCreated = true;
        eventType = item.eventType;
    }
}

@test:Config {
    dependsOn: ["testCreateWorkItem"]
}
function testOnWorkItemCreated() {
    int counter = 20;
    while (!isWorkItemCreated && counter >= 0) {
        runtime:sleep(1000);
        counter -= 1;
    }
    test:assertTrue(isWorkItemCreated,
                 msg = "expected a webhook call upon t he work item creation");
    test:assertEquals(eventType, "workitem.created", msg = "expected the event type from work item creation");
}

function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
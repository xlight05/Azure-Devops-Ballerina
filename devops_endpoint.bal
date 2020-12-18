// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
// import ballerina/io;

# Represents the Azure Devops Client Connector Endpoint configuration.
# 
# + clientConfig - HTTP client endpoint configuration
# + accessToken - The access token of the account
# + org - Organization name
# + project - Project name
public type DevOpsConfiguration record {
    http:ClientConfiguration clientConfig = {};
    AccessToken | PATToken accessToken;
    string org;
    string project?;
};

public type AccessToken record {|
    string accessToken;
|};

public type PATToken record {|
    string patToken;
|};

# Azure Devops Client object.
# 
# + accessToken - The access token of the github account
# + devopsClient - HTTP client endpoint
# + org - Organization name
public client class Client {

    string accessToken;
    http:Client devopsClient;
    string org;

    public function init(DevOpsConfiguration devopsConfig) {
        AccessToken|PATToken token = devopsConfig.accessToken;
        if (token is AccessToken) {
            self.accessToken = token.accessToken;
        } else {
            self.accessToken = token.patToken.toBytes().toBase64();
        }
        self.org = devopsConfig.org;
        self.devopsClient = new("https://dev.azure.com/" + self.org, devopsConfig.clientConfig);
    }
    
    # Get All projects of the account
    # 
    # + return - List of Projects on success else error
    remote function getProjects() returns @tainted ProjectEntry[]|error {
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);
        var response = self.devopsClient->get("/_apis/projects?api-version=5.0",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        ApiResponse project = check projectJson.cloneWithType(ApiResponse);
        ProjectEntry[]|PipelineEntry[] value = <@untainted> project.value;
        if (value is ProjectEntry[]) {
            return value;
        } else {
            return error("Unxpected Payload recieved");
        }
    }

    # Get all work items of the project
    # 
    # + project - The project which contains the work items
    # + return - List of Work itmes on success else error
    remote function getWorkItems(ProjectEntry project) returns @tainted WorkItemEntry[]|error {
        string projectName = project.name;
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);
        //https://docs.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax?toc=%2Fvsts%2Fwork%2Ftrack%2Ftoc.json&bc=%2Fvsts%2Fwork%2Ftrack%2Fbreadcrumb%2Ftoc.json&view=azure-devops&viewFallbackFrom=azure-devops-rest-5.0
        json query = {"query": "Select [System.Id], [System.Title], [System.State] From WorkItems"};
        request.setJsonPayload(query);
        var response = self.devopsClient->post("/"+projectName+"/_apis/wit/wiql?api-version=5.1",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        WorkItemResponse workItems = check projectJson.cloneWithType(WorkItemResponse);
        return  <@untainted> workItems.workItems;
    }

    # Get all builds of the project
    # 
    # + project - The project which contains the builds
    # + return - List of Builds on success else error
    remote function getBuilds(ProjectEntry project) returns @tainted PipelineEntry[]|error {
        string projectName = project.name;
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);
        var response = self.devopsClient->get("/"+projectName+"/_apis/build/builds?api-version=6.1-preview.6",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        ApiResponse apiResponse = check projectJson.cloneWithType(ApiResponse);
        ProjectEntry[]|PipelineEntry[] value = <@untainted> apiResponse.value;
        if (value is PipelineEntry[]) {
            return value;
        } else {
            return error("Unxpected Payload recieved");
        }
    }

    # Create a work item.
    # 
    # + project - The project which contains the builds
    # + title - The name of the work item
    # + return - error if the work item creation failed
    remote function createWorkItem(ProjectEntry project, string title) returns @tainted error? {
        string projectName = project.name;
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);
        json body = [
            {
                "op": "add",
                "path": "/fields/System.Title",
                "from": null,
                "value": title
            }
        ];
        request.setJsonPayload(body);
        request.setHeader("Content-type","application/json-patch+json");
        var response = self.devopsClient->post("/"+projectName+"/_apis/wit/workitems/$task?api-version=6.1-preview.3",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        // io:println (projectJson);
    }

    # Register a Webhook progamatically for Work Item action
    # 
    # + project - The project which contains the builds
    # + event - The event that should trigger the webhook
    # + webhookUrl - The url of the webhook endpoint
    # + return - error if the subscription failed
    remote function subscribeToWorkItem(ProjectEntry project, WorkItemEvent event, string webhookUrl) returns @tainted error? {
        string projectName = project.name;
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);

        json subscription = getWorkItemSubscriptionJson(project,event,webhookUrl);
        request.setJsonPayload(subscription);
        var response = self.devopsClient->post("/_apis/hooks/subscriptions?api-version=5.0",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        SubscriptionResponse|error subRes = projectJson.cloneWithType(SubscriptionResponse);
        if (subRes is error) {
            return subRes;
        }
    }

    # Register a Webhook progamatically for Build action
    # 
    # + project - The project which contains the builds
    # + event - The event that should trigger the webhook
    # + webhookUrl - The url of the webhook endpoint
    # + return - error if the subscription failed
    remote function subscribeToBuild(ProjectEntry project, BuildEvent event, string webhookUrl) returns @tainted error? {
        string projectName = project.name;
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);

        json subscription = getBuildSubscriptionJson(project,event,webhookUrl);
        request.setJsonPayload(subscription);
        var response = self.devopsClient->post("/_apis/hooks/subscriptions?api-version=5.0",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        // io:println(projectJson);
        SubscriptionResponse|error subRes = projectJson.cloneWithType(SubscriptionResponse);
        if (subRes is error) {
            return subRes;
        }
    }

    # Register a Webhook progamatically for Work Item action
    # 
    # + project - The project which contains the builds
    # + event - The event that should trigger the webhook
    # + webhookUrl - The url of the webhook endpoint
    # + return - error if the subscription failed
    remote function subscribeToRelease(ProjectEntry project, BuildEvent event, string webhookUrl) returns @tainted error? {
        string projectName = project.name;
        http:Request request = new;
        request.setHeader("Authorization","Bearer " + self.accessToken);

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
        json subscription = {
            publisherId : "tfs",
            eventType : "build.complete",
            resourceVersion: "1.0",
            consumerId: "webHooks",
            consumerActionId: "httpRequest",
            publisherInputs: publisherInput,
            consumerInputs: {
                url : webhookUrl
            }
        };
        request.setJsonPayload(subscription);
        var response = self.devopsClient->post("/_apis/hooks/subscriptions?api-version=5.0",request);
        if (response is error) {
            return  <@untainted> response;
        }
        http:Response responseResult = <http:Response> response;
        json projectJson = check responseResult.getJsonPayload();
        // io:println(projectJson);
        SubscriptionResponse|error subRes = projectJson.cloneWithType(SubscriptionResponse);
        if (subRes is error) {
            return subRes;
        }
    }
}

public type ReleaseItemEvent record {|
    string areaPath?;
    ReleaseItemAction action;
    WorkItemType 'type?;
|};

public enum ReleaseItemAction {
    RELEASE_CREATED = "ms.vss-release.release-created-event",
    RELEASE_ABANDONED = "ms.vss-release.release-abandoned-event",
    DEPLOYMENT_APPROVAL_COMPLETED = "ms.vss-release.deployment-approval-completed-event",
    DEPLOYMENT_APPROVAL_PENDING = "ms.vss-release.deployment-approval-pending-event",
    DEPLOYMENT_COMPLETED = "ms.vss-release.deployment-completed-event",
    DEPLOYMENT_STARTED = "ms.vss-release.deployment-started-event"
}

public type BuildEvent record {
    string definitionName?;
    BUILD_STATUS status?;
};

const string ANY  = "";

public enum BUILD_STATUS {
    SUCCEEDED = "Succeeded",
    FAILED = "Failed",
    STOPPED = "Stopped",
    PARTIALLY_SUCCEEDED = "PartiallySucceeded"
}

public type WorkItemEvent record {|
    string areaPath?;
    WorkItemAction action;
    WorkItemType 'type?;
|};

public enum WorkItemType {
    EPIC = "Epic",
    ISSUE = "Issue",
    TASK = "Task"
}

public enum WorkItemAction {
    CREATED = "workitem.created",
    DELETED = "workitem.deleted",
    UPDATED = "workitem.updated",
    RESTORED = "workitem.restored"
}
// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/websub;

public class WebhookListener {

    public WebhookListenerConfiguration? webhookListenerConfig = ();

    private websub:Listener websubListener;

    public function init(int port, WebhookListenerConfiguration? config = ()) {
        self.webhookListenerConfig = config;

        websub:ExtensionConfig extensionConfig = {
            topicIdentifier: websub:TOPIC_ID_PAYLOAD_KEY,
            payloadKeyResourceMap: DEVOPS_RESOURCE_MAP
        };
        websub:SubscriberListenerConfiguration slConfig = {
            extensionConfig: extensionConfig
        };
        if (config is WebhookListenerConfiguration) {
            string? specHost = config["host"];
            if (specHost is string) {
                slConfig.host = specHost;
            }
            slConfig.httpServiceSecureSocket = config["httpServiceSecureSocket"];
        }
        self.websubListener = new (port, slConfig);
    }

    public function attach(service object {} s, string[]|string? name = ()) returns error? {
        return self.websubListener.attach(s, name);
    }

    public function detach(service object {} s) returns error? {
        return self.websubListener.detach(s);
    }

    public function 'start() returns error? {
        return self.websubListener.'start();
    }

    public function gracefulStop() returns error? {
        return self.websubListener.gracefulStop();
    }

    public function immediateStop() returns error? {
        return self.websubListener.immediateStop();
    }
}


# Record representing the configuration for the GitHub Webhook Listener.
#
# + host - The host name/IP of the listener
# + httpServiceSecureSocket - The SSL configurations for the listener
public type WebhookListenerConfiguration record {|
    string host?;
    http:ListenerSecureSocket httpServiceSecureSocket?;
|};

final map<map<[string, typedesc<record {}>]>> DEVOPS_RESOURCE_MAP = {
    "eventType": {
        "workitem.created": ["onWorkItemCreated", Response],
        "workitem.deleted": ["onWorkItemDeleted", Response],
        "build.complete": ["onBuildCompleted", Response],
        "ms.vss-release.release-created-event": ["onReleaseCreated", Response],
        "ms.vss-release.release-abandoned-event": ["onReleaseAbandoned", Response],
        "ms.vss-release.deployment-approval-completed-event": ["onReleaseDeploymentApprovalComplete", Response],
        "ms.vss-release.deployment-approval-pending-event": ["onReleaseDeploymentApprovalPending", Response],
        "ms.vss-release.deployment-completed-event": ["onReleaseDeploymentCompleted", Response],
        "ms.vss-release.deployment-started-event": ["onReleaseDeploymentStarted", Response]
    }
};

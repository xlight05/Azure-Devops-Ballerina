public type ApiResponse record {
    int count;
    ProjectEntry[]|PipelineEntry[] value;
};

public type PipelineEntry record {
    Links _links;
    NotKnown? properties;
    NotKnown[]? tags;
    NotKnown[]? validationResults;
    Plan[] plans;
    TriggerInfo triggerInfo;
    int id;
    string buildNumber;
    string status;
    string result;
    string queueTime;
    string startTime;
    string finishTime;
    string url;
    PipelineDefinition definition;
    int buildNumberRevision;
    ProjectEntry project;
    string uri;
    string sourceBranch;
    string sourceVersion;
    PipelineQueue queue;
    string priority;
    string reason;
    Person requestedFor;
    Person requestedBy;
    string lastChangedDate;
    Person lastChangedBy;
    OrchestrationPlan orchestrationPlan;
    Logs logs;
    Repository repository;
    boolean keepForever;
    boolean retainedByRelease;
    NotKnown? triggeredByBuild;
};

public type OrchestrationPlan record {
    string planId;
};

public type Logs record {
    int id;
    string 'type;
    string url;
};

public type Repository record {
    string id;
    string 'type;
    string name;
    string url;
    NotKnown? clean;
    boolean checkoutSubmodules;
};

public type PipelineQueue record {
    int id;
    string name;
    QueuePool pool;
};

public type QueuePool record {
    int id;
    string name;
    boolean isHosted;
};

public type PipelineDefinition record {
    NotKnown[] drafts;
    int id;
    string name;
    string url;
    string uri;
    string path;
    string 'type;
    string queueStatus;
    int revision;
    ProjectEntry project;


};

public type Plan record {
    string planId;
};

public type TriggerInfo record {
    // string ci.sourceBranch;
    // string ci.sourceSha;
    // string ci.message;
};

public type ProjectEntry record {
    string id;
    string name;
    string url;
    string state;
    int revision;
    string visibility;
    string lastUpdateTime;
};

public type WorkItemResponse record {
    string queryType;
    string queryResultType;
    string asOf;
    Column[] columns;
    WorkItemEntry[] workItems;
};

public type Column record {
    string referenceName;
    string name;
    string url;
};

public type WorkItemEntry record {
    int id;
    string url;
};

public type SubscriptionResponse record {
    string id;
    string url;
    string status;
    string publisherId;
    string eventType;
    Person? subscriber;
    string resourceVersion;
    string eventDescription;
    string consumerId;
    string consumerActionId;
    string actionDescription;
    Person createdBy;
    string createdDate;
    Person modifiedBy;
    string modifiedDate;
    PublisherInputs publisherInputs;
    ConsumerInputs consumerInputs;
    Links _links;
};

public type PublisherInputs record {
    string projectId;
    string tfsSubscriptionId;
    string workItemType?;
    string buildStatus?;
};

public type ConsumerInputs record {|
    string url;
|};

public type ErrorResponse record {|
    // int '$id;
    string? innerException;
    string message;
    string typeName;
    string typeKey;
    int errorCode;
    int eventId;
|};


public type Person record {
    string? displayName;
    string url?;
    string id;
    string uniqueName?;
    string imageUrl?;
    string descriptor?;
};

public type NotKnown record {

};

public type Links record {
    Reference web?;
    Reference self?;
    Reference workItemUpdates?;
    Reference workItemRevisions?;
    Reference workItemComments?;
    Reference html?;
    Reference workItemType?;
    Reference fields?;
    Reference sourceVersionDisplayUri?;
    Reference timeline?;
    Reference badge?;
    Reference consumer?;
    Reference actions?;
    Reference publisher?;
    Reference notifications?;
};

public type Reference record {
    string href;
};

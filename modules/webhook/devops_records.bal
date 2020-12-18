public type Response record {
    string subscriptionId;
    int notificationId;
    string id;
    string eventType;
    string publisherId;
    Message message;
    Message detailedMessage;
    ResourceContainers resourceContainers;
    ReleaseResource | BuildResource | WorkItemResource 'resource;
    string resourceVersion;
    string createdDate;
};

public type Message record {
    string text;
    string html;
    string markdown;
};

public type ResourceContainers record {
    Container collection;
    Container account;
    Container project?;
};

public type Container record {
    string id;
    string baseUrl?;
};

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


//Build Records
public type BuildResource record {
    string uri;
    int id;
    string buildNumber;
    string url;
    string startTime;
    string finishTime;
    string reason;
    string status;
    string dropLocation?;
    Drop drop;
    Log log;
    string sourceGetVersion;
    Person lastChangedBy;
    boolean retainIndefinitely;
    boolean hasDiagnostics?;
};

public type Drop record {
    string location?;
    string 'type?;
    string url?;
    string downloadUrl?;
};

public type Log record {
    string 'type?;
    string url?;
    string downloadUrl?;
};


public type Definition record {
    int batchSize?;
    string triggerType?;
    string definitionType;
    int id;
    string name;
    string url;
};

public type Queue record {
    string queueType;
    int id;
    string name;
    string url;
    Request[] requests;
};

public type Request record {
    int id;
    string url;
    Person requestedFor;
};


// WorkItem Records
public type WorkItemResource record {
    int id;  //works when this is commented
    int rev; //works when this is commented
    Fields fields; //issue
    Links _links;
    string url; //works when this is commented
};

public type Fields record {
    string 'System\.AreaPath;
    string 'System\.TeamProject;
    string 'System\.IterationPath;
    string 'System\.WorkItemType;
    string 'System\.State;
    string 'System\.Reason;
    string 'System\.CreatedDate;
    Person|string 'System\.CreatedBy;
    string 'System\.ChangedDate;
    Person|string 'System\.ChangedBy;
//    int 'System\.CommentCount?;
    string 'System\.Title;
//    string 'Microsoft\.VSTS\.Common\.Severity;
//    string 'System\.BoardColumn?;
//    boolean 'System\.BoardColumnDone?;
//    string 'Microsoft\.VSTS\.Common\.StateChangeDate?;
//    int 'Microsoft\.VSTS\.Common\.Priority?;
//    string 'WEF_700539256839438D82EC5D06F5270DD0_Kanban\.Column?;
//    boolean 'WEF_700539256839438D82EC5D06F5270DD0\_Kanban\.Column\.Done?;
//    string 'System\.Description?;
};

//Release records
public type ReleaseResource record {
    Release release?;
    Project project;
    Environment environment?;
    int id?;
    string? url?;
    int attemptId?;
    string? stageName?;
    string? comment?;
    NotKnown data?;
};

public type Release record {
    int id;
    string? name;
    string status;
    string createdOn;
    string modifiedOn;
    Person? modifiedBy;
    Person? createdBy;
    Person? createdFor?;
    Environment[] environments;
    NotKnown variables;
    NotKnown[] variableGroups?;
    Artifact[] artifacts;
    ReleaseDefinition releaseDefinition;
    int releaseDefinitionRevision?;
    string description?;
    string reason;
    string? releaseNameFormat;
    boolean keepForever;
    int definitionSnapshotRevision;
    string comment?;
    string? logsContainerUrl;
    string url?;
    Links _links;
    NotKnown[] tags?;
    NotKnown? triggeringArtifactAlias?;
    DefinitionEntry? projectReference?;
    ReleaseProperties properties?;

};

public type ReleaseProperties record {
    ReleaseProperty ReleaseCreationSource;
    ReleaseProperty DownloadBuildArtifactsUsingTask;
};

public type ReleaseProperty record {
    // string '\$type;
    // string '$value;
};


public type ReleaseDefinition record {
    int id;
    string name;
    string url?;
    string path?;
    Links _links?;
    NotKnown? projectReference?;
};

public type Artifact record {
    string sourceId;
    string 'type;
    string alias;
    boolean isPrimary;
    boolean isRetained?;
    DefinitionReference definitionReference;
};

public type DefinitionReference record {
    DefinitionEntry artifactSourceDefinitionUrl?;
    DefinitionEntry branches?;
    DefinitionEntry definition?;
    DefinitionEntry IsMultiDefinitionType?;
    DefinitionEntry project?;
    DefinitionEntry repository?;
    DefinitionEntry 'version?;
    DefinitionEntry artifactSourceVersionUrl?;
    DefinitionEntry branch?;
};

public type DefinitionEntry record {
    string id;
    string? name;
};

public type Environment record {
    int id;
    int releaseId;
    string name;
    string status;
    NotKnown variables;
    NotKnown[] variableGroups?;
    NotKnown[] preDeployApprovals;
    NotKnown[] postDeployApprovals;
    ApprovalsSnapshot preApprovalsSnapshot;
    ApprovalsSnapshot postApprovalsSnapshot;
    NotKnown[] deploySteps;
    int rank;
    int definitionEnvironmentId;
    int queueId?;
    EnvironmentOptions environmentOptions;
    NotKnown[] demands;
    NotKnown[] conditions;
    string modifiedOn?;
    WorkflowTask[] workflowTasks;
    DeployPhasesSnapshot[] deployPhasesSnapshot;
    Person owner;
    string scheduledDeploymentTime?;
    NotKnown[] schedules;
    ReleaseEntry release;
    ReleaseDefinition releaseDefinition?;
    Person releaseCreatedBy?;
    string triggerReason?;
    ProcessParameters processParameters?;
    Gates preDeploymentGatesSnapshot;
    Gates postDeploymentGatesSnapshot;
};


public type DeployPhasesSnapshot record {
    DeploymentInput deploymentInput;
    int rank;
    string phaseType;
    string name;
    NotKnown? refName;
    WorkflowTask[] workflowTasks;
};

public type WorkflowTask record {
    NotKnown environment?;
    string taskId;
    string 'version;
    string name;
    string refName?;
    boolean enabled;
    boolean alwaysRun;
    boolean continueOnError;
    int timeoutInMinutes;
    NotKnown? definitionType;
    NotKnown overrideInputs;
    string condition;
    FlowTaskInputs inputs;
};

public type FlowTaskInputs record {
    string ConnectionType?;
    string ConnectedServiceName?;
    string PublishProfilePath?;
    string PublishProfilePassword?;
    string WebAppKind?;
    string WebAppName?;
    string DeployToSlotOrASEFlag?;
    string ResourceGroupName?;
    string SlotName?;
    string DockerNamespace?;
    string DockerRepository?;
    string DockerImageTag?;
    string VirtualApplication?;
    string Package?;
    string RuntimeStack?;
    string RuntimeStackFunction?;
    string StartupCommand?;
    string ScriptType?;
    string InlineScript?;
    string ScriptPath?;
    string WebConfigParameters?;
    string AppSettings?;
    string ConfigurationSettings?;
    string UseWebDeploy?;
    string DeploymentType?;
    string TakeAppOfflineFlag?;
    string SetParametersFile?;
    string RemoveAdditionalFilesFlag?;
    string ExcludeFilesFromAppDataFlag?;
    string AdditionalArguments?;
    string RenameFilesFlag?;
    string XmlTransformation?;
    string XmlVariableSubstitution?;
    string JSONFiles?;
    string WebSiteName?;
    string WebSiteLocation?;
    string Slot?;
};

public type DeploymentInput record {
    ParallelExecution parallelExecution;
    AgentSpecification agentSpecification;
    boolean skipArtifactsDownload;
    ArtifactsDownloadInput artifactsDownloadInput;
    int queueId;
    NotKnown[] demands;
    boolean enableAccessToken;
    int timeoutInMinutes;
    int jobCancelTimeoutInMinutes;
    string condition;
    NotKnown overrideInputs;
};

public type ParallelExecution record {
    string parallelExecutionType;
};

public type AgentSpecification record {
    string identifier;
};

public type ArtifactsDownloadInput record {
    NotKnown[] downloadInputs;
};

public type ProcessParameters record {
    Input[] inputs;
    DataSourceBinding[] dataSourceBindings;
};

public type Input record {
    NotKnown[] aliases;
    InputOptions options;
    InputProperties properties;
    string name;
    string label;
    string defaultValue;
    boolean required?;
    string 'type;
    string helpMarkDown;
    string visibleRule?;
    string groupName;
};

public type InputOptions record {
    string webApp?;
    string webAppLinux?;
    string webAppContainer?;
    string functionApp?;
    string functionAppLinux?;
    string functionAppContainer?;
    string apiApp?;
    string mobileApp?;  
};

public type InputProperties record {
    string EditableOptions?;
};

public type DataSourceBinding record {
    string dataSourceName;
    string endpointId;
    string target;
    BindParams parameters;
};

public type BindParams record {
    string WebAppKind;
};

public type Gates record {
    int id;
    NotKnown? gatesOptions;
    NotKnown[] gates;
};

public type ReleaseEntry record {
    int id;
    string name;
    string url?;
    Links _links?;
};

public type ApprovalsSnapshot record {
    NotKnown[] approvals;
    ApprovalOptions approvalOptions?;
};

public type ApprovalOptions record {
    int requiredApproverCount;
    boolean releaseCreatorCanBeApprover;
    boolean autoTriggeredAndPreviousEnvironmentApprovedCanBeSkipped?;
    boolean enforceIdentityRevalidation?;
    int timeoutInMinutes?;
    string executionOrder?;
};

public type EnvironmentOptions record {
    string emailNotificationType;
    string emailRecipients;
    boolean skipArtifactsDownload;
    int timeoutInMinutes;
    boolean enableAccessToken;
    boolean publishDeploymentStatus?;
    boolean badgeEnabled?;
    boolean autoLinkWorkItems?;
    boolean pullRequestDeploymentEnabled?;
};

public type Project record {
    string id;
    string name;
};



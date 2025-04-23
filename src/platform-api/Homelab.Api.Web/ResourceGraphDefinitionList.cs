using System;
using System.Collections.Generic;
using k8s.Models;


public class ResourceGraphDefinitionList
{
    public string ApiVersion { get; set; }
    public List<ResourceGraphDefinition> Items { get; set; }
    public string Kind { get; set; }
    public Metadata Metadata { get; set; }
}

public class ResourceGraphDefinition
{
    public string ApiVersion { get; set; }
    public string Kind { get; set; }
    public Metadata Metadata { get; set; }
    public Spec Spec { get; set; }
    public Status Status { get; set; }
}

public class Metadata
{
    public string CreationTimestamp { get; set; }
    public List<string> Finalizers { get; set; }
    public int? Generation { get; set; }
    public Dictionary<string, string> Labels { get; set; } = new();
    public Dictionary<string, string> Annotations { get; set; } = new();
    public List<ManagedField> ManagedFields { get; set; }
    public string Name { get; set; }
    public string ResourceVersion { get; set; }
    public string Uid { get; set; }
    public string Continue { get; set; } // for list metadata
}

public class ManagedField
{
    public string ApiVersion { get; set; }
    public string FieldsType { get; set; }
    public object FieldsV1 { get; set; }
    public string Manager { get; set; }
    public string Operation { get; set; }
    public string Time { get; set; }
    public string Subresource { get; set; }
}

public class Spec
{
    public List<Resource> Resources { get; set; }
    public Schema Schema { get; set; }
}

public class Resource
{
    public string Id { get; set; }
    public object Template { get; set; }
    public List<string> IncludeWhen { get; set; }
}

public class Schema
{
    public string ApiVersion { get; set; }
    public string Group { get; set; }
    public string Kind { get; set; }
    public Dictionary<string, object> Spec { get; set; }
    public Dictionary<string, object> Status { get; set; }
}

public class Status
{
    public List<Condition> Conditions { get; set; }
    public string State { get; set; }
}

public class Condition
{
    public string LastTransitionTime { get; set; }
    public string Message { get; set; }
    public string Reason { get; set; }
    public string Status { get; set; }
    public string Type { get; set; }
}

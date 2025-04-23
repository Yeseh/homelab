using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using k8s;
using System.Linq;

using static PlatformApiMetadata;

public class PlatformClient(Kubernetes client)
{
    public async Task<List<ResourceGraphDefinition>> ListPlatformApisAsync(string apiVersion)
    {
        var rgdList = await client.CustomObjects.ListClusterCustomObjectAsync<ResourceGraphDefinitionList>(
            "kro.run", 
            apiVersion, 
            "resourcegraphdefinitions",
            labelSelector: "homelab.yeseh.nl/llm-exposed=true");

        return rgdList.Items;
    }
    
    public async Task<ResourceGraphDefinition> GetPlatformApiAsync(string apiVersion, string name)
    {
        var rgd = await client.CustomObjects.GetClusterCustomObjectAsync<ResourceGraphDefinition>(
            "kro.run", apiVersion, "resourcegraphdefinitions", name);

        return rgd;
    }
}

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using k8s;

public class PlatformClient(Kubernetes client)
{
    public async Task<List<ResourceGraphDefinition>> ListPlatformApisAsync(string apiVersion)
    {
        var rgdList = await client.CustomObjects.ListClusterCustomObjectAsync<ResourceGraphDefinitionList>(
            "kro.run", apiVersion, "resourcegraphdefinitions", labelSelector: "api-version");

        return rgdList.Items;
    }
}

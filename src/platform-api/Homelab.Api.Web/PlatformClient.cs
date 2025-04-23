using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using k8s;

public class PlatformClient(Kubernetes client)
{
    public async Task<List<ResourceGraphDefinition>> ListPlatformApisAsync()
    {
        var rgdList = await client.CustomObjects.ListClusterCustomObjectAsync<ResourceGraphDefinitionList>(
            "kro.run", "v1alpha1", "resourcegraphdefinitions");

        rgdList.Items.ForEach(rgd =>
        {
            Console.WriteLine(rgd.Metadata.Name);
        });

        return rgdList.Items;
    }
}

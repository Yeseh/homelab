using Microsoft.AspNetCore.Builder;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using k8s;
using System;
using Microsoft.AspNetCore.Http.HttpResults;
using System.Collections.Generic;

public static class ListPlatformApis
{
    public static WebApplication MapListPlatformApis(this WebApplication app)
    {
        app.MapGet("/api/platform-apis", ExecuteAsync);
        return app;
    }

    private static async Task<Ok<List<ResourceGraphDefinition>>> ExecuteAsync()
    {
        var config = KubernetesClientConfiguration.BuildDefaultConfig();
        var client = new Kubernetes(config);

        var rgdList = await client.CustomObjects.ListClusterCustomObjectAsync<ResourceGraphDefinitionList>(
            "kro.run", "v1alpha1", "resourcegraphdefinitions");

        rgdList.Items.ForEach(rgd =>
        {
            Console.WriteLine(rgd.Metadata.Name);
        });

        return TypedResults.Ok(rgdList.Items);
    }
}

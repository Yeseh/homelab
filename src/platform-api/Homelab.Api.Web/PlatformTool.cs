using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using ModelContextProtocol.Server;

namespace Homelab.Api.Web;
    
[McpServerToolType]
public class PlatformTool(PlatformClient client)
{
    [McpServerTool(Name = "ListPlatformApis", Destructive = false, ReadOnly = true, Title = "List Platform APIs")]
    [Description("Lists all platform infrastructure templates")]
    public async Task<List<PlatformApiSummary>> ListPlatformApis(
        [Description("The API version of the infrastructure templates")] string apiVersion = "v1alpha1")
    {
        var apis = await client.ListPlatformApisAsync(apiVersion);
        var summaries = apis.Select(PlatformApiSummary.From).ToList();

        return summaries;
    }

    [McpServerTool(Name = "GetPlatformApi", Destructive = false, ReadOnly = true, Title = "Get Platform API")]
    [Description("Get a detailed view of a single platform API")]
    public async Task<PlatformApiDetail> GetPlatformApi(
        [Description("The name of the infrastructure template")] string name,
        [Description("The API version of the infrastructure templates")] string apiVersion = "v1alpha1")
    {
        var api = await client.GetPlatformApiAsync(apiVersion, name);
        var detail = PlatformApiDetail.From(api); 

        return api is not null 
            ? PlatformApiDetail.From(api) 
            : detail;
    }
}
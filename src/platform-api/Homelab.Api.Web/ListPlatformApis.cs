using System.Threading.Tasks;
using System.Collections.Generic;
using ModelContextProtocol.Server;
using System.ComponentModel;
using System.Linq;

[McpServerToolType]
public class PlatformTool
{
    public record PlatformApiSummary(
        string Name,
        string ApiVersion,
        string Kind,
        string Description
    );

    [McpServerTool(Name = "ListPlatformApis", Destructive = false, ReadOnly = true, Title = "List Platform APIs")]
    [Description("Lists all platform infrastructure templates")]
    public static async Task<List<PlatformApiSummary>> ListPlatformApis(PlatformClient client)
    {
        var apis = await client.ListPlatformApisAsync();

        var summaries = apis.Select(api => new PlatformApiSummary(
            api.Metadata.Name,
            api.ApiVersion,
            api.Kind,
            api.Metadata.Labels["homelab.yeseh.nl/llm-description"]
        )).ToList();

        return summaries;
    }
}

using System.Threading.Tasks;
using System.Collections.Generic;
using ModelContextProtocol.Server;
using System.ComponentModel;
using System.Linq;

[McpServerToolType]
public class PlatformTool(PlatformClient client)
{
    public record PlatformApiSummary(
        string Name,
        string ApiVersion,
        string Kind,
        string Description
    )
    {
        public static PlatformApiSummary From(ResourceGraphDefinition rgd)
        {
            _ = rgd.Metadata.Annotations.TryGetValue("homelab.yeseh.nl/llm-description", out var description);

            var summary = new PlatformApiSummary(
                rgd.Metadata.Name,
                rgd.ApiVersion,
                rgd.Kind,
                description ?? "Unknown");
            
            return summary;
        }
        public override string ToString()
        {
            return $"{Name} ({ApiVersion}) - {Kind}: {Description}";
        }
    };

    [McpServerTool(Name = "ListPlatformApis", Destructive = false, ReadOnly = true, Title = "List Platform APIs")]
    [Description("Lists all platform infrastructure templates")]
    public async Task<List<PlatformApiSummary>> ListPlatformApis()
    {
        var apis = await client.ListPlatformApisAsync();

        var summaries = apis.Select(PlatformApiSummary.From).ToList();

        return summaries;
    }
}

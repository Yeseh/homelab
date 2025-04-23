namespace Homelab.Api.Web;

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
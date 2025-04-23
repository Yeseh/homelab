using System.Collections.Generic;
using System.Text.Json;

namespace Homelab.Api.Web;

using static PlatformApiMetadata;

public record PlatformApiDetail(
    string Name,
    string ApiVersion,
    string Description,
    string Kind,
    string Schema
)
{
    public static PlatformApiDetail From(ResourceGraphDefinition rgd)
    {
        _ = rgd.Metadata.Annotations.TryGetValue(Llmdescription, out var description);

        var schema = JsonSerializer.Serialize(rgd.Spec.Schema);

        var detail = new PlatformApiDetail(
            rgd.Metadata.Name,
            rgd.ApiVersion,
            description ?? "Unknown",
            rgd.Kind,
            schema
        );

        return detail;
    }
};

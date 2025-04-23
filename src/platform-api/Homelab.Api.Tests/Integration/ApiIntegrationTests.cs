using System.Net.Http;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;
using System.Collections.Generic;

namespace Homelab.Api.Tests.Integration;

public class ApiIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ApiIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task PlatformApis_Endpoint_ReturnsSuccess()
    {
        // Act
        var response = await _client.GetFromJsonAsync<List<ResourceGraphDefinition>>("api/platform-apis");

        Assert.NotNull(response);
        Assert.NotEmpty(response);
    }
}

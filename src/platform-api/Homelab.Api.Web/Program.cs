using Homelab.Api.Web;
using k8s;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMcpServer()
    .WithTools<PlatformTool>()
    .WithHttpTransport();

builder.Services.AddSingleton(new Kubernetes(KubernetesClientConfiguration.BuildDefaultConfig()));
builder.Services.AddSingleton(sp => new PlatformClient(sp.GetRequiredService<Kubernetes>()));

var app = builder.Build();

app.MapMcp();
app.Run();

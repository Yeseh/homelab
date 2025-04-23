using System;
using System.Linq;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container if needed
// builder.Services.AddSingleton<...>();

var app = builder.Build();

// Example minimal API endpoint
app.MapGet("/weatherforecast", () =>
{
    var summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };
    var forecast = Enumerable.Range(1, 5).Select(index => new WeatherForecast
    {
        Date = DateTime.Now.AddDays(index),
        TemperatureC = Random.Shared.Next(-20, 55),
        Summary = summaries[Random.Shared.Next(summaries.Length)]
    })
    .ToArray();
    return forecast;
});

app.MapListPlatformApis();

app.Run();

record WeatherForecast
                               {
                                   public DateTime Date { get; set; }
                                   public int TemperatureC { get; set; }
                                   public string Summary { get; set; }
                               }
                               
                               
                               public partial class Program {}
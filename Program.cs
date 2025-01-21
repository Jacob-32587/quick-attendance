// using Microsoft.AspNetCore.Components.Web;
// using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
// using id_scanner;
//
// var builder = WebAssemblyHostBuilder.CreateDefault(args);
// builder.RootComponents.Add<App>("#app");
// builder.RootComponents.Add<HeadOutlet>("head::after");
//
// builder.Services.AddScoped(sp => new HttpClient {
//   BaseAddress = new Uri(builder.HostEnvironment.BaseAddress)
// });

// await builder.Build().RunAsync();
// Keep the code above, it will be used if we decide to make a web interface
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

HostApplicationBuilder builder = Host.CreateApplicationBuilder(args);

builder.Services.AddCustomServices();

using IHost host = builder.Build();

var app = new ConsoleApplication(host.Services.GetRequiredService<ICardReader>());
app.main(args);

open FSharpTemplate
open Giraffe
open System
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting

let configureApp (app : IApplicationBuilder) =
    let test = "test"
    app
       .UseGiraffe(HttpRoutes.api test)
       
let configureServices (services : IServiceCollection) =
    services.AddGiraffe() |> ignore
    services.AddApplicationInsightsTelemetry() |> ignore
           
[<EntryPoint>]
let main args =
    Host.CreateDefaultBuilder(args)
        .ConfigureWebHostDefaults(
            fun webHostBuilder ->
                webHostBuilder
                    .Configure(Action<IApplicationBuilder> configureApp)
                    .ConfigureServices(configureServices)
                    |> ignore)
        .Build()
        .Run()
    0
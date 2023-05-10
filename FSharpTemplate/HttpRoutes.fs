namespace FSharpTemplate

open Giraffe

module rec HttpRoutes =
    let api _ =
        choose [
            healthCheck
            setStatusCode 404 >=> text "Not Found"
        ]
    
    let healthCheck =
        GET >=>
            route "/api/health"
                >=> HealthCheck.handle
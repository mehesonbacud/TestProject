namespace FSharpTemplate

open Giraffe.HttpStatusCodeHandlers

module HealthCheck =
    let handle next context = task {
        return! Successful.OK "healthy" next context
    }


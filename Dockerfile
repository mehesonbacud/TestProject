FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
COPY ["FSharpTemplate/FSharpTemplate.fsproj", "FSharpTemplate/"]
RUN dotnet restore "FSharpTemplate/FSharpTemplate.fsproj"
COPY . .
RUN dotnet build "FSharpTemplate/FSharpTemplate.fsproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FSharpTemplate/FSharpTemplate.fsproj" -c Release -o /app/publish

EXPOSE 80 9000
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FSharpTemplate.dll"]

# 1. Use the .NET SDK to build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 2. Copy the project files using the FULL PATH from the repo root
# This allows the API to find its sibling projects (Core and Infrastructure)
COPY ["Bingo Service/Bingo.API/Bingo.API.csproj", "Bingo Service/Bingo.API/"]
COPY ["Bingo Service/Bingo.Core/Bingo.Core.csproj", "Bingo Service/Bingo.Core/"]
COPY ["Bingo Service/Bingo.Infrastructure/Bingo.Infrastructure.csproj", "Bingo Service/Bingo.Infrastructure/"]

# 3. Restore dependencies
RUN dotnet restore "Bingo Service/Bingo.API/Bingo.API.csproj"

# 4. Copy everything else and build
COPY . .
WORKDIR "/src/Bingo Service/Bingo.API"
RUN dotnet build "Bingo.API.csproj" -c Release -o /app/build

# 5. Publish
FROM build AS publish
RUN dotnet publish "Bingo.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# 6. Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# ASP.NET Core will listen on port 8080 inside the container
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Bingo.API.dll"]
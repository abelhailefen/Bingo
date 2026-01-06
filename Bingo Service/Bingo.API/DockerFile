FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# The first part of the path MUST match your GitHub folder name exactly   
COPY ["Bingo Service/Bingo.API/Bingo.API.csproj", "Bingo Service/Bingo.API/"]
COPY ["Bingo Service/Bingo.Core/Bingo.Core.csproj", "Bingo Service/Bingo.Core/"]
COPY ["Bingo Service/Bingo.Infrastructure/Bingo.Infrastructure.csproj", "Bingo Service/Bingo.Infrastructure/"]

RUN dotnet restore "Bingo Service/Bingo.API/Bingo.API.csproj"

COPY . .
WORKDIR "/src/Bingo Service/Bingo.API"
RUN dotnet build "Bingo.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Bingo.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS=http://+:10000
EXPOSE 10000
ENTRYPOINT ["dotnet", "Bingo.API.dll"]
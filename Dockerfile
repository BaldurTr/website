FROM microsoft/aspnetcore-build:2.0 AS build-env

LABEL maintainer="baldur.tryggvason@arionbanki.is"

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore

# Copy everything else and build
COPY . .
RUN dotnet publish --output /out/ --configuration Release

# Build runtime image
FROM microsoft/aspnetcore:2.0

# Install Node.js on the runtime image
ENV NODE_VERSION 6.12.3 
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz 
ENV NODE_DOWNLOAD_SHA 0F8144C84C4379CB35AE409779C062A65680CF163B52C4660932EB58CFA1D065 
RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz \ 
    && echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - \ 
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \ 
    && rm nodejs.tar.gz \ 
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

WORKDIR /app
COPY --from=build-env /out .

ENTRYPOINT ["dotnet", "website.dll"]


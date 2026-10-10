FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY Touchline.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /out --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
USER root
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-venv libglib2.0-0 && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/vision
COPY Tools/requirements-linux.txt /tmp/requirements.txt
RUN /opt/vision/bin/pip install --no-cache-dir torch==2.8.0 torchvision==0.23.0 --index-url https://download.pytorch.org/whl/cpu && /opt/vision/bin/pip install --no-cache-dir -r /tmp/requirements.txt
ENV VISION_ENGINE=linux VISION_PYTHON=/opt/vision/bin/python VISION_MODEL_DIR=/opt/models TORCH_HOME=/opt/torch VISION_THREADS=2 ASPNETCORE_URLS=http://+:8080 HOSTED_MODE=true
WORKDIR /app
COPY --from=build /out .
COPY Tools/linux_reader.py Tools/linux_reader.py
RUN /opt/vision/bin/python Tools/linux_reader.py --prepare && chmod -R a+rX /opt/models /opt/torch
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "Touchline.dll"]

FROM microsoft/dotnet:2.0.4-sdk-2.1.3
RUN apt update && apt install unzip -yqq
EXPOSE 5000
ADD * /app/
WORKDIR /app
RUN unzip -o s.zip
ENTRYPOINT ["dotnet", "VSTSTest.dll"]
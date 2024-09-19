# File: tests/logicapp/Dockerfile
#
# Purpose: This Dockerfile sets up an environment to run a Logic App workflow locally.
# It uses the Azure Functions Node.js image as a base and copies the workflow definition into the container.

FROM mcr.microsoft.com/azure-functions/node:4-node18

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY tests/logicapp/workflow.json /home/site/wwwroot/workflow.json

RUN npm install -g azure-functions-core-tools@4

CMD ["func", "start", "--javascript"]
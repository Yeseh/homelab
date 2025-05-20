# Platform API Examples

This directory contains example usage of the platform APIs defined in the `infrastructure/platform-apis` directory.

## Azure SQL Database

The `azure-sql-database.yaml` example demonstrates how to create an Azure SQL Database with a private endpoint using the platform API. It links to an existing Canvas for permissions and networking.

### Prerequisites

Before using this example:

1. Make sure you have a Canvas already created (see the Canvas API)
2. Update the following fields with your actual values:
   - `namespace`: Should match your canvas namespace
   - `canvasName` and `canvasEnvironment`: Should match your canvas configuration
   - `location`: Azure region where resources will be deployed
   - `administratorLogin` and `administratorLoginPassword`: Secure credentials for the SQL Server
   - `privateEndpointSubnetId`: Subnet ID where the private endpoint will be created

### Security Considerations

For production use:
- Do not store passwords in plain text in the YAML file
- Use a secret reference or external-secrets integration instead
- Follow least privilege principle when assigning roles

### Deployment

To apply this example:

```bash
kubectl apply -f examples/azure-sql-database.yaml
```
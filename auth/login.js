const { CognitoIdentityProviderClient, AdminInitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION || "us-east-1" });

module.exports.handler = async (event) => {
  console.log("Login Event: ", event);
  
  try {
    const body = JSON.parse(event.body || '{}');
    const { cpf } = body;

    if (!cpf) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: "CPF is required",
        }),
      };
    }

    const userPoolId = process.env.COGNITO_USER_POOL_ID;
    const clientId = process.env.COGNITO_CLIENT_ID;
    
    if (!userPoolId || !clientId) {
      throw new Error("COGNITO_USER_POOL_ID and COGNITO_CLIENT_ID environment variables are required");
    }

    const command = new AdminInitiateAuthCommand({
      UserPoolId: userPoolId,
      ClientId: clientId,
      AuthFlow: 'ADMIN_NO_SRP_AUTH',
      AuthParameters: {
        USERNAME: cpf,
        PASSWORD: `${cpf}Temp!`
      }
    });

    const response = await cognitoClient.send(command);

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Login successful",
        accessToken: response.AuthenticationResult?.AccessToken,
        idToken: response.AuthenticationResult?.IdToken,
        refreshToken: response.AuthenticationResult?.RefreshToken,
        expiresIn: response.AuthenticationResult?.ExpiresIn
      }),
    };
  } catch (error) {
    console.error("Error during login:", error);
    
    if (error.name === 'UserNotFoundException' || error.name === 'NotAuthorizedException') {
      return {
        statusCode: 401,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: "Invalid CPF or user not found"
        }),
      };
    }

    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Error during login",
        error: error.message
      }),
    };
  }
};
const { CognitoIdentityProviderClient, AdminCreateUserCommand } = require("@aws-sdk/client-cognito-identity-provider");

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION || "us-east-1" });

module.exports.handler = async (event) => {
  console.log("Registration Event: ", event);
  
  try {
    const body = JSON.parse(event.body || '{}');
    const { cpf, name } = body;

    if (!cpf || !name) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: "CPF and name are required",
        }),
      };
    }

    const userPoolId = process.env.COGNITO_USER_POOL_ID;
    if (!userPoolId) {
      throw new Error("COGNITO_USER_POOL_ID environment variable is required");
    }

    const command = new AdminCreateUserCommand({
      UserPoolId: userPoolId,
      Username: cpf,
      UserAttributes: [
        {
          Name: 'name',
          Value: name
        },
        {
          Name: 'email',
          Value: `${cpf}@temp.local`
        }
      ],
      TemporaryPassword: `${cpf}Temp!`,
      MessageAction: 'SUPPRESS'
    });

    const response = await cognitoClient.send(command);

    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "User registered successfully",
        username: response.User.Username,
        userStatus: response.User.UserStatus
      }),
    };
  } catch (error) {
    console.error("Error registering user:", error);
    
    if (error.name === 'UsernameExistsException') {
      return {
        statusCode: 409,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: "User with this CPF already exists"
        }),
      };
    }

    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Error registering user",
        error: error.message
      }),
    };
  }
};
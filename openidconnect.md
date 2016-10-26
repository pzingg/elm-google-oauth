Info from https://developers.google.com/identity/protocols/OpenIDConnect

# OpenID Connect

Google's OpenID Connect endpoint is OpenID Certified.

Google's OAuth 2.0 APIs can be used for both authentication and authorization. This document describes our OAuth 2.0 implementation for authentication, which conforms to the OpenID Connect specification, and is OpenID Certified. The documentation found in Using OAuth 2.0 to Access Google APIs also applies to this service. If you want to explore this protocol interactively, we recommend the Google OAuth 2.0 Playground. To get help on Stack Overflow, tag your questions with 'google-oauth'.

    Note: If you want to provide a "Sign-in with Google" button for your website or app, we recommend using Google Sign-In, our sign-in client library that is built on the OpenID Connect protocol and provides OpenID Connect formatted ID Tokens.

## Setting up OAuth 2.0

Before your application can use Google's OAuth 2.0 authentication system for user login, you must set up a project in the Google API Console to obtain OAuth 2.0 credentials, set a redirect URI, and (optionally) customize the branding information that your users see on the user-consent screen. You can also use the API Console to create a service account, enable billing, set up filtering, and do other tasks. For more details, see the Google API Console Help.

### Obtain OAuth 2.0 credentials

You need OAuth 2.0 credentials, including a client ID and client secret, to authenticate users and gain access to Google's APIs.

To find your project's client ID and client secret, do the following:

1. Select an existing OAuth 2.0 credential or open the Credentials page.
2. If you haven't done so already, create your project's OAuth 2.0 credentials by clicking Create credentials > OAuth client ID, and providing the information needed to create the credentials.
3. Look for the Client ID in the OAuth 2.0 client IDs section. For details, click the client ID.

### Set a redirect URI

The redirect URI that you set in the API Console determines where Google sends responses to your authentication requests.

To find the redirect URIs for your OAuth 2.0 credentials, do the following:

1. Open the Credentials page in the API Console.
2. If you haven't done so already, create your OAuth 2.0 credentials by clicking Create credentials > OAuth client ID.
3. After you create your credentials, view or edit the redirect URLs by clicking the client ID (for a web application) in the OAuth 2.0 client IDs section.

### Customize the user consent screen

For your users, the OAuth 2.0 authentication experience includes a consent screen that describes the information that the user is releasing and the terms that apply. For example, when the user logs in, they might be asked to give your app access to their email address and basic account information. You request access to this information using the scope parameter, which your app includes in its authentication request. You can also use scopes to request access to other Google APIs.

The user consent screen also presents branding information such as your product name, logo, and a homepage URL. You control the branding information in the API Console.

To set up your project's consent screen, do the following:

1. Open the Consent Screen page in the Google API Console. If prompted, select a project or create a new one.
2. Fill out the form and click Save.

The following consent dialog shows what a user would see when a combination of OAuth 2.0 and Google Drive scopes are present in the request. (This generic dialog was generated using the Google OAuth 2.0 Playground, so it does not include branding information that would be set in the API Console.)

### Accessing the service

Google and third parties provide libraries that you can use to take care of many of the implementation details of authenticating users and gaining access to Google APIs. Examples include Google Sign-In and the Google client libraries, which are available for a variety of platforms.

    Note: Given the security implications of getting the implementation correct, we strongly encourage you to take advantage of a pre-written library or service. Authenticating users properly is important to their and your safety and security, and using well-debugged code written by others is generally a best practice. For more information, see Client libraries.

If you choose not to use a library, follow the instructions in the remainder of this document, which describes the HTTP request flows that underly the available libraries.

### Authenticating the user

Authenticating the user involves obtaining an ID token and validating it. ID tokens are a standardized feature of OpenID Connect designed for use in sharing identity assertions on the Internet.

The most commonly used approaches for authenticating a user and obtaining an ID token are called the "server" flow and the "implicit" flow. The server flow allows the back-end server of an application to verify the identity of the person using a browser or mobile device. The implicit flow is used when a client-side application (typically a JavaScript app running in the browser) needs to access APIs directly instead of via its back-end server.

This document describes how to perform the server flow for authenticating the user. The implicit flow is significantly more complicated because of security risks in handling and using tokens on the client side. If you need to implement an implicit flow, we highly recommend using Google Sign-In.

### Server flow

Make sure you set up your app in the API Console to enable it to use these protocols and authenticate your users. When a user tries to log in with Google, you need to:

1. Create an anti-forgery state token
2. Send an authentication request to Google
3. Confirm the anti-forgery state token
4. Exchange code for access token and ID token
5. Obtain user information from the ID token, or
6. Obtain user profile information from the access token, and possibly
7. Authenticate the user

### 1. Create an anti-forgery state token

See Update.elm and Tokens.elm for a time-seeded 40-character token.  This
token will be stored in browser Local Storage for the round-trip to Google.

### 2. Send an authentication request to Google

For a basic request, specify the following parameters:

* client_id, which you obtain from the API Console.
* response_type, which in a basic request should be code. (Read more at response_type.)
* scope, which in a basic request should be openid email. (Read more at scope.)
* redirect_uri should be the HTTP endpoint on your server that will receive the response from Google. You specify this URI in the API Console.
* state should include the value of the anti-forgery unique session token, as well as any other information needed to recover the context when the user returns to your application, e.g., the starting URL. (Read more at state.)
* login_hint can be the user's email address or the sub string, which is equivalent to the user's Google ID. If you do not provide a login_hint and the user is currently logged in, the consent screen includes a request for approval to release the user’s email address to your app. (Read more at login_hint.)
* Use the openid.realm if you are migrating an existing application from OpenID 2.0 to OpenID Connect. For details, see Migrating off of OpenID 2.0.
* Use the hd parameter to optimize the OpenID Connect flow for users of a particular Google Apps for Work domain. (Read more at hd.)

Here is an example of a complete OpenID Connect authentication URI, with line breaks and spaces for readability:

```
https://accounts.google.com/o/oauth2/v2/auth?
 client_id=424911365001.apps.googleusercontent.com&
 response_type=code&
 scope=openid%20email&
 redirect_uri=https://oauth2-login-demo.example.com/code&
 state=security_token%3D138r5719ru3e1%26url%3Dhttps://oauth2-login-demo.example.com/myHome&
 login_hint=jsmith@example.com&
 openid.realm=example.com&
 hd=example.com
```

### 4. Exchange code for access token and ID token

The request must include the following parameters in the POST body:

* code: The authorization code that is returned from the initial request.
* client_id: The client ID that you obtain from the API Console, as described in Obtain OAuth 2.0 credentials.
* client_secret: The client secret that you obtain from the API Console, as described in Obtain OAuth 2.0 credentials.
* redirect_uri: The URI that you specify in the API Console, as described in Set a redirect URI.
* grant_type: This field must contain a value of authorization_code, as defined in the OAuth 2.0 specification.

The actual request might look like the following example:

```
POST /oauth2/v4/token HTTP/1.1
Host: www.googleapis.com
Content-Type: application/x-www-form-urlencoded

code=4/P7q7W91a-oMsCeLvIaQm6bTrgtp7&
client_id=8819981768.apps.googleusercontent.com&
client_secret={client_secret}&
redirect_uri=https://oauth2-login-demo.example.com/code&
grant_type=authorization_code
```

### 6. Obtain user profile information from the access token

To obtain additional profile information about the user, you can use the access token (which your application receives during the authentication flow) with two different endpoints. Unless you are using the plus.login scope, these endpoints provide identical information, just formatted differently.

#### Google Sign-In

If you are using Google Sign-In, retrieve user profile information from the people.get endpoint. To do this, add your access token to the authorization header and make an HTTPS GET request to the following URI:

```
https://www.googleapis.com/plus/v1/people/me
```

Use your access token to authenticate the request, as described in people.get. Note that the response does not use the OpenID Connect format.

#### OpenID Connect

If you want to use the OpenID Connect standard and need attributes formatted accordingly:

To be OpenID-compliant, you must include the openid profile scope in your authentication request.

If you want the user’s email address to be included, you can optionally request the openid email scope. To specify both profile and email, you can include the following parameter in your authentication request URI:

```
scope=openid%20email%20profile
```

Add your access token to the authorization header and make an HTTPS GET request to the userinfo endpoint, which you should retrieve from the Discovery document using the key userinfo_endpoint. The response includes information about the user, as described in people.getOpenIdConnect. Users may choose to supply or withhold certain fields, so you might not get information for every field to which your scopes request access.

If successful, this method returns a response body with the following structure:

```
{
  "kind": "plus#personOpenIdConnect",
  "gender": string,
  "sub": string,
  "name": string,
  "given_name": string,
  "family_name": string,
  "profile": string,
  "picture": string,
  "email": string,
  "email_verified": "true",
  "locale": string,
  "hd": string
}
```

## Client secrets

You must create an Elm source file named ClientSecrets.elm in the src
folder and expose these functions:

```
projectName : String
projectName = ...

redirectURI : String
redirectURI = ...

clientID : String
clientID = ...

clientSecret : String
clientSecret = ...
```

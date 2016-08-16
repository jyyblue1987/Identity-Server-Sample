using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens;
using System.Security.Claims;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;
using Newtonsoft.Json;


namespace ScottBrady91.IdentityServer3.Example.Client.FormPost.Controllers
{
    public class Profile
    {
        public String given_name;
        public String sub;
        public String family_name;
        public String email;
        public String[] role;
    }

    public sealed class AccountController : Controller
    {
        private const string ClientUri = @"https://localhost:44304";
        private const string CallbackEndpoint = ClientUri + @"/account/signInCallback";
        private const string IdServBaseUri = @"https://localhost:44300/core";
        private const string AuthorizeUri = IdServBaseUri + @"/connect/authorize";
        private const string LogoutUri = IdServBaseUri + @"/connect/endsession";

     
        public ActionResult SignIn()
        {
            var state = Guid.NewGuid().ToString("N");
            var nonce = Guid.NewGuid().ToString("N");

            var url = AuthorizeUri +
                      "?client_id=implicitclient" +
                      "&response_type=id_token token" +
                      "&scope=openid email profile roles" +
                      "&redirect_uri=" + CallbackEndpoint +
                      "&response_mode=form_post" +
                      "&state=" + state +
                      "&nonce=" + nonce;

            this.SetTempCookie(state, nonce);
            return this.Redirect(url);
        }

        private void SetTempCookie(string state, string nonce)
        {
            var tempId = new ClaimsIdentity("TempCookie");
            tempId.AddClaim(new Claim("state", state));
            tempId.AddClaim(new Claim("nonce", nonce));

            this.Request.GetOwinContext().Authentication.SignIn(tempId);
        }

        [HttpPost]
        public async Task<ActionResult> SignInCallback()
        {
            var token = this.Request.Form["id_token"];
            var state = this.Request.Form["state"];
            var access_token = this.Request.Form["access_token"];

            var claims = await this.ValidateIdentityTokenAsync(token, state);

            var id = new ClaimsIdentity(claims, "Cookies");
            this.Request.GetOwinContext().Authentication.SignIn(id);

            ServicePointManager.ServerCertificateValidationCallback +=
                        (sender, cert, chain, sslPolicyErrors) => true;

            // Create a request for the URL. 
            WebRequest request = WebRequest.Create(
              "https://localhost:44300/core/connect/userinfo");
            // If required by the server, set the credentials.
            //request.Credentials = CredentialCache.DefaultCredentials;

            request.Headers["Authorization"] = "Bearer " + access_token;

            // Get the response.
            WebResponse response = request.GetResponse();
            // Display the status.
            Console.WriteLine(((HttpWebResponse)response).StatusDescription);
            // Get the stream containing content returned by the server.
            Stream dataStream = response.GetResponseStream();
            // Open the stream using a StreamReader for easy access.
            StreamReader reader = new StreamReader(dataStream);
            // Read the content.
            string responseFromServer = reader.ReadToEnd();
            // Display the content.
            Console.WriteLine(responseFromServer);
            // Clean up the streams and the response.
            reader.Close();
            response.Close();

            Profile profile = JsonConvert.DeserializeObject<Profile>(responseFromServer);

            var given_name = profile.given_name;

            HttpCookie profile_cookie = new HttpCookie("Profile");
            profile_cookie["given_name"] = profile.given_name;
            profile_cookie["family_name"] = profile.family_name;
            profile_cookie["email"] = profile.email;
            string roles = "";
            for(var i = 0; i < profile.role.Length; i++)
            {
                if( i > 0 )
                    roles += ", ";
                roles += profile.role[i];
            }
            profile_cookie["roles"] = roles;
            profile_cookie.Expires = DateTime.Now.AddDays(1d);
            Response.Cookies.Add(profile_cookie);


            return this.Redirect("/");
        }

        private async Task<IEnumerable<Claim>> ValidateIdentityTokenAsync(string token, string state)
        {
            const string certString =
                "MIIDBTCCAfGgAwIBAgIQNQb+T2ncIrNA6cKvUA1GWTAJBgUrDgMCHQUAMBIxEDAOBgNVBAMTB0RldlJvb3QwHhcNMTAwMTIwMjIwMDAwWhcNMjAwMTIwMjIwMDAwWjAVMRMwEQYDVQQDEwppZHNydjN0ZXN0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqnTksBdxOiOlsmRNd+mMS2M3o1IDpK4uAr0T4/YqO3zYHAGAWTwsq4ms+NWynqY5HaB4EThNxuq2GWC5JKpO1YirOrwS97B5x9LJyHXPsdJcSikEI9BxOkl6WLQ0UzPxHdYTLpR4/O+0ILAlXw8NU4+jB4AP8Sn9YGYJ5w0fLw5YmWioXeWvocz1wHrZdJPxS8XnqHXwMUozVzQj+x6daOv5FmrHU1r9/bbp0a1GLv4BbTtSh4kMyz1hXylho0EvPg5p9YIKStbNAW9eNWvv5R8HN7PPei21AsUqxekK0oW9jnEdHewckToX7x5zULWKwwZIksll0XnVczVgy7fCFwIDAQABo1wwWjATBgNVHSUEDDAKBggrBgEFBQcDATBDBgNVHQEEPDA6gBDSFgDaV+Q2d2191r6A38tBoRQwEjEQMA4GA1UEAxMHRGV2Um9vdIIQLFk7exPNg41NRNaeNu0I9jAJBgUrDgMCHQUAA4IBAQBUnMSZxY5xosMEW6Mz4WEAjNoNv2QvqNmk23RMZGMgr516ROeWS5D3RlTNyU8FkstNCC4maDM3E0Bi4bbzW3AwrpbluqtcyMN3Pivqdxx+zKWKiORJqqLIvN8CT1fVPxxXb/e9GOdaR8eXSmB0PgNUhM4IjgNkwBbvWC9F/lzvwjlQgciR7d4GfXPYsE1vf8tmdQaY8/PtdAkExmbrb9MihdggSoGXlELrPA91Yce+fiRcKY3rQlNWVd4DOoJ/cPXsXwry8pWjNCo5JD8Q+RQ5yZEy7YPoifwemLhTdsBz3hlZr28oCGJ3kbnpW0xGvQb3VHSTVVbeei0CfXoW6iz1";

            var cert = new X509Certificate2(Convert.FromBase64String(certString));

            var result = await this.Request
                .GetOwinContext()
                .Authentication
                .AuthenticateAsync("TempCookie");

            if (result == null)
            {
                throw new InvalidOperationException("No temp cookie");
            }

            if (state != result.Identity.FindFirst("state").Value)
            {
                throw new InvalidOperationException("invalid state");
            }

            var parameters = new TokenValidationParameters
            {
                ValidAudience = "implicitclient",
                ValidIssuer = IdServBaseUri,
                IssuerSigningToken = new X509SecurityToken(cert)
            };

            var handler = new JwtSecurityTokenHandler();
            SecurityToken jwt;
            var id = handler.ValidateToken(token, parameters, out jwt);

            if (id.FindFirst("nonce").Value !=
                result.Identity.FindFirst("nonce").Value)
            {
                throw new InvalidOperationException("Invalid nonce");
            }

            this.Request
                .GetOwinContext()
                .Authentication
                .SignOut("TempCookie");

            return id.Claims;
        }

        public ActionResult SignOut()
        {
            this.Request.GetOwinContext().Authentication.SignOut();
            return this.Redirect(LogoutUri);
        }
    }
}
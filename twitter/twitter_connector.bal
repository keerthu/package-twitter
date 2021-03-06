// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package twitter;

import ballerina/io;
import ballerina/net.uri;
import ballerina/mime;

//Creates package-global Http client endpoint for twitter REST API
endpoint http:ClientEndpoint twitterHttpClientEP {targets:[{uri:"https://api.twitter.com"}]};
boolean isConnectorInitialized = false;

//Twitter Connector Struct
public struct TwitterConnector {
    OAuthConfig oAuthConfig;
}

public struct OAuthConfig {
    string accessToken;
    string accessTokenSecret;
    string clientId;
    string clientSecret;
}

public function <TwitterConnector twitterConnector> init (string clientId, string clientSecret,
                                                          string accessToken, string accessTokenSecret) {
    OAuthConfig conf = {};
    conf.clientId = clientId;
    conf.clientSecret = clientSecret;
    conf.accessToken = accessToken;
    conf.accessTokenSecret = accessTokenSecret;
    twitterConnector.oAuthConfig = conf;
    isConnectorInitialized = true;
}

public function <TwitterConnector twitterConnector> tweet (string status) returns Status | TwitterError {
    http:Request request = {};
    TwitterError twitterError = {};
    string tweetPath = "/1.1/statuses/update.json";
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string encodedStatusValue =? uri:encode(status, "UTF-8");

    string urlParams = "status=" + encodedStatusValue + "&";

    string oauthStr = constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                           twitterConnector.oAuthConfig.accessToken) + urlParams;

    constructRequestHeaders(request, "POST", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);
    tweetPath = tweetPath + "?" + urlParams;

    var httpResponse = twitterHttpClientEP -> post(tweetPath, request);

    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                               var twitterJSONResponse = response.getJsonPayload();
                               match twitterJSONResponse {
                                   mime:EntityError err => {
                                       twitterError.errorMessage = err.message;
                                       return twitterError;
                                   }
                                   json jsonResponse => {
                                       if (statusCode == 200) {
                                           Status twitterResponse = <Status , convertToStatus()> jsonResponse;
                                           return twitterResponse;
                                       } else {
                                           twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                           twitterError.statusCode = statusCode;
                                           return twitterError;
                                       }
                                   }
                               }
                            }
    }
}

public function <TwitterConnector twitterConnector> retweet (string id) returns Status | TwitterError {
    http:Request request = {};
    TwitterError twitterError = {};
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string oauthStr = constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                           twitterConnector.oAuthConfig.accessToken);

    string tweetPath = "/1.1/statuses/retweet/" + id + ".json";
    constructRequestHeaders(request, "POST", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);

    var httpResponse = twitterHttpClientEP -> post(tweetPath, request);

    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                Status twitterResponse = <Status , convertToStatus()> jsonResponse;
                                                return twitterResponse;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
                                }
    }
}

public function <TwitterConnector twitterConnector> unretweet (string id) returns Status | TwitterError {
    http:Request request = {};
    TwitterError twitterError = {};
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string oauthStr = constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                           twitterConnector.oAuthConfig.accessToken);

    string tweetPath = "/1.1/statuses/unretweet/" + id + ".json";
    constructRequestHeaders(request, "POST", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);

    var httpResponse = twitterHttpClientEP -> post(tweetPath, request);

    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                Status twitterResponse = <Status , convertToStatus()> jsonResponse;
                                                return twitterResponse;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
        }
    }
}

public function <TwitterConnector twitterConnector> search (string queryStr) returns Status[] | TwitterError {
    string tweetPath = "/1.1/search/tweets.json";
    string encodedQueryValue =? uri:encode(queryStr, "UTF-8");
    TwitterError twitterError = {};

    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string urlParams = "q=" + encodedQueryValue + "&";
    string oauthStr = constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                           twitterConnector.oAuthConfig.accessToken) + urlParams;

    http:Request request = {};
    constructRequestHeaders(request, "GET", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);
    tweetPath = tweetPath + "?" + urlParams;

    var httpResponse = twitterHttpClientEP -> get(tweetPath, request);

    Status[] searchResponse = [];
    match httpResponse {
        http:HttpConnectorError err => { twitterError.errorMessage = err.message;
                                         twitterError.statusCode = err.statusCode;
                                         return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                if (jsonResponse.statuses != null) {
                                                    searchResponse = convertToStatuses(jsonResponse.statuses);
                                                }
                                                return searchResponse;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.error.message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
        }
    }
}

public function <TwitterConnector twitterConnector> showStatus (string id) returns Status | TwitterError {
    http:Request request = {};
    TwitterError twitterError = {};
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string tweetPath = "/1.1/statuses/show.json";
    string urlParams = "id=" + id;
    string oauthStr = urlParams + "&" + constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                                             twitterConnector.oAuthConfig.accessToken);

    constructRequestHeaders(request, "GET", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);
    tweetPath = tweetPath + "?" + urlParams;

    var httpResponse = twitterHttpClientEP -> get(tweetPath, request);

    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                Status twitterResponse = <Status , convertToStatus()> jsonResponse;
                                                return twitterResponse;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
        }
    }
}

public function <TwitterConnector twitterConnector> destroyStatus (string id) returns Status | TwitterError {
    http:Request request = {};
    TwitterError twitterError = {};
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string oauthStr = constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                           twitterConnector.oAuthConfig.accessToken);

    string tweetPath = "/1.1/statuses/destroy/" + id + ".json";
    constructRequestHeaders(request, "POST", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);

    var httpResponse = twitterHttpClientEP -> post(tweetPath, request);

    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                Status twitterResponse = <Status , convertToStatus()> jsonResponse;
                                                return twitterResponse;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
        }
    }
}

public function <TwitterConnector twitterConnector> getClosestTrendLocations (string lat, string long)
                                                                    returns Location [] | TwitterError {
    TwitterError twitterError = {};
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string tweetPath = "/1.1/trends/closest.json";
    string urlParams =  "&lat=" + lat + "&long=" + long;
    string oauthStr = urlParams.subString(1, urlParams.length()) + "&" +
                      constructOAuthParams(twitterConnector.oAuthConfig.clientId,
                                           twitterConnector.oAuthConfig.accessToken);
    http:Request request = {};
    constructRequestHeaders(request, "GET", tweetPath, twitterConnector.oAuthConfig.clientId,
                            twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);
    tweetPath = tweetPath + "?" + urlParams.subString(1, urlParams.length());

    var httpResponse = twitterHttpClientEP -> get(tweetPath, request);
    Location[] locations = [];
    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                locations = convertToLocations(jsonResponse);
                                                return locations;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
        }
    }
}

public function <TwitterConnector twitterConnector> getTopTrendsByPlace (string locationId)
                                                                    returns Trends[] | TwitterError {
    TwitterError twitterError = {};
    if (!isConnectorInitialized) {
        twitterError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return twitterError;
    }
    string tweetPath = "/1.1/trends/place.json";
    string urlParams = "id=" + locationId;
    string oauthStr = urlParams + "&" + constructOAuthParams(twitterConnector.oAuthConfig.clientId,
    twitterConnector.oAuthConfig.accessToken);

    http:Request request = {};
    constructRequestHeaders(request, "GET", tweetPath, twitterConnector.oAuthConfig.clientId,
    twitterConnector.oAuthConfig.clientSecret, twitterConnector.oAuthConfig.accessToken,
                            twitterConnector.oAuthConfig.accessTokenSecret, oauthStr);
    tweetPath = tweetPath + "?" + urlParams;

    Trends[] trends = [];
    var httpResponse = twitterHttpClientEP -> get(tweetPath, request);

    match httpResponse {
        http:HttpConnectorError err => {
            twitterError.errorMessage = err.message;
            twitterError.statusCode = err.statusCode;
            return twitterError;
        }
        http:Response response => { int statusCode = response.statusCode;
                                    var twitterJSONResponse = response.getJsonPayload();
                                    match twitterJSONResponse {
                                        mime:EntityError err => {
                                            twitterError.errorMessage = err.message;
                                            return twitterError;
                                        }
                                        json jsonResponse => {
                                            if (statusCode == 200) {
                                                trends = convertTrends(jsonResponse);
                                                return trends;
                                            } else {
                                                twitterError.errorMessage = jsonResponse.errors[0].message.toString();
                                                twitterError.statusCode = statusCode;
                                                return twitterError;
                                            }
                                        }
                                    }
        }
    }
}

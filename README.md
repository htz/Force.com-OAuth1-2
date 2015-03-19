# Force.com OAuth 1.0 and 2.0 Developer Kit with API Tester

## Introduction
This project was copied over from &quot;<https://github.com/jesperfj/sfdc-oauth-playground> by Jesper Joergensen&quot;, since I do all my projects on github now. I don't expect to make any changes, so the two locations will likely stay in sync but this is now the main project home.

This project provides a basic Oauth 1.0/2.0 consumer implementation in Apex. It defines objects for storing keys and secrets for multiple services and users. It also comes with an API "playground" where you can try out API calls to your Oauth services.

## Package
* Package Name: OAuth Development Kit
* Version: 1.0
* Last Update: 2015/03/19 11:15
* Install URL: [Install](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t10000000GEwe)
* Commit: aa6675de98830783c51bc8afd01afe609141ed02

## About this project

The main purpose of this project is to show how to write OAuth signed requests in Apex, but it expanded beyond that to a more full fledged OAuth consumer playground. It comes with a set of custom objects for storing OAuth service configuration and OAuth tokens on behalf of users in the org.

IMPORT SECURITY NOTE: When you authorize access to a remote service, your personal and very private access token and secret are stored in a custom object. Do not use this app in an org where you do not trust users who may access this object (OAuth\_Token\_\_c). At the very least, administrators will have access to the data.

The project also comes with functionality for authorizing access, including authorization redirects and callbacks.

Finally, the project includes an API Tester that you can use to make API requests to services that have been authorized for access.

The code has been tested with the following services:

**Outh 1.0**
* LinkedIn
* Twitter
* TripIt
* Dropbox
* Hatena
* Cacoo

**Oauth 2.0**
* Salesforce
* Facebook
* Google
* foursquare
* GitHub

### Apex Classes
* OAuth.cls
* OAuthException.cls (extends Exception)
* OAuth1.cls (extends OAuth)
* OAuthSign.cls
* OAuth1Exception.cls (extends OAuthException)
* OAuth2.cls (extends OAuth)
* OAuth2Exception.cls (extends OAuthException)
* OAuthJSON.cls
* OAuthJSONException.cls (extends OAuthException)

### Sample Code
* OAuthTwitterSampleController.cls
* OAuthTwitterSample.page

**Create "OAuth Service" record of Name field as "Twitter".**

## Reference RFC
* [RFC 5849](http://tools.ietf.org/html/rfc5849) - The OAuth 1.0 Protocol
* [RFC 6749](http://tools.ietf.org/html/rfc6749) - The OAuth 2.0 Authorization Framework
* [RFC 6750](http://tools.ietf.org/html/rfc6750) - The OAuth 2.0 Authorization Framework: Bearer Token Usage

## License
**MIT License**

Copyright (c) 2012 Masashi Tsuji

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

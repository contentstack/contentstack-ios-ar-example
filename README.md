
[![Contentstack](https://www.contentstack.com/docs/static/images/contentstack.png)](https://www.contentstack.com/)

# Contentstack iOS Augmented Reality example app

Contentstack iOS Augmented Reality example app provides you to view USDZ files within the application. Given below is a detailed guide and helpful resources to get started with our iOS Persistence Library.

## Quickstart

Here’s a quick guide on how to create a Augmented Reality for iOS using iOS SDK and Contentstack.

## Prerequisites
- Use Xcode 10.1 and later and Mac OS X 10.14.1 and later
- [Conentstack](https://app.contentstack.com)  account

## Installation and Setup

In this tutorial, we will first go through the steps involved in configuring Contentstack, and then look at the steps required to customize and use the presentation layer.

### Step 1: Create a stack

Log in to your Contentstack account, and create a new stack. This stack will hold all the data, specific to your website. Learn more on [how to create a stack](https://www.contentstack.com/docs/guide/stack#create-a-new-stack).

### Step 2: Add a publishing environment
To add an environment in Contentstack, navigate to ‘Settings' -> 'Environment', and click on the '+ New Environment’ tab. Provide a suitable name for your environment, say ‘staging’. Specify the base URL (e.g., ‘http://YourDomainName.com’), and select the language (e.g., English - United States). Then, click on 'Save'. Read more about environments.

### Step 3: Import content types
A content type is like the structure or blueprint of a page or a section of your web or mobile property. Read more about [Content Types](https://www.contentstack.com/docs/guide/content-types).
For this website, basic content types are required: Product. For quick integration, we have already created these content types. You simply need to import them to your stack. (You can also create your own content types. Learn [how to do this](https://www.contentstack.com/docs/guide/content-types#creating-a-content-type)).


### Step 4: Adding content
Create and publish entries for all the content types

Add a few dummy entries for news articles for the ‘Product’ content type. Save and publish these entries. Learn how to [create](https://www.contentstack.com/docs/guide/content-management#add-a-new-entry) and [publish](https://www.contentstack.com/docs/guide/content-management#publish-an-entry) entries.

With this step, you have created sample data for your website. Now, it’s time to use and configure the presentation layer. 

### Step 5: Clone and configure the application
To get your app up and running quickly, we have created a sample iOS app for this project. You need to download it and change the configuration. Download the app using the command given below: 

```
$ git clone https://github.com/contentstack/contentstack-ios-ar-example.git
```

Now add your Contentstack API Key, Delivery Token, and Environment to the CSConstants.swift file within your project. (Find your Stack's API Key and Delivery Token).

```

enum StackConstants {
    // Constant define here.
    static let 🔑   =    "***REMOVED***"
    static let 🗝   =    "***REMOVED***"
    static let 🌅   =    "development"
}


enum CSARDemoConstants {
    static let 📦🎁💼   = "product"
}
```
This will initiate your project.


### Step 6: Build and run your Augmented Reality app
Install the pods and open the .xcworkspace file to see the project in Xcode.
```
$ pod install
$ open ContentstackAR.xcworkspace
```
Now that we have a working project, you can build and run it.


# Ersa

In Greek mythology, Ersa is the daughter of Zeus who is the God of many things including Lightning.

In Salesforce, Ersa is a utility to easily show Lightning Components on a Visualforce Page. 

<a href="https://githubsfdeploy.herokuapp.com?owner=postmates&repo=salesforce-ersa">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

### Why Should You Use This Library?
Loading Lightning Components onto Visualforce Pages is a tedious operation that requires copying and pasting lots of boiler-plate code. You also need to roll your own handlers for Standard Lightning Events, which adds to the boiler-plate.

This utility removes the boiler-plate and enables you to write code that only pertains to the program you are developing.

### How to Use This Library
1. Build a Lightning Component
2. [Create and Reference a Lightning Dependency App](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_visualforce.htm)
3. Add the following tags to your Visualforce Page
   1. `<apex:includeLightning />`
   1. `<apex:includeScript value="{!$Resource.Ersa}"/>`
   1. `<div id="hello-world-lightning-component"></div>`
      * You should replace `hello-world-lightning-component` with a real `id` here
   
4. Follow the pattern below to load the Lightning Component 
```html
<script>
    Ersa.uiTheme = '{!$User.UITheme}'; // tell Ersa which UITheme you are running in
    Ersa.lightningApp = 'c:HelloWorldApp'; // tell Ersa which Lightning Dependency App you created
    
    // Add Lightning Components to load
    Ersa.addLightningComponent(
        'c:HelloWorld',
        {accountId: '{!Account.Id}'},
        'hello-world-lightning-component' // this is the id of the <div> you want the component put into
    );
    
    Ersa.loadComponents(); // loads the components
</script>
```

### Currently Supported Lightning Events
Ersa currently handles the following Standard Lighting Events
* `force:navigateToSObject`
* `force:navigateToURL`
* `force:refreshView`
* `force:showToast`

### Collaboration
We welcome feedback and collaboration. If you see an area for improvement, feel free to send a pull request
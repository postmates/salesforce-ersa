/**
 * Ersa by Postmates
 * Utilities for Lightning Components in Visualforce
 *
 * In Greek mythology, Ersa is the goddess of dew and the daughter of Zeus and
 * the Moon (Selene), sister of Pandia and half-sister to Endymion's 50
 * daughters.
 * - Wikipedia
 *
 * Website:
 * GitHub:
 * License:
 */
(function(window) {
    window.Ersa = {
        uiTheme: null,
        lightningApp: null,
        lightningComponents: [],
        addLightningComponent: (name, attributes, elementId) => {
            if(!name || ! elementId) throw new Error('name and elementId are required');
            Ersa.lightningComponents.push({name, attributes, elementId});
        },
        loadComponents: () => {
            if(!Ersa.lightningComponents || Ersa.lightningComponents.length === 0 || !Ersa.lightningApp) {
                throw new Error('call Ersa.addLightningComponent() to add lightning components before loading the components');
            }

            // Lightning Out Markup Docs: https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/lightning_out_markup.htm
            // We can call $Lightning.use() more than once, but ***we must reference the same dependency app in every call***
            // Because of this, I call $Lightning.use() once and then and call $Lightning.createComponent forEach component passed in

            // $Lightning.use(String appName, Function callback, String lightningEndPointURI, String authToken)
            $Lightning.use(
                Ersa.lightningApp,
                () => {
                    Ersa.lightningComponents.forEach(lightningComponent => {
                        // $Lightning.createComponent(String type, Object attributes, String locator, Function callback)
                        $Lightning.createComponent(lightningComponent.name, lightningComponent.attributes, lightningComponent.elementId, Ersa.addEventHandlers);
                    });
                }
            );
        },

        addEventHandlers: component => {
            // Lightning Event Reference: https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/ref_events.htm
            // addEventHandler(String event, Function handler, String phase, String includeFacets)

            // force:navigateToSObject
            component.addEventHandler(
                'force:navigateToSObject',
                event => {
                    const recordId = event.getParam('recordId');

                    if(Ersa.isLightningUiTheme()) {
                        sforce.one.navigateToSObject(recordId);
                    } else if(Ersa.isClassicUiTheme()) {
                        window.parent.location = '/' + recordId;
                    } else {
                        Ersa.logError();
                    }
                }
            );

            // force:navigateToURL
            component.addEventHandler(
                'force:navigateToURL',
                event => {
                    const url = event.getParam('url');

                    if(Ersa.isLightningUiTheme()) {
                        sforce.one.navigateToURL(url);
                    } else if(Ersa.isClassicUiTheme()) {
                        window.parent.location = url;
                    } else {
                        Ersa.logError();
                    }
                }
            );

            // force:refreshView
            component.addEventHandler(
                'force:refreshView',
                () => {
                    if(Ersa.isLightningUiTheme()) {
                        sforce.one.refreshView();
                    } else if(Ersa.isClassicUiTheme()) {
                        window.parent.location.reload();
                    } else {
                        Ersa.logError();
                    }
                }
            );

            // force:showToast
            component.addEventHandler(
                'force:showToast',
                event => {
                    // Inspired by this blog post: http://joebuschmann.com/salesforce-lightning-navigation-events-in-a-visualforce-page/
                    if(Ersa.isLightningUiTheme() && SfdcApp && SfdcApp.projectOneNavigator && SfdcApp.projectOneNavigator.fireContainerEvent) {
                        // Not officially supported by Salesforce
                        SfdcApp.projectOneNavigator.fireContainerEvent('force:showToast', event.getParams());
                    } else if(Ersa.isClassicUiTheme()) {
                        // TODO: Roll my own toast with SLDS
                        window.alert(event.getParam('message'));
                    } else {
                        Ersa.logError();
                    }
                }
            );
        },

        // Theme Name    | Description
        // ----------------------------------------------------------------------
        // Theme1        | Obsolete Salesforce theme
        // Theme2        | Salesforce Classic 2005 user interface theme
        // Theme3        | Salesforce Classic 2010 user interface theme
        // Theme4d       | Salesforce Lightning Experience user interface theme
        // Theme4t       | Salesforce mobile app theme
        // Theme4u       | Lightning Console theme
        // PortalDefault | Salesforce Customer Portal theme
        // Webstore      | Salesforce AppExchange theme
        isLightningUiTheme: () => Ersa.uiTheme === 'Theme4d' || Ersa.uiTheme === 'Theme4t',
        isClassicUiTheme: () => Ersa.uiTheme === 'Theme3',
        logError: () => console.error('Unsupported UITheme: ' + Ersa.uiTheme),
    };
})(window);
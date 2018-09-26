/**
 * Ersa by Postmates
 * Utilities for Lightning Components in Visualforce
 *
 * In Greek mythology, Ersa is the daughter of Zeus who is the God of many things including Lightning.
 * In Salesforce, Ersa is a utility to easily show Lightning Components on a Visualforce Page.
 *
 * GitHub: https://github.com/postmates/salesforce-ersa
 * License: BSD 3-Clause License
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

/*
Copyright (c) 2018 Postmates, Inc
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
in the documentation and/or other materials provided with the distribution.
3. Neither the name of the nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
 */
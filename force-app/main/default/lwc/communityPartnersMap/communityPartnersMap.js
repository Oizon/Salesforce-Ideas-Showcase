import { LightningElement , wire} from 'lwc';
import getRecords from "@salesforce/apex/CommunityPartnerService.getRecords";
import {NavigationMixin} from 'lightning/navigation';

export default class CommunityPartnersMap extends NavigationMixin(LightningElement) {
    mapMarkers;
    error;
    center;
    selectedRecord;

    @wire(getRecords)
    wiredPartners({ error, data }) {
        let mapMarker = 'M 10 15 L 4.122 18.09 l 1.123 -6.545 L 0.489 6.91 l 6.572 -0.955 L 10 0 l 2.939 5.955 l 6.572 0.955 l -4.755 4.635 l 1.123 6.545 Z';

        this.center = {
            location: { Latitude: '35.5000000', Longitude: '-98.3500000' }
        };

        if (data) {
            this.mapMarkers = data.map((partner) => {
                return {
                    location: {
                        Street: partner.BillingStreet,
                        City: partner.BillingCity,
                        State: partner.BillingState
                    },
                    icon: 'standard:account',
                    title: partner.Name,
                    mapIcon: {
                        strokeColor: '#002E5D',
                        strokeOpacity: 1,
                        strokeWeight: 2,
                        fillOpacity: 1,
                        fillColor: '#ffffff',
                        path: mapMarker
                    },
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.mapMarkers = undefined;
        }
    }
}
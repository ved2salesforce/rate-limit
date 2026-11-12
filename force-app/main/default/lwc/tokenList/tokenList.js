import { LightningElement, wire, track } from 'lwc';
import getActiveTokens from '@salesforce/apex/TokenController.getActiveTokens';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Value', fieldName: 'Value__c', type: 'text' },
    { label: 'Expiry Date', fieldName: 'ExpiryDate__c', type: 'date',
      typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit',
                        hour: '2-digit', minute: '2-digit' } },
    { label: 'Status', fieldName: 'Status__c', type: 'text' }
];

export default class TokenList extends LightningElement {
    @track tokens = [];
    @track error;
    @track isLoading = true;

    columns = COLUMNS;

    @wire(getActiveTokens)
    wiredTokens({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.tokens = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.tokens = [];
        }
    }

    get hasTokens() {
        return this.tokens && this.tokens.length > 0;
    }

    get errorMessage() {
        if (this.error) {
            if (this.error.body && this.error.body.message) {
                return this.error.body.message;
            }
            return String(this.error);
        }
        return '';
    }
}

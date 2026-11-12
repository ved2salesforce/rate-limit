import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createToken from '@salesforce/apex/TokenController.createToken';
import revokeToken from '@salesforce/apex/TokenController.revokeToken';

export default class TokenActions extends LightningElement {
    /** Optional: when placed on a Token__c record page, the record Id to revoke */
    @api tokenId;

    @track tokenValue = '';
    @track expiryDate = '';
    @track isCreating = false;
    @track isRevoking = false;

    handleValueChange(event) {
        this.tokenValue = event.target.value;
    }

    handleExpiryChange(event) {
        this.expiryDate = event.target.value;
    }

    handleCreateToken() {
        if (!this.tokenValue) {
            this.dispatchToast('error', 'Validation Error', 'Token Value is required.');
            return;
        }
        this.isCreating = true;
        // Convert datetime-local value to format expected by Apex: yyyy-MM-dd HH:mm:ss
        let expiryForApex = '';
        if (this.expiryDate) {
            expiryForApex = this.expiryDate.replace('T', ' ') + ':00';
        }
        createToken({ value: this.tokenValue, expiryDate: expiryForApex })
            .then((id) => {
                this.isCreating = false;
                this.tokenValue = '';
                this.expiryDate = '';
                this.dispatchToast('success', 'Token Created', 'Token was created successfully.');
                this.dispatchEvent(new CustomEvent('tokencreated', { detail: { id } }));
            })
            .catch((error) => {
                this.isCreating = false;
                const msg = (error && error.body && error.body.message) ? error.body.message : String(error);
                this.dispatchToast('error', 'Error Creating Token', msg);
            });
    }

    handleRevokeToken() {
        this.isRevoking = true;
        revokeToken({ tokenId: this.tokenId })
            .then(() => {
                this.isRevoking = false;
                this.dispatchToast('success', 'Token Revoked', 'Token was revoked successfully.');
                this.dispatchEvent(new CustomEvent('tokenrevoked', { detail: { id: this.tokenId } }));
            })
            .catch((error) => {
                this.isRevoking = false;
                const msg = (error && error.body && error.body.message) ? error.body.message : String(error);
                this.dispatchToast('error', 'Error Revoking Token', msg);
            });
    }

    dispatchToast(variant, title, message) {
        this.dispatchEvent(new ShowToastEvent({ variant, title, message }));
    }
}

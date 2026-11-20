import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchOpenJobs from '@salesforce/apex/TalentHubJobService.searchOpenJobsForLwc';

const COLUMNS = [
    {
        label: 'Job Title',
        type: 'button',
        fieldName: 'Name',
        typeAttributes: {
            label: { fieldName: 'Name' },
            name: 'open_record',
            variant: 'base'
        }
    },
    { label: 'Department', fieldName: 'Department__c', type: 'text' },
    { label: 'Location', fieldName: 'Location__c', type: 'text' },
    { label: 'Open Date', fieldName: 'Open_Date__c', type: 'date-local' },
    { label: 'Close Date', fieldName: 'Close_Date__c', type: 'date-local' }
];

export default class TalentHubJobSearch extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    jobs = [];
    department = '';
    location = '';
    isLoading = false;
    hasSearched = false;
    errorMessage = '';

    connectedCallback() {
        this.loadJobs();
    }

    get hasJobs() {
        return this.jobs.length > 0;
    }

    get showNoResults() {
        return this.hasSearched && !this.isLoading && !this.errorMessage && !this.hasJobs;
    }

    handleDepartmentChange(event) {
        this.department = event.target.value;
    }

    handleLocationChange(event) {
        this.location = event.target.value;
    }

    handleSearch() {
        this.loadJobs();
    }

    handleClear() {
        this.department = '';
        this.location = '';
        this.loadJobs();
    }

    async loadJobs() {
        this.isLoading = true;
        this.hasSearched = false;
        this.errorMessage = '';
        try {
            const results = await searchOpenJobs({
                department: this.department.trim() || null,
                location: this.location.trim() || null
            });
            this.jobs = results || [];
        } catch (error) {
            this.jobs = [];
            this.errorMessage = this.reduceError(error);
        } finally {
            this.isLoading = false;
            this.hasSearched = true;
        }
    }

    handleRowAction(event) {
        if (event.detail.action.name !== 'open_record') {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.row.Id,
                objectApiName: 'Job__c',
                actionName: 'view'
            }
        });
    }

    reduceError(error) {
        if (Array.isArray(error?.body)) {
            return error.body.map((item) => item.message).join(', ');
        }
        return error?.body?.message || error?.message || 'Could not load jobs. Please try again.';
    }
}
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import searchCandidates from '@salesforce/apex/TalentHubApplicationStartController.searchCandidates';
import getOpenJobs from '@salesforce/apex/TalentHubApplicationStartController.getOpenJobs';

export default class TalentHubApplicationStart extends NavigationMixin(LightningElement) {
    candidates = [];
    jobs = [];
    searchTerm = '';
    selectedCandidateId = '';
    selectedJobId = '';
    errorMessage = '';
    hasSearched = false;

    connectedCallback() {

        this.loadJobs();
    }

    async loadCandidates(searchTerm) {
        try {
            const records = await searchCandidates({ searchTerm });
            this.candidates = (records || []).map((candidate) => ({
                id: candidate.Id,
                name: [candidate.Name, candidate.Last_Name__c]
                    .filter(Boolean)
                    .join(' '),
                email: candidate.Email__c
            }));
            this.errorMessage = '';
        } catch (error) {
            this.candidates = [];
            this.errorMessage =
                error?.body?.message || error?.message ||
                'Unable to load candidates. Check your access and try again.';
        }
    }

    async loadJobs() {
        try {
            const records = await getOpenJobs();
            this.jobs = (records || []).map((job) => ({
                id: job.Id,
                title: job.Name,
                status: job.Status__c
            }));
        } catch (error) {
            this.jobs = [];
            this.errorMessage =
                error?.body?.message || error?.message ||
                'Unable to load open jobs. Check your access and try again.';
        }
    }

    get filteredCandidates() {
        const query = this.searchTerm.trim().toLowerCase();
        if (!query) {
            return this.candidates;
        }

        return this.candidates.filter((candidate) =>
            candidate.name.toLowerCase().includes(query) ||
            (candidate.email || '').toLowerCase().includes(query)
        );
    }

    get openJobOptions() {
        return this.jobs
            .filter((job) => job.status === 'Open')
            .map((job) => ({ label: job.title, value: job.id }));
    }

    get showNoCandidates() {
        return this.hasSearched && this.filteredCandidates.length === 0;
    }

    get candidateButtonLabel() {
        return 'Select';
    }

    handleSearch(event) {
        this.searchTerm = event.target.value; this.selectedCandidateId = '';
        const query = this.searchTerm.trim();
        this.hasSearched = Boolean(query);
        this.candidates = [];
        if (query) this.loadCandidates(query);
    }

    selectCandidate(event) {
        const selectedCandidate = this.candidates.find((candidate) => candidate.id === event.currentTarget.dataset.id);
        this.selectedCandidateId = event.currentTarget.dataset.id;
        this.searchTerm = selectedCandidate
            ? [selectedCandidate.name, selectedCandidate.email].filter(Boolean).join(' — ')
            : '';
        this.candidates = [];
        this.hasSearched = false;
        this.errorMessage = '';
    }

    selectJob(event) {
        this.selectedJobId = event.detail.value;
        this.errorMessage = '';
    }

    continueToApplication() {
        if (!this.selectedCandidateId || !this.selectedJobId) {
            this.errorMessage = 'Select a candidate and an open job to continue.';
            return;
        }

        this.dispatchEvent(
            new CustomEvent('applicationstart', {
                detail: {
                    candidateId: this.selectedCandidateId,
                    jobId: this.selectedJobId
                },
                bubbles: true,
                composed: true
            })
        );

        const defaultFieldValues = encodeDefaultFieldValues({
            Candidate__c: this.selectedCandidateId,
            Job__c: this.selectedJobId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Job_Application__c',
                actionName: 'new'
            },
            state: { defaultFieldValues }
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/lightning/o/Job_Application__c/new?defaultFieldValues=${defaultFieldValues}`
            }
        });
        window.location.assign(`/lightning/o/Job_Application__c/new?defaultFieldValues=${defaultFieldValues}`);
    }
}
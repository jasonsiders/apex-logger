import { LightningElement, api } from "lwc";

// TODO: Add real copy
const DESCRIPTION = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.";
// Maps to the expected @InvocableVariable names from the LogInput class
const INVOCABLE_VARS = {
	BODY: "body",
	LEVEL: "level",
	LOGGED_FROM: "loggedFrom",
	RELATED_RECORD: "relatedRecordId",
	SOURCE: "source"
};
// Maps to valid System.LoggingLevel enum options
const LEVEL_OPTIONS = [
	{ label: "FINEST", value: "FINEST" },
	{ label: "FINER", value: "FINER" },
	{ label: "FINE", value: "FINE" },
	{ label: "INFO", value: "INFO" },
	{ label: "DEBUG", value: "DEBUG" },
	{ label: "WARN", value: "WARN" },
	{ label: "ERROR", value: "ERROR" }
];

export default class LoggerCpe extends LightningElement {
	@api inputVariables;
	description = DESCRIPTION;
	invocableVars = INVOCABLE_VARS;
	levelOptions = LEVEL_OPTIONS;

	@api validate() {
		let errors = [];
		const innerComponents = ["lightning-combobox", "lightning-input", "lightning-textarea"];
		innerComponents?.forEach((componentName) => {
			const component = this.template.querySelector(componentName);
			if (!component?.reportValidity()) {
				const label = component?.label;
				const error = { key: label, errorString: `${label} is invalid`};
				errors?.push(error);
			}
		});
		return errors;
	}

	get body() {
		return this.getInvocableVariable(this.invocableVars?.BODY)?.value;
	}

	get level() {
		return this.getInvocableVariable(this.invocableVars?.LEVEL)?.value;
	}

	get loggedFrom() {
		return this.getInvocableVariable(this.invocableVars?.LOGGED_FROM)?.value;
	}

	get relatedRecordId() {
		return this.getInvocableVariable(this.invocableVars?.RELATED_RECORD)?.value;
	}

	get source() {
		return this.getInvocableVariable(this.invocableVars?.SOURCE)?.value;
	}

	getInvocableVariable(name) {
		// Retrieve the named Invocable Variable
		return this.inputVariables?.find((variable) => variable?.name === name);
	} 

	handleChange(event) {
		// Publish a ValueChangedEvent to send the input value to matching inputVariable
		const elementName = event?.target?.name || event?.detail?.name;
		const newValue = event?.detail?.newValue || event?.detail?.value;
		const valueChangedEvent = new CustomEvent("configuration_editor_input_value_changed", {
			bubbles: true,
			cancelable: false,
			composed: true, 
			detail: {
				name: elementName,
				newValue,
				newValueDataType: "String"
			}
		});
		this.dispatchEvent(valueChangedEvent);
	}
}

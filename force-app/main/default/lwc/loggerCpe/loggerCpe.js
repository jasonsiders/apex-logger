import { api } from "lwc";
import {
	CustomPropertyEditor,
	DataTypes,
	Error,
	ValueChangedEvent,
} from "c/customPropertyEditor";

// TODO: Replace this with a real description!
const DESCRIPTION = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';
const INVOCABLE_VARS = {
	BODY: "body",
	LEVEL: "level",
	LOGGED_FROM: "loggedFrom",
	RELATED_RECORD: "relatedRecordId",
	SOURCE: "source"
};
const LEVEL_OPTIONS = [
	{ label: "FINEST", value: "FINEST" },
	{ label: "FINER", value: "FINER" },
	{ label: "FINE", value: "FINE" },
	{ label: "INFO", value: "INFO" },
	{ label: "DEBUG", value: "DEBUG" },
	{ label: "WARN", value: "WARN" },
	{ label: "ERROR", value: "ERROR" }
];

export default class CpeLogger extends CustomPropertyEditor {
	description = DESCRIPTION;
	invocableVars = INVOCABLE_VARS;
	levelOptions = LEVEL_OPTIONS;

	@api validate() {
		let errors = [];
		const innerComponents = ["lightning-combobox", "lightning-textarea"];
		innerComponents?.forEach((componentName) => {
			const component = this.template.querySelector(componentName);
			if (!component?.reportValidity()) {
				errors.push(new Error(component?.label, `${component?.label} is invalid`));
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

	handleChange(event) {
		const elementName = event?.target?.name || event?.detail?.name;
		const newValue = event?.detail?.newValue || event?.detail?.value;
		const valueChangedEvent = new ValueChangedEvent(elementName, newValue, DataTypes.STRING);
		this.dispatchEvent(valueChangedEvent);
	}
}

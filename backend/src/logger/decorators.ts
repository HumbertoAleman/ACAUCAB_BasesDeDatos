import { CORS_HEADERS } from "../../globals";
import Logger from "./logger";

function LogFunctionExecution(_: any, propertyName: string, descriptor: PropertyDescriptor): void {
	const originalMethod = descriptor.value;
	descriptor.value = function (...args: any[]) {
		Logger.debug(`Executing ${propertyName} with parameters: ${args}`);
		return originalMethod.apply(this, args);
	};
}

function sqlProtection(_: any, propertyName: string, descriptor: PropertyDescriptor): void {
	const originalMethod = descriptor.value;
	descriptor.value = async function (...args: any[]) {
		try {
			return await originalMethod.apply(this, args);
		} catch (e) {
			Logger.error(`Function ${propertyName} returned an error:\n\t${e}`)
			return Response.json({ error_information: e }, { ...CORS_HEADERS, status: 500 })
		}
	};
}

export { LogFunctionExecution, sqlProtection }

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

function AddOptionsMethod<T extends { new(...args: any[]): {} }>(constructor: T) {
	return class extends constructor {
		[x: string]: any;
		constructor(...args: any[]) {
			super(...args);
			for (const route in this.routes) {
				if (this.routes.hasOwnProperty(route)) {
					const methods = this.routes[route];
					methods.OPTIONS = async () => {
						const headers = {
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": `${Object.keys(methods)}`,
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
						};
						return new Response(null, { status: 204, headers: headers, });
					};
				}
			}
		}
	};
}

export { LogFunctionExecution, sqlProtection, AddOptionsMethod }
